import { Prisma } from "@prisma/client";
import { prisma } from "../../config/database";
import { NotFoundError, UnauthorizedError, BadRequestError } from "../../shared/errors";
import { algorandService } from "../algorand/algorand.service";

// ── DTOs ────────────────────────────────────────────────────

export interface CreateBountyDTO {
  title: string;
  description: string;
  category: string;
  algoAmount?: number;
  deadline: string; // ISO date string
  latitude?: number;
  longitude?: number;
  location?: string;
  imageUrls?: string[];
  extraFields?: Prisma.InputJsonValue;
}

export interface UpdateBountyDTO {
  title?: string;
  description?: string;
  category?: string;
  algoAmount?: number;
  deadline?: string;
  latitude?: number;
  longitude?: number;
  location?: string;
  imageUrls?: string[];
  extraFields?: Prisma.InputJsonValue;
}

// ── Select shape ────────────────────────────────────────────

const bountySelect = {
  id: true,
  title: true,
  description: true,
  category: true,
  algoAmount: true,
  deadline: true,
  status: true,
  latitude: true,
  longitude: true,
  location: true,
  imageUrls: true,
  extraFields: true,
  escrowTxId: true,
  escrowStatus: true,
  refundTxId: true,
  createdAt: true,
  updatedAt: true,
  creator: {
    select: {
      id: true,
      name: true,
      avatarUrl: true,
      walletAddress: true,
    },
  },
  _count: {
    select: { claims: true },
  },
} as const;

// ── Service ─────────────────────────────────────────────────

export class BountyService {
  /**
   * Create a new bounty.
   */
  async create(creatorId: string, dto: CreateBountyDTO) {
    return prisma.bounty.create({
      data: {
        creatorId,
        title: dto.title,
        description: dto.description,
        category: dto.category,
        algoAmount: dto.algoAmount ?? 0,
        deadline: new Date(dto.deadline),
        latitude: dto.latitude,
        longitude: dto.longitude,
        location: dto.location,
        imageUrls: dto.imageUrls ?? [],
        extraFields: dto.extraFields ?? undefined,
      },
      select: bountySelect,
    });
  }

  /**
   * List bounties with optional filters.
   */
  async list(params: {
    status?: string;
    category?: string;
    creatorId?: string;
    page?: number;
    limit?: number;
  }) {
    const page = params.page ?? 1;
    const limit = Math.min(params.limit ?? 20, 100);
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = {};
    if (params.status) where.status = params.status;
    if (params.category) where.category = params.category;
    if (params.creatorId) where.creatorId = params.creatorId;
    // If no explicit filter and no creatorId, hide CLAIMED/IN_REVIEW from public
    if (!params.status && !params.creatorId) {
      where.status = { in: ["OPEN", "COMPLETED", "CANCELLED"] };
    }

    const [bounties, total] = await Promise.all([
      prisma.bounty.findMany({
        where,
        select: bountySelect,
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
      prisma.bounty.count({ where }),
    ]);

    return {
      bounties,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get a single bounty by ID (with claims).
   */
  async getById(id: string) {
    const bounty = await prisma.bounty.findUnique({
      where: { id },
      select: {
        ...bountySelect,
        claims: {
          select: {
            id: true,
            status: true,
            proofUrl: true,
            note: true,
            paymentTxId: true,
            submittedAt: true,
            resolvedAt: true,
            createdAt: true,
            claimer: {
              select: { id: true, name: true, avatarUrl: true, walletAddress: true },
            },
          },
          orderBy: { createdAt: "desc" },
        },
      },
    });

    if (!bounty) throw new NotFoundError("Bounty not found");
    return bounty;
  }

  /**
   * Update a bounty (only the creator can update).
   */
  async update(id: string, userId: string, dto: UpdateBountyDTO) {
    const bounty = await prisma.bounty.findUnique({
      where: { id },
      select: { creatorId: true },
    });

    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.creatorId !== userId) {
      throw new UnauthorizedError("You can only edit your own bounties");
    }

    return prisma.bounty.update({
      where: { id },
      data: {
        ...(dto.title !== undefined && { title: dto.title }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.category !== undefined && { category: dto.category }),
        ...(dto.algoAmount !== undefined && { algoAmount: dto.algoAmount }),
        ...(dto.deadline !== undefined && { deadline: new Date(dto.deadline) }),
        ...(dto.latitude !== undefined && { latitude: dto.latitude }),
        ...(dto.longitude !== undefined && { longitude: dto.longitude }),
        ...(dto.location !== undefined && { location: dto.location }),
        ...(dto.imageUrls !== undefined && { imageUrls: dto.imageUrls }),
        ...(dto.extraFields !== undefined && { extraFields: dto.extraFields }),
      },
      select: bountySelect,
    });
  }

  /**
   * Delete a bounty (only creator can delete, only OPEN).
   * If funded → refund ALGO to creator's wallet first.
   */
  async delete(id: string, userId: string) {
    const bounty = await prisma.bounty.findUnique({
      where: { id },
      select: {
        creatorId: true,
        status: true,
        algoAmount: true,
        escrowStatus: true,
        title: true,
        creator: { select: { walletAddress: true } },
      },
    });

    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.creatorId !== userId) {
      throw new UnauthorizedError("You can only delete your own bounties");
    }
    if (bounty.status !== "OPEN") {
      throw new UnauthorizedError("Can only delete OPEN bounties");
    }

    // Refund escrowed ALGO if bounty was funded
    if (bounty.escrowStatus === "FUNDED" && bounty.algoAmount > 0) {
      if (!bounty.creator.walletAddress) {
        throw new BadRequestError(
          "Creator has no wallet address set — cannot refund"
        );
      }
      try {
        const refund = await algorandService.refundCreator(
          bounty.creator.walletAddress,
          bounty.algoAmount,
          id
        );
        await prisma.bounty.update({
          where: { id },
          data: { refundTxId: refund.txId, escrowStatus: "REFUNDED" },
        });
        // Record CREDIT for creator (escrow refund)
        await prisma.walletTransaction.create({
          data: {
            userId,
            type: "CREDIT",
            amountAlgo: bounty.algoAmount,
            txId: refund.txId,
            bountyId: id,
            bountyTitle: bounty.title,
            counterpartyAddress: bounty.creator.walletAddress,
            description: `Escrow refunded — "${bounty.title}" deleted`,
          },
        });
      } catch (err: any) {
        console.error("[Escrow] Refund failed:", err.message);
        throw new BadRequestError(
          `Escrow refund failed: ${err.message}. Bounty not deleted.`
        );
      }
    }

    await prisma.bounty.delete({ where: { id } });
  }

  /**
   * Claim a bounty.
   */
  async claim(bountyId: string, claimerId: string) {
    const bounty = await prisma.bounty.findUnique({
      where: { id: bountyId },
      select: { creatorId: true, status: true },
    });

    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.status !== "OPEN") {
      throw new UnauthorizedError("Bounty is not open for claims");
    }
    if (bounty.creatorId === claimerId) {
      throw new UnauthorizedError("Cannot claim your own bounty");
    }

    const claim = await prisma.bountyClaim.create({
      data: { bountyId, claimerId },
      select: {
        id: true,
        status: true,
        createdAt: true,
        claimer: { select: { id: true, name: true, avatarUrl: true } },
      },
    });

    // Update bounty status to CLAIMED
    await prisma.bounty.update({
      where: { id: bountyId },
      data: { status: "CLAIMED" },
    });

    return claim;
  }

  /**
   * Submit proof for a claim (supports multiple file URLs).
   */
  async submitProof(
    claimId: string,
    claimerId: string,
    proofUrls: string[],
    note?: string
  ) {
    const claim = await prisma.bountyClaim.findUnique({
      where: { id: claimId },
      select: { claimerId: true, status: true },
    });

    if (!claim) throw new NotFoundError("Claim not found");
    if (claim.claimerId !== claimerId) {
      throw new UnauthorizedError("Not your claim");
    }
    if (claim.status !== "ACTIVE") {
      throw new UnauthorizedError("Claim is not active");
    }

    const updated = await prisma.bountyClaim.update({
      where: { id: claimId },
      data: {
        status: "SUBMITTED",
        proofUrl: proofUrls.join(","),
        note,
        submittedAt: new Date(),
      },
    });

    // Update bounty to IN_REVIEW
    await prisma.bounty.update({
      where: { id: updated.bountyId },
      data: { status: "IN_REVIEW" },
    });

    return updated;
  }

  /**
   * Declaim / leave a bounty (only the claimer, only ACTIVE claims).
   */
  async declaim(claimId: string, claimerId: string) {
    const claim = await prisma.bountyClaim.findUnique({
      where: { id: claimId },
      select: { claimerId: true, status: true, bountyId: true },
    });

    if (!claim) throw new NotFoundError("Claim not found");
    if (claim.claimerId !== claimerId) {
      throw new UnauthorizedError("Not your claim");
    }
    if (claim.status !== "ACTIVE") {
      throw new UnauthorizedError("Can only leave active claims");
    }

    // Delete the claim
    await prisma.bountyClaim.delete({ where: { id: claimId } });

    // Check if any remaining claims exist for this bounty
    const remaining = await prisma.bountyClaim.count({
      where: { bountyId: claim.bountyId },
    });

    // If no claims left, re-open the bounty
    if (remaining === 0) {
      await prisma.bounty.update({
        where: { id: claim.bountyId },
        data: { status: "OPEN" },
      });
    }
  }

  /**
   * Approve or reject a claim (only bounty creator).
   * If approved & bounty is funded → release ALGO payment to claimer.
   */
  async resolveClaim(
    claimId: string,
    userId: string,
    action: "APPROVED" | "REJECTED"
  ) {
    const claim = await prisma.bountyClaim.findUnique({
      where: { id: claimId },
      include: {
        bounty: {
          select: {
            creatorId: true,
            algoAmount: true,
            escrowStatus: true,
            id: true,
            title: true,
          },
        },
        claimer: { select: { walletAddress: true } },
      },
    });

    if (!claim) throw new NotFoundError("Claim not found");
    if (claim.bounty.creatorId !== userId) {
      throw new UnauthorizedError("Only the bounty creator can resolve claims");
    }

    let paymentTxId: string | null = null;

    // If approving & there's funded escrow → release payment
    if (
      action === "APPROVED" &&
      claim.bounty.escrowStatus === "FUNDED" &&
      claim.bounty.algoAmount > 0
    ) {
      if (!claim.claimer.walletAddress) {
        throw new BadRequestError(
          "Claimer has no wallet address set — cannot release payment"
        );
      }
      try {
        const payment = await algorandService.releasePayment(
          claim.claimer.walletAddress,
          claim.bounty.algoAmount,
          claim.bounty.id
        );
        paymentTxId = payment.txId;

        // Mark escrow as released
        await prisma.bounty.update({
          where: { id: claim.bountyId },
          data: { escrowStatus: "RELEASED" },
        });

        // Record CREDIT for the claimer
        await prisma.walletTransaction.create({
          data: {
            userId: claim.claimerId,
            type: "CREDIT",
            amountAlgo: claim.bounty.algoAmount,
            txId: paymentTxId,
            bountyId: claim.bountyId,
            bountyTitle: claim.bounty.title,
            counterpartyAddress: claim.claimer.walletAddress,
            description: `Bounty reward — "${claim.bounty.title}" approved`,
          },
        });
      } catch (err: any) {
        console.error("[Escrow] Payment release failed:", err.message);
        throw new BadRequestError(
          `Escrow payment release failed: ${err.message}`
        );
      }
    }

    const updated = await prisma.bountyClaim.update({
      where: { id: claimId },
      data: {
        status: action,
        resolvedAt: new Date(),
        ...(paymentTxId && { paymentTxId }),
      },
    });

    // If approved → complete the bounty; if rejected → re-open it
    await prisma.bounty.update({
      where: { id: claim.bountyId },
      data: { status: action === "APPROVED" ? "COMPLETED" : "OPEN" },
    });

    return updated;
  }

  /**
   * Get claims for the current user (as claimer).
   */
  async myClaims(userId: string) {
    return prisma.bountyClaim.findMany({
      where: { claimerId: userId },
      select: {
        id: true,
        status: true,
        proofUrl: true,
        note: true,
        submittedAt: true,
        resolvedAt: true,
        createdAt: true,
        claimer: { select: { id: true, name: true, avatarUrl: true } },
        bounty: {
          select: {
            id: true,
            title: true,
            algoAmount: true,
            status: true,
            creator: { select: { id: true, name: true, avatarUrl: true } },
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  }
}

export const bountyService = new BountyService();
