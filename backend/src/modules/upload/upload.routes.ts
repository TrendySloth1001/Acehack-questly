import { Router } from "express";
import multer from "multer";
import { uploadController } from "./upload.controller";
import { authenticate, asyncHandler } from "../../shared/middleware";
import { UPLOAD } from "../../shared/constants";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: UPLOAD.MAX_FILE_SIZE },
});

const router = Router();

router.use(authenticate);

router.post("/", upload.single("file"), asyncHandler(uploadController.upload));
router.get("/", asyncHandler(uploadController.list));
router.get("/:uploadId/presigned", asyncHandler(uploadController.getPresignedUrl));
router.delete("/:uploadId", asyncHandler(uploadController.delete));

export default router;
