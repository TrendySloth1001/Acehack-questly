import { Prisma } from "@prisma/client";
import { prisma } from "../../config/database";
import { NotFoundError, UnauthorizedError } from "../../shared/errors";

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
  createdAt: true,
  updatedAt: true,
  creator: {
    select: {
      id: true,
      name: true,
      avatarUrl: true,
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
            submittedAt: true,
            resolvedAt: true,
            createdAt: true,
            claimer: {
              select: { id: true, name: true, avatarUrl: true },
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
   */
  async delete(id: string, userId: string) {
    const bounty = await prisma.bounty.findUnique({
      where: { id },
      select: { creatorId: true, status: true },
    });

    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.creatorId !== userId) {
      throw new UnauthorizedError("You can only delete your own bounties");
    }
    if (bounty.status !== "OPEN") {
      throw new UnauthorizedError("Can only delete OPEN bounties");
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
   * Submit proof for a claim.
   */
  async submitProof(
    claimId: string,
    claimerId: string,
    proofUrl: string,
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
        proofUrl,
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
   * Approve or reject a claim (only bounty creator).
   */
  async resolveClaim(
    claimId: string,
    userId: string,
    action: "APPROVED" | "REJECTED"
  ) {
    const claim = await prisma.bountyClaim.findUnique({
      where: { id: claimId },
      include: { bounty: { select: { creatorId: true } } },
    });

    if (!claim) throw new NotFoundError("Claim not found");
    if (claim.bounty.creatorId !== userId) {
      throw new UnauthorizedError("Only the bounty creator can resolve claims");
    }

    const updated = await prisma.bountyClaim.update({
      where: { id: claimId },
      data: {
        status: action,
        resolvedAt: new Date(),
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
