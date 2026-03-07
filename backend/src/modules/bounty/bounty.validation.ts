import { body } from "express-validator";

export const createBountyValidation = [
  body("title")
    .isString()
    .trim()
    .isLength({ min: 3, max: 200 })
    .withMessage("Title must be 3-200 characters"),
  body("description")
    .isString()
    .trim()
    .isLength({ min: 10, max: 5000 })
    .withMessage("Description must be 10-5000 characters"),
  body("category")
    .isString()
    .trim()
    .notEmpty()
    .withMessage("Category is required"),
  body("deadline")
    .isISO8601()
    .withMessage("Deadline must be a valid date"),
  body("algoAmount")
    .optional()
    .isFloat({ min: 0 })
    .withMessage("Algo amount must be >= 0"),
  body("latitude")
    .optional()
    .isFloat({ min: -90, max: 90 }),
  body("longitude")
    .optional()
    .isFloat({ min: -180, max: 180 }),
  body("location")
    .optional()
    .isString()
    .trim(),
  body("extraFields")
    .optional()
    .isObject()
    .withMessage("Extra fields must be an object"),
  body("imageUrls")
    .optional()
    .isArray({ max: 5 })
    .withMessage("imageUrls must be an array (max 5)"),
  body("imageUrls.*")
    .optional()
    .isString()
    .isURL({ require_tld: false })
    .withMessage("Each imageUrl must be a valid URL"),
];

export const resolveClaimValidation = [
  body("action")
    .isIn(["APPROVED", "REJECTED"])
    .withMessage("Action must be APPROVED or REJECTED"),
];

export const submitProofValidation = [
  body("proofUrls")
    .isArray({ min: 1, max: 10 })
    .withMessage("proofUrls must be an array with 1-10 items"),
  body("proofUrls.*")
    .isString()
    .isURL({ require_tld: false })
    .withMessage("Each proof URL must be a valid URL"),
  body("note")
    .optional()
    .isString()
    .trim(),
];

export const declaimValidation: never[] = [];
