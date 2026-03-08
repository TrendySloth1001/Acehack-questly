import { Request, Response } from "express";
import { gamificationService, getRank, levelToXp } from "./gamification.service";
import { sendSuccess } from "../../shared/utils/api-response";

export class GamificationController {
  async leaderboard(req: Request, res: Response) {
    const limit =
      typeof req.query.limit === "string" ? Number(req.query.limit) : 50;
    const users = await gamificationService.leaderboard(limit);

    const ranked = users.map((u, i) => ({
      rank: i + 1,
      ...u,
      tier: getRank(u.xp),
      nextLevelXp: levelToXp(u.level + 1),
    }));

    sendSuccess({ res, data: ranked });
  }

  async myStats(req: Request, res: Response) {
    const stats = await gamificationService.getStats(req.currentUser!.userId);
    sendSuccess({ res, data: stats });
  }

  async processDecay(req: Request, res: Response) {
    const result = await gamificationService.processDecay();
    sendSuccess({ res, data: result, message: "Decay processed" });
  }
}

export const gamificationController = new GamificationController();
