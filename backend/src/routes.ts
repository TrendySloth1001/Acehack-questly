import { Router } from "express";
import { authRoutes } from "./modules/auth";
import { questRoutes } from "./modules/quest";
import { uploadRoutes } from "./modules/upload";
import { bountyRoutes } from "./modules/bounty";

export const apiRouter = Router();

apiRouter.use("/auth", authRoutes);
apiRouter.use("/quests", questRoutes);
apiRouter.use("/uploads", uploadRoutes);
apiRouter.use("/bounties", bountyRoutes);
