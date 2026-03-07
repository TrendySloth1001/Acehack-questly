import { body } from "express-validator";

export const registerValidation = [
  body("email").isEmail().normalizeEmail().withMessage("Valid email is required"),
  body("password")
    .isLength({ min: 8 })
    .withMessage("Password must be at least 8 characters"),
  body("name").optional().isString().trim().isLength({ max: 100 }),
];

export const loginValidation = [
  body("email").isEmail().normalizeEmail().withMessage("Valid email is required"),
  body("password").notEmpty().withMessage("Password is required"),
];

export const refreshValidation = [
  body("refreshToken").notEmpty().withMessage("Refresh token is required"),
];
