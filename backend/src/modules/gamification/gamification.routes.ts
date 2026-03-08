import { Router } from "express";
import { gamificationController } from "./gamification.controller";
import { authenticate, asyncHandler } from "../../shared/middleware";

const router = Router();

router.use(authenticate);

router.get("/leaderboard", asyncHandler(gamificationController.leaderboard));
router.get("/me", asyncHandler(gamificationController.myStats));
router.post("/decay", asyncHandler(gamificationController.processDecay));

export default router;
