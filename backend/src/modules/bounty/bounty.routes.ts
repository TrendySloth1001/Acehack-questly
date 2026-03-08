import { Router } from "express";
import multer from "multer";
import { bountyController } from "./bounty.controller";
import {
  createBountyValidation,
  resolveClaimValidation,
  submitProofValidation,
  declaimValidation,
} from "./bounty.validation";
import { validate, authenticate, asyncHandler } from "../../shared/middleware";
import { UPLOAD } from "../../shared/constants";

const router = Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: UPLOAD.MAX_FILE_SIZE },
});

// All bounty routes require authentication
router.use(authenticate);

// ── Image upload (multiple) ─────────────────────────────────
router.post(
  "/upload-images",
  upload.array("images", 10),
  asyncHandler(bountyController.uploadImages)
);

// ── CRUD ────────────────────────────────────────────────────
router.post(
  "/",
  createBountyValidation,
  validate,
  asyncHandler(bountyController.create)
);

router.get("/", asyncHandler(bountyController.list));

// ── My claims ───────────────────────────────────────────────
router.get("/claims/mine", asyncHandler(bountyController.myClaims));

// ── Single bounty ───────────────────────────────────────────
router.get("/:id", asyncHandler(bountyController.getById));
router.patch("/:id", asyncHandler(bountyController.update));
router.delete("/:id", asyncHandler(bountyController.delete));
router.post("/:id/cancel", asyncHandler(bountyController.cancel));

// ── Claims ──────────────────────────────────────────────────
router.post("/:id/claim", asyncHandler(bountyController.claim));

router.patch(
  "/claims/:claimId/proof",
  submitProofValidation,
  validate,
  asyncHandler(bountyController.submitProof)
);

router.patch(
  "/claims/:claimId/resolve",
  resolveClaimValidation,
  validate,
  asyncHandler(bountyController.resolveClaim)
);

router.delete(
  "/claims/:claimId",
  asyncHandler(bountyController.declaim)
);

// ── Disputes ────────────────────────────────────────────────
router.post(
  "/claims/:claimId/dispute",
  asyncHandler(bountyController.raiseDispute)
);

router.patch(
  "/disputes/:disputeId/resolve",
  asyncHandler(bountyController.resolveDispute)
);

router.get(
  "/:id/disputes",
  asyncHandler(bountyController.getDisputes)
);

export default router;
