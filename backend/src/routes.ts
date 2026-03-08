import { Router } from "express";
import { authRoutes } from "./modules/auth";
import { questRoutes } from "./modules/quest";
import { uploadRoutes } from "./modules/upload";
import { bountyRoutes } from "./modules/bounty";
import { algorandRoutes } from "./modules/algorand";
import { reviewRoutes } from "./modules/review";
import { gamificationRoutes } from "./modules/gamification";

export const apiRouter = Router();

apiRouter.use("/auth", authRoutes);
apiRouter.use("/quests", questRoutes);
apiRouter.use("/uploads", uploadRoutes);
apiRouter.use("/bounties", bountyRoutes);
apiRouter.use("/algorand", algorandRoutes);
apiRouter.use("/reviews", reviewRoutes);
apiRouter.use("/gamification", gamificationRoutes);
