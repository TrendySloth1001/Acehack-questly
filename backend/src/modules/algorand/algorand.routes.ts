import { Router } from "express";
import { algorandController } from "./algorand.controller";
import {
  fundBountyValidation,
  submitTxnValidation,
  verifyFundingValidation,
  balanceValidation,
  setWalletValidation,
} from "./algorand.validation";
import { validate, authenticate, asyncHandler } from "../../shared/middleware";

const router = Router();

// All algorand routes require authentication
router.use(authenticate);

// ── Escrow funding flow ─────────────────────────────────────
router.post(
  "/fund-bounty/:bountyId",
  fundBountyValidation,
  validate,
  asyncHandler(algorandController.fundBounty)
);

router.post(
  "/submit-txn",
  submitTxnValidation,
  validate,
  asyncHandler(algorandController.submitTransaction)
);

router.post(
  "/verify-funding/:bountyId",
  verifyFundingValidation,
  validate,
  asyncHandler(algorandController.verifyFunding)
);

// ── Balance & info ──────────────────────────────────────────
router.get(
  "/balance/:address",
  balanceValidation,
  validate,
  asyncHandler(algorandController.getBalance)
);

router.get(
  "/escrow-info",
  asyncHandler(algorandController.getEscrowInfo)
);

// ── Wallet management ───────────────────────────────────────
router.patch(
  "/wallet",
  setWalletValidation,
  validate,
  asyncHandler(algorandController.setWallet)
);

router.get(
  "/wallet",
  asyncHandler(algorandController.getWallet)
);

router.post(
  "/generate-wallet",
  asyncHandler(algorandController.generateWallet)
);

router.post(
  "/dispense",
  asyncHandler(algorandController.dispense)
);

// ── Transaction history ─────────────────────────────────────
router.get(
  "/transactions",
  asyncHandler(algorandController.getTransactions)
);

export default router;
