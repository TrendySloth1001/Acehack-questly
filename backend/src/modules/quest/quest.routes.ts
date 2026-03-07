import { Router } from "express";
import { questController } from "./quest.controller";
import {
  createQuestValidation,
  updateQuestValidation,
  questIdValidation,
  listQuestValidation,
  addTaskValidation,
  updateTaskValidation,
  taskIdValidation,
} from "./quest.validation";
import { validate, authenticate, asyncHandler } from "../../shared/middleware";

const router = Router();

// All quest routes require auth
router.use(authenticate);

// ── Quests ──────────────────────────────────────────────────
router.post(
  "/",
  createQuestValidation,
  validate,
  asyncHandler(questController.create)
);

router.get(
  "/",
  listQuestValidation,
  validate,
  asyncHandler(questController.findAll)
);

router.get(
  "/:questId",
  questIdValidation,
  validate,
  asyncHandler(questController.findById)
);

router.patch(
  "/:questId",
  updateQuestValidation,
  validate,
  asyncHandler(questController.update)
);

router.delete(
  "/:questId",
  questIdValidation,
  validate,
  asyncHandler(questController.delete)
);

// ── Tasks (nested under quest) ──────────────────────────────
router.post(
  "/:questId/tasks",
  addTaskValidation,
  validate,
  asyncHandler(questController.addTask)
);

router.patch(
  "/:questId/tasks/:taskId",
  updateTaskValidation,
  validate,
  asyncHandler(questController.updateTask)
);

router.delete(
  "/:questId/tasks/:taskId",
  taskIdValidation,
  validate,
  asyncHandler(questController.deleteTask)
);

export default router;
