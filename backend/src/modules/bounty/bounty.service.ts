import { Prisma } from "@prisma/client";
import { prisma } from "../../config/database";
import { NotFoundError, UnauthorizedError, BadRequestError } from "../../shared/errors";
import { algorandService } from "../algorand/algorand.service";
import { gamificationService, XP } from "../gamification/gamification.service";

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
    const bounty = await prisma.bounty.create({
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

    // +20 XP for posting a bounty
    await gamificationService.awardXP(creatorId, XP.POST_BOUNTY);

    return bounty;
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
        // Atomic: update escrow status + record CREDIT together
        await prisma.$transaction([
          prisma.bounty.update({
            where: { id },
            data: { refundTxId: refund.txId, escrowStatus: "REFUNDED" },
          }),
          prisma.walletTransaction.create({
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
          }),
        ]);
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
   * Cancel a bounty and refund escrowed ALGO if applicable.
   * Unlike delete(), this keeps the bounty record (status → CANCELLED).
   * Works for OPEN bounties (with or without claims).
   */
  async cancel(id: string, userId: string) {
    const bounty = await prisma.bounty.findUnique({
      where: { id },
      select: {
        creatorId: true,
        status: true,
        algoAmount: true,
        escrowStatus: true,
        title: true,
        creator: { select: { walletAddress: true } },
        claims: { select: { id: true, status: true } },
      },
    });

    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.creatorId !== userId) {
      throw new UnauthorizedError("You can only cancel your own bounties");
    }
    if (bounty.status !== "OPEN") {
      throw new BadRequestError("Can only cancel OPEN bounties");
    }

    // Refund escrowed ALGO if funded
    let refundTxId: string | null = null;
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
        refundTxId = refund.txId;
      } catch (err: any) {
        console.error("[Escrow] Refund on cancel failed:", err.message);
        throw new BadRequestError(
          `Escrow refund failed: ${err.message}. Bounty not cancelled.`
        );
      }
    }

    // Reject all pending claims
    const pendingClaims = bounty.claims.filter(
      (c) => c.status === "ACTIVE" || c.status === "SUBMITTED"
    );

    const operations: any[] = [
      // Mark bounty cancelled
      prisma.bounty.update({
        where: { id },
        data: {
          status: "CANCELLED",
          ...(refundTxId
            ? { refundTxId, escrowStatus: "REFUNDED" }
            : {}),
        },
      }),
      // Reject all pending claims
      ...pendingClaims.map((c) =>
        prisma.bountyClaim.update({
          where: { id: c.id },
          data: { status: "REJECTED" },
        })
      ),
    ];

    // Record refund transaction if applicable
    if (refundTxId) {
      operations.push(
        prisma.walletTransaction.create({
          data: {
            userId,
            type: "CREDIT",
            amountAlgo: bounty.algoAmount,
            txId: refundTxId,
            bountyId: id,
            bountyTitle: bounty.title,
            counterpartyAddress: bounty.creator.walletAddress!,
            description: `Escrow refunded — "${bounty.title}" cancelled`,
          },
        })
      );
    }

    await prisma.$transaction(operations);

    // -20 XP if cancelled after someone claimed
    if (pendingClaims.length > 0) {
      await gamificationService.awardXP(userId, XP.CANCEL_AFTER_CLAIM);
    }

    return { refundTxId, refunded: !!refundTxId };
  }

  /**
   * Claim a bounty.
   */
  async claim(bountyId: string, claimerId: string) {
    const bounty = await prisma.bounty.findUnique({
      where: { id: bountyId },
      select: { creatorId: true, status: true, deadline: true },
    });

    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.status !== "OPEN") {
      throw new UnauthorizedError("Bounty is not open for claims");
    }
    if (bounty.deadline && new Date(bounty.deadline) < new Date()) {
      throw new BadRequestError("This bounty has passed its deadline");
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
    if (claim.status !== "ACTIVE" && claim.status !== "REJECTED") {
      throw new UnauthorizedError("Claim cannot be resubmitted in its current state");
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

    // +10 XP for submitting proof
    await gamificationService.awardXP(claimerId, XP.SUBMIT_PROOF);

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
    // Guard: if escrow isn't funded, block approval so money is never silently lost
    if (action === "APPROVED" && claim.bounty.algoAmount > 0) {
      if (claim.bounty.escrowStatus !== "FUNDED") {
        throw new BadRequestError(
          `Cannot approve: the bounty escrow is "${claim.bounty.escrowStatus}". ` +
          `You must fund the escrow first from the bounty page before approving a claim.`
        );
      }
      if (!claim.claimer.walletAddress) {
        throw new BadRequestError(
          "Claimer has no wallet address set — cannot release payment"
        );
      }
    }

    if (
      action === "APPROVED" &&
      claim.bounty.escrowStatus === "FUNDED" &&
      claim.bounty.algoAmount > 0
    ) {
      // Note: walletAddress + escrow FUNDED already verified by guard above
      try {
        const payment = await algorandService.releasePayment(
          claim.claimer.walletAddress!, // guarded above: null check already threw
          claim.bounty.algoAmount,
          claim.bounty.id
        );
        paymentTxId = payment.txId;

        // Atomic: mark escrow released + record CREDIT in one transaction
        // so a partial DB failure never leaves the history in an inconsistent state
        await prisma.$transaction([
          prisma.bounty.update({
            where: { id: claim.bountyId },
            data: { escrowStatus: "RELEASED" },
          }),
          prisma.walletTransaction.create({
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
          }),
        ]);
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

    // If approved → complete the bounty; if rejected → re-open for resubmission
    // When rejected, set bounty to CLAIMED (claimer still attached) so they can resubmit.
    await prisma.bounty.update({
      where: { id: claim.bountyId },
      data: { status: action === "APPROVED" ? "COMPLETED" : "CLAIMED" },
    });

    // +100 XP for the claimer when their work is approved
    if (action === "APPROVED") {
      await gamificationService.awardXP(claim.claimerId, XP.COMPLETE_BOUNTY);
    }

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

  // ── Dispute Methods ─────────────────────────────────────────

  /**
   * Raise a dispute on a rejected claim.
   */
  async raiseDispute(claimId: string, userId: string, reason: string) {
    const claim = await prisma.bountyClaim.findUnique({
      where: { id: claimId },
      select: { claimerId: true, status: true, bountyId: true },
    });

    if (!claim) throw new NotFoundError("Claim not found");
    if (claim.claimerId !== userId) {
      throw new UnauthorizedError("Only the claimer can raise a dispute");
    }
    if (claim.status !== "REJECTED") {
      throw new BadRequestError("Can only dispute rejected claims");
    }

    // Check for existing open dispute
    const existing = await prisma.dispute.findFirst({
      where: { claimId, status: "OPEN" },
    });
    if (existing) throw new BadRequestError("An open dispute already exists for this claim");

    return prisma.dispute.create({
      data: {
        claimId,
        raisedById: userId,
        reason,
      },
      select: {
        id: true,
        reason: true,
        status: true,
        createdAt: true,
        claim: {
          select: {
            id: true,
            bountyId: true,
            bounty: { select: { id: true, title: true } },
          },
        },
      },
    });
  }

  /**
   * Resolve a dispute (admin or bounty creator).
   */
  async resolveDispute(
    disputeId: string,
    userId: string,
    action: "RESOLVED" | "DISMISSED",
    resolution?: string
  ) {
    const dispute = await prisma.dispute.findUnique({
      where: { id: disputeId },
      include: {
        claim: {
          include: {
            bounty: { select: { creatorId: true, id: true } },
          },
        },
      },
    });

    if (!dispute) throw new NotFoundError("Dispute not found");
    if (dispute.status !== "OPEN") {
      throw new BadRequestError("Dispute is already resolved");
    }

    // Only bounty creator or admin can resolve
    if (dispute.claim.bounty.creatorId !== userId) {
      throw new UnauthorizedError("Only the bounty creator can resolve disputes");
    }

    const updated = await prisma.dispute.update({
      where: { id: disputeId },
      data: {
        status: action,
        resolution,
        resolvedAt: new Date(),
      },
    });

    // If resolved in favour of claimer → re-open claim for resubmission
    if (action === "RESOLVED") {
      await prisma.bountyClaim.update({
        where: { id: dispute.claimId },
        data: { status: "ACTIVE" },
      });
      await prisma.bounty.update({
        where: { id: dispute.claim.bountyId },
        data: { status: "CLAIMED" },
      });
    }

    return updated;
  }

  /**
   * Get disputes for a bounty (via its claims).
   */
  async getDisputes(bountyId: string) {
    return prisma.dispute.findMany({
      where: { claim: { bountyId } },
      select: {
        id: true,
        reason: true,
        status: true,
        resolution: true,
        resolvedAt: true,
        createdAt: true,
        raisedBy: { select: { id: true, name: true, avatarUrl: true } },
        claim: { select: { id: true, status: true } },
      },
      orderBy: { createdAt: "desc" },
    });
  }
}

export const bountyService = new BountyService();
