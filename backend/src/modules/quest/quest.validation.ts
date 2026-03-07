import { body, param, query } from "express-validator";

export const createQuestValidation = [
  body("title").isString().trim().isLength({ min: 1, max: 200 }),
  body("description").optional().isString().trim().isLength({ max: 2000 }),
  body("tasks").optional().isArray({ max: 50 }),
  body("tasks.*.title").optional().isString().trim().isLength({ min: 1, max: 200 }),
];

export const updateQuestValidation = [
  param("questId").isString(),
  body("title").optional().isString().trim().isLength({ min: 1, max: 200 }),
  body("description").optional().isString().trim().isLength({ max: 2000 }),
  body("status").optional().isIn(["DRAFT", "ACTIVE", "COMPLETED", "ARCHIVED"]),
];

export const questIdValidation = [param("questId").isString()];

export const listQuestValidation = [
  query("status").optional().isIn(["DRAFT", "ACTIVE", "COMPLETED", "ARCHIVED"]),
  query("search").optional().isString().trim(),
  query("page").optional().isInt({ min: 1 }),
  query("limit").optional().isInt({ min: 1, max: 100 }),
];

export const addTaskValidation = [
  param("questId").isString(),
  body("title").isString().trim().isLength({ min: 1, max: 200 }),
  body("description").optional().isString().trim().isLength({ max: 2000 }),
];

export const updateTaskValidation = [
  param("questId").isString(),
  param("taskId").isString(),
  body("title").optional().isString().trim().isLength({ min: 1, max: 200 }),
  body("description").optional().isString().trim().isLength({ max: 2000 }),
  body("isCompleted").optional().isBoolean(),
  body("order").optional().isInt({ min: 0 }),
];

export const taskIdValidation = [
  param("questId").isString(),
  param("taskId").isString(),
];
