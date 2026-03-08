import { prisma } from "../../config/database";

// ── Rank tiers (Minecraft-themed) ───────────────────────────

export type RankTier =
  | "WOOD"
  | "STONE"
  | "IRON"
  | "GOLD"
  | "DIAMOND"
  | "NETHERITE";

interface RankInfo {
  tier: RankTier;
  minXp: number;
  minLevel: number;
}

const RANK_TABLE: RankInfo[] = [
  { tier: "NETHERITE", minXp: 25_000, minLevel: 50 },
  { tier: "DIAMOND", minXp: 10_000, minLevel: 35 },
  { tier: "GOLD", minXp: 4_000, minLevel: 20 },
  { tier: "IRON", minXp: 1_500, minLevel: 10 },
  { tier: "STONE", minXp: 500, minLevel: 5 },
  { tier: "WOOD", minXp: 0, minLevel: 0 },
];

// ── XP constants ────────────────────────────────────────────

export const XP = {
  COMPLETE_BOUNTY: 100,
  POST_BOUNTY: 20,
  SUBMIT_PROOF: 10,
  REVIEW_5_STAR: 50,
  REVIEW_4_STAR: 25,
  DAILY_STREAK: 5,
  INACTIVE_DECAY: -10, // per day inactive (3+ days)
  REVIEW_1_STAR: -30,
  REVIEW_2_STAR: -15,
  CANCEL_AFTER_CLAIM: -20,
} as const;

// ── Helpers ─────────────────────────────────────────────────

/** Convert XP → level using sqrt curve: level = floor(sqrt(xp / 25)) */
function xpToLevel(xp: number): number {
  if (xp <= 0) return 0;
  return Math.floor(Math.sqrt(xp / 25));
}

/** XP required for a given level */
export function levelToXp(level: number): number {
  return level * level * 25;
}

/** Determine rank tier from XP */
export function getRank(xp: number): RankTier {
  for (const r of RANK_TABLE) {
    if (xp >= r.minXp) return r.tier;
  }
  return "WOOD";
}

// ── Service ─────────────────────────────────────────────────

export class GamificationService {
  /**
   * Award XP to a user, recalculate level, and touch lastActiveAt.
   * Returns the updated user fields.
   */
  async awardXP(userId: string, amount: number) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { xp: true },
    });
    if (!user) return null;

    const newXp = Math.max(0, user.xp + amount); // never go below 0
    const newLevel = xpToLevel(newXp);

    return prisma.user.update({
      where: { id: userId },
      data: {
        xp: newXp,
        level: newLevel,
        lastActiveAt: new Date(),
      },
      select: { id: true, xp: true, level: true },
    });
  }

  /**
   * Recalculate avgRating / totalReviews for a reviewee.
   */
  async refreshRating(userId: string) {
    const agg = await prisma.review.aggregate({
      where: { revieweeId: userId },
      _avg: { stars: true },
      _count: true,
    });

    return prisma.user.update({
      where: { id: userId },
      data: {
        avgRating: agg._avg.stars ?? null,
        totalReviews: agg._count,
      },
    });
  }

  /**
   * XP award based on review stars for the reviewee.
   */
  xpForStars(stars: number): number {
    switch (stars) {
      case 5:
        return XP.REVIEW_5_STAR;
      case 4:
        return XP.REVIEW_4_STAR;
      case 3:
        return 0;
      case 2:
        return XP.REVIEW_2_STAR;
      case 1:
        return XP.REVIEW_1_STAR;
      default:
        return 0;
    }
  }

  /**
   * Process daily inactivity XP decay for all users
   * who haven't been active in >= 3 days.
   * Call from a cron or manual trigger.
   */
  async processDecay() {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);

    const inactive = await prisma.user.findMany({
      where: {
        xp: { gt: 0 },
        lastActiveAt: { lt: threeDaysAgo },
      },
      select: { id: true, xp: true },
    });

    const updates = inactive.map((u) => {
      const newXp = Math.max(0, u.xp + XP.INACTIVE_DECAY);
      return prisma.user.update({
        where: { id: u.id },
        data: { xp: newXp, level: xpToLevel(newXp) },
      });
    });

    await prisma.$transaction(updates);
    return { processed: inactive.length };
  }

  /**
   * Leaderboard — top users by XP.
   */
  async leaderboard(limit = 50) {
    return prisma.user.findMany({
      where: { xp: { gt: 0 } },
      orderBy: { xp: "desc" },
      take: limit,
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        xp: true,
        level: true,
        avgRating: true,
        totalReviews: true,
      },
    });
  }

  /**
   * Get gamification stats for a single user.
   */
  async getStats(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        xp: true,
        level: true,
        avgRating: true,
        totalReviews: true,
        lastActiveAt: true,
      },
    });
    if (!user) return null;

    const rank = getRank(user.xp);
    const nextLevel = user.level + 1;
    const xpForNext = levelToXp(nextLevel);

    return {
      ...user,
      rank,
      nextLevelXp: xpForNext,
    };
  }
}

export const gamificationService = new GamificationService();
