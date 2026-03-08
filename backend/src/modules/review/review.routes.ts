import { Router } from "express";
import { reviewController } from "./review.controller";
import { authenticate, asyncHandler } from "../../shared/middleware";

const router = Router();

router.use(authenticate);

router.post("/", asyncHandler(reviewController.create));
router.get("/user/:userId", asyncHandler(reviewController.getForUser));
router.get("/bounty/:bountyId", asyncHandler(reviewController.getForBounty));

export default router;
