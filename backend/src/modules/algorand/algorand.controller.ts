import { Request, Response } from "express";
import { algorandService } from "./algorand.service";
import { sendSuccess } from "../../shared/utils/api-response";
import { HTTP_STATUS } from "../../shared/constants";
import { prisma } from "../../config/database";
import { BadRequestError, NotFoundError } from "../../shared/errors";

export class AlgorandController {
  // ── POST /algorand/fund-bounty/:bountyId ──────────────────
  async fundBounty(req: Request, res: Response) {
    const bountyId = req.params.bountyId as string;
    const { senderAddress } = req.body;

    // Verify bounty exists & caller is creator
    const bounty = await prisma.bounty.findUnique({
      where: { id: bountyId },
      select: { creatorId: true, algoAmount: true, escrowStatus: true },
    });
    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.creatorId !== req.currentUser!.userId) {
      throw new BadRequestError("Only the bounty creator can fund it");
    }
    if (bounty.escrowStatus === "FUNDED") {
      throw new BadRequestError("Bounty is already funded");
    }
    if (!bounty.algoAmount || bounty.algoAmount <= 0) {
      throw new BadRequestError("Bounty has no ALGO reward set");
    }

    const result = await algorandService.createFundingTransaction(
      senderAddress as string,
      bounty.algoAmount,
      bountyId
    );

    sendSuccess({
      res,
      data: result,
      message: "Unsigned funding transaction created",
    });
  }

  // ── POST /algorand/submit-txn ─────────────────────────────
  // Receives the unsigned txn from the client, signs it server-side
  // using the caller's custodial mnemonic (root cause fix), then
  // submits to algod so the actual on-chain deduction happens.
  async submitTransaction(req: Request, res: Response) {
    const { signedTxn: unsignedTxnB64, bountyId } = req.body as {
      signedTxn: string;
      bountyId: string;
    };
    const userId = req.currentUser!.userId;

    // Look up the caller's custodial mnemonic
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { walletMnemonic: true, walletAddress: true },
    });
    if (!user?.walletMnemonic) {
      throw new BadRequestError("No wallet found — generate one first");
    }

    // Look up bounty for amount / title
    const bounty = await prisma.bounty.findUnique({
      where: { id: bountyId },
      select: { algoAmount: true, title: true, creatorId: true },
    });
    if (!bounty) throw new NotFoundError("Bounty not found");
    if (bounty.creatorId !== userId) {
      throw new BadRequestError("Only the bounty creator can fund it");
    }

    // Sign with custodial key + submit to algod (real on-chain deduction)
    const result = await algorandService.signAndSubmitTransaction(
      unsignedTxnB64,
      user.walletMnemonic
    );

    // Mark bounty as funded in DB
    await prisma.bounty.update({
      where: { id: bountyId },
      data: {
        escrowTxId: result.txId,
        escrowStatus: "FUNDED",
      },
    });

    // Record DEBIT transaction for the creator
    await prisma.walletTransaction.create({
      data: {
        userId,
        type: "DEBIT",
        amountAlgo: bounty.algoAmount,
        txId: result.txId,
        bountyId,
        bountyTitle: bounty.title,
        counterpartyAddress: user.walletAddress,
        description: `Funded escrow for "${bounty.title}"`,
      },
    });

    sendSuccess({
      res,
      data: result,
      message: "Transaction signed, submitted & bounty funded",
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  // ── POST /algorand/verify-funding/:bountyId ──────────────
  async verifyFunding(req: Request, res: Response) {
    const bountyId = req.params.bountyId as string;

    const bounty = await prisma.bounty.findUnique({
      where: { id: bountyId },
      select: { escrowTxId: true, algoAmount: true, escrowStatus: true },
    });
    if (!bounty) throw new NotFoundError("Bounty not found");
    if (!bounty.escrowTxId) {
      throw new BadRequestError("Bounty has no escrow transaction");
    }

    const verification = await algorandService.verifyFunding(
      bounty.escrowTxId,
      bounty.algoAmount
    );

    // Auto-update escrow status if verified and not already FUNDED
    if (verification.verified && bounty.escrowStatus !== "FUNDED") {
      await prisma.bounty.update({
        where: { id: bountyId },
        data: { escrowStatus: "FUNDED" },
      });
    }

    sendSuccess({
      res,
      data: { bountyId, ...verification },
    });
  }

  // ── GET /algorand/balance/:address ────────────────────────
  async getBalance(req: Request, res: Response) {
    const balance = await algorandService.getBalance(req.params.address as string);
    sendSuccess({ res, data: balance });
  }

  // ── GET /algorand/escrow-info ─────────────────────────────
  async getEscrowInfo(_req: Request, res: Response) {
    const info = await algorandService.getEscrowInfo();
    sendSuccess({ res, data: info });
  }

  // ── PATCH /algorand/wallet ────────────────────────────────
  async setWallet(req: Request, res: Response) {
    const { walletAddress } = req.body;

    if (!algorandService.isValidAddress(walletAddress)) {
      throw new BadRequestError("Invalid Algorand wallet address");
    }

    const user = await prisma.user.update({
      where: { id: req.currentUser!.userId },
      data: { walletAddress },
      select: { id: true, name: true, walletAddress: true },
    });

    sendSuccess({ res, data: user, message: "Wallet address saved" });
  }

  // ── GET /algorand/wallet ──────────────────────────────────
  async getWallet(req: Request, res: Response) {
    const user = await prisma.user.findUnique({
      where: { id: req.currentUser!.userId },
      select: { walletAddress: true },
    });

    sendSuccess({ res, data: { walletAddress: user?.walletAddress ?? null } });
  }

  // ── POST /algorand/generate-wallet ────────────────────────
  // Auto-generates a custodial wallet for the logged in user.
  // If the user already has a wallet, returns the existing one.
  async generateWallet(req: Request, res: Response) {
    const userId = req.currentUser!.userId;

    // Check if user already has a wallet
    const existing = await prisma.user.findUnique({
      where: { id: userId },
      select: { walletAddress: true, walletMnemonic: true },
    });

    if (existing?.walletAddress && existing?.walletMnemonic) {
      // Already has a wallet — just return it
      let balance = null;
      try {
        balance = await algorandService.getBalance(existing.walletAddress);
      } catch (_) {}
      sendSuccess({
        res,
        data: {
          walletAddress: existing.walletAddress,
          isNew: false,
          balance,
        },
        message: "Wallet already exists",
      });
      return;
    }

    // Generate new wallet
    const { address, mnemonic } = algorandService.generateWallet();

    // Store on user record
    await prisma.user.update({
      where: { id: userId },
      data: { walletAddress: address, walletMnemonic: mnemonic },
    });

    sendSuccess({
      res,
      data: {
        walletAddress: address,
        isNew: true,
        balance: { balanceAlgo: 0, balanceMicroAlgo: 0, minBalance: 0.1 },
      },
      message: "Wallet generated successfully",
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  // ── POST /algorand/dispense ───────────────────────────────
  // Local faucet — sends ALGO from the devmode genesis to user.
  async dispense(req: Request, res: Response) {
    const userId = req.currentUser!.userId;
    const { amount } = req.body as { amount?: number };
    const amountAlgo = amount ?? 10;

    // Get user’s wallet address
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { walletAddress: true },
    });

    if (!user?.walletAddress) {
      throw new BadRequestError("Generate a wallet first");
    }

    const result = await algorandService.dispense(
      user.walletAddress,
      amountAlgo
    );

    // Return updated balance
    let balance = null;
    try {
      balance = await algorandService.getBalance(user.walletAddress);
    } catch (_) {}

    sendSuccess({
      res,
      data: { ...result, balance },
      message: `Dispensed ${amountAlgo} ALGO to your wallet`,
      statusCode: HTTP_STATUS.CREATED,
    });
  }
}

export const algorandController = new AlgorandController();
