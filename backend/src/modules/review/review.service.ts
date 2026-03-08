import { prisma } from "../../config/database";
import { NotFoundError, BadRequestError, ConflictError } from "../../shared/errors";
import { gamificationService, XP } from "../gamification/gamification.service";

export interface CreateReviewDTO {
  bountyId: string;
  revieweeId: string;
  stars: number; // 1-5
  comment?: string;
}

export class ReviewService {
  /**
   * Create a review for a completed bounty.
   * Reviewer = the opposite party (creator reviews claimer, claimer reviews creator).
   */
  async create(reviewerId: string, dto: CreateReviewDTO) {
    if (dto.stars < 1 || dto.stars > 5) {
      throw new BadRequestError("Stars must be between 1 and 5");
    }
    if (reviewerId === dto.revieweeId) {
      throw new BadRequestError("Cannot review yourself");
    }

    // Verify bounty is completed
    const bounty = await prisma.bounty.findUnique({
      where: { id: dto.bountyId },
      select: { status: true, creatorId: true, claims: { select: { claimerId: true, status: true } } },
    });
    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.status !== "COMPLETED") {
      throw new BadRequestError("Can only review completed bounties");
    }

    // Verify reviewer is involved in this bounty
    const isCreator = bounty.creatorId === reviewerId;
    const isClaimer = bounty.claims.some(
      (c) => c.claimerId === reviewerId && c.status === "APPROVED"
    );
    if (!isCreator && !isClaimer) {
      throw new BadRequestError("You must be the creator or approved claimer to review");
    }

    // Check for duplicate
    const existing = await prisma.review.findUnique({
      where: { reviewerId_bountyId: { reviewerId, bountyId: dto.bountyId } },
    });
    if (existing) throw new ConflictError("You have already reviewed this bounty");

    const review = await prisma.review.create({
      data: {
        reviewerId,
        revieweeId: dto.revieweeId,
        bountyId: dto.bountyId,
        stars: dto.stars,
        comment: dto.comment,
      },
      select: {
        id: true,
        stars: true,
        comment: true,
        createdAt: true,
        reviewer: { select: { id: true, name: true, avatarUrl: true } },
        reviewee: { select: { id: true, name: true } },
        bounty: { select: { id: true, title: true } },
      },
    });

    // Award / deduct XP based on stars
    const xpDelta = gamificationService.xpForStars(dto.stars);
    if (xpDelta !== 0) {
      await gamificationService.awardXP(dto.revieweeId, xpDelta);
    }

    // Refresh reviewee's avg rating
    await gamificationService.refreshRating(dto.revieweeId);

    return review;
  }

  /**
   * List reviews for a specific user (as reviewee).
   */
  async getForUser(userId: string) {
    return prisma.review.findMany({
      where: { revieweeId: userId },
      select: {
        id: true,
        stars: true,
        comment: true,
        createdAt: true,
        reviewer: { select: { id: true, name: true, avatarUrl: true } },
        bounty: { select: { id: true, title: true } },
      },
      orderBy: { createdAt: "desc" },
    });
  }

  /**
   * List reviews for a specific bounty.
   */
  async getForBounty(bountyId: string) {
    return prisma.review.findMany({
      where: { bountyId },
      select: {
        id: true,
        stars: true,
        comment: true,
        createdAt: true,
        reviewer: { select: { id: true, name: true, avatarUrl: true } },
        reviewee: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: "desc" },
    });
  }
}

export const reviewService = new ReviewService();
