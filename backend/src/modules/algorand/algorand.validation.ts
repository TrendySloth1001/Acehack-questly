import { body, param } from "express-validator";

export const fundBountyValidation = [
  param("bountyId").isString().notEmpty().withMessage("bountyId is required"),
  body("senderAddress")
    .isString()
    .trim()
    .isLength({ min: 58, max: 58 })
    .withMessage("Invalid Algorand address (must be 58 chars)"),
];

export const submitTxnValidation = [
  body("signedTxn")
    .isString()
    .notEmpty()
    .withMessage("signedTxn (base64) is required"),
  body("bountyId")
    .isString()
    .notEmpty()
    .withMessage("bountyId is required"),
];

export const verifyFundingValidation = [
  param("bountyId").isString().notEmpty().withMessage("bountyId is required"),
];

export const balanceValidation = [
  param("address")
    .isString()
    .isLength({ min: 58, max: 58 })
    .withMessage("Invalid Algorand address"),
];

export const setWalletValidation = [
  body("walletAddress")
    .isString()
    .trim()
    .isLength({ min: 58, max: 58 })
    .withMessage("Invalid Algorand address (must be 58 chars)"),
];
