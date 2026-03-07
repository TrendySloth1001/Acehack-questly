import algosdk from "algosdk";
import { algodClient, kmdClient, getEscrowAccount, getEscrowAddress } from "../../config";
import { BadRequestError } from "../../shared/errors";

// ═════════════════════════════════════════════════════════════
//  Algorand Service — escrow management, payments, verification
// ═════════════════════════════════════════════════════════════

const MICROALGOS_PER_ALGO = 1_000_000;
const MIN_TXN_FEE = 1000; // 0.001 ALGO minimum fee

export class AlgorandService {
  // ── Create unsigned funding txn (creator → escrow) ────────

  async createFundingTransaction(
    senderAddress: string,
    amountAlgo: number,
    bountyId: string
  ) {
    if (!algosdk.isValidAddress(senderAddress)) {
      throw new BadRequestError("Invalid Algorand wallet address");
    }
    if (amountAlgo <= 0) {
      throw new BadRequestError("Amount must be greater than 0");
    }

    const params = await algodClient.getTransactionParams().do();
    const amountMicroAlgo = Math.floor(amountAlgo * MICROALGOS_PER_ALGO);
    const note = new TextEncoder().encode(
      JSON.stringify({ app: "questly", action: "fund", bountyId })
    );

    const txn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
      sender: senderAddress,
      receiver: getEscrowAddress(),
      amount: amountMicroAlgo,
      note,
      suggestedParams: params,
    });

    // Encode unsigned transaction for transport
    const unsignedBytes = algosdk.encodeUnsignedTransaction(txn);
    const unsignedTxnB64 = Buffer.from(unsignedBytes).toString("base64");

    return {
      unsignedTxn: unsignedTxnB64,
      txnId: txn.txID(),
      escrowAddress: getEscrowAddress(),
      amountMicroAlgo,
      amountAlgo,
    };
  }

  // ── Submit a signed transaction to the network ────────────

  async submitSignedTransaction(signedTxnB64: string) {
    const signedBytes = new Uint8Array(
      Buffer.from(signedTxnB64, "base64")
    );

    const { txid } = await algodClient
      .sendRawTransaction(signedBytes)
      .do();

    // Wait for confirmation (up to 5 rounds)
    const confirmedTxn = await algosdk.waitForConfirmation(
      algodClient,
      txid,
      5
    );

    return {
      txId: txid,
      confirmedRound: Number(confirmedTxn.confirmedRound ?? 0),
    };
  }

  // ── Sign an unsigned txn with a mnemonic, then submit ─────
  // This is the custodial flow: server holds the mnemonic.

  async signAndSubmitTransaction(unsignedTxnB64: string, mnemonic: string) {
    const unsignedBytes = new Uint8Array(
      Buffer.from(unsignedTxnB64, "base64")
    );

    // Decode the unsigned transaction object
    const txn = algosdk.decodeUnsignedTransaction(unsignedBytes);

    // Recover the account from the stored mnemonic
    const account = algosdk.mnemonicToSecretKey(mnemonic);

    // Sign it
    const signedBytes = txn.signTxn(account.sk);

    // Submit to algod
    const { txid } = await algodClient.sendRawTransaction(signedBytes).do();

    // Wait for confirmation
    const confirmed = await algosdk.waitForConfirmation(algodClient, txid, 5);

    return {
      txId: txid,
      confirmedRound: Number(confirmed.confirmedRound ?? 0),
    };
  }

  // ── Verify a funding transaction on-chain ─────────────────

  async verifyFunding(
    txId: string,
    expectedAmountAlgo: number
  ): Promise<{
    verified: boolean;
    senderAddress: string;
    amountAlgo: number;
    confirmedRound: number;
  }> {
    try {
      const txnInfo = await algodClient
        .pendingTransactionInformation(txId)
        .do();

      const confirmedRound = Number(txnInfo.confirmedRound ?? 0);
      if (!confirmedRound) {
        return {
          verified: false,
          senderAddress: "",
          amountAlgo: 0,
          confirmedRound: 0,
        };
      }

      // Access the inner transaction via typed SignedTransaction
      const innerTxn = txnInfo.txn.txn;
      const paymentFields = innerTxn.payment;
      const receiverStr = paymentFields?.receiver?.toString() ?? "";
      const actualAmount = Number(paymentFields?.amount ?? 0n);
      const senderStr = innerTxn.sender?.toString() ?? "";

      const expectedMicro = Math.floor(
        expectedAmountAlgo * MICROALGOS_PER_ALGO
      );

      const isCorrectReceiver = receiverStr === getEscrowAddress();
      const isCorrectAmount = actualAmount >= expectedMicro;

      return {
        verified: isCorrectReceiver && isCorrectAmount && confirmedRound > 0,
        senderAddress: senderStr,
        amountAlgo: actualAmount / MICROALGOS_PER_ALGO,
        confirmedRound,
      };
    } catch (err: any) {
      console.error("[Algorand] verification error:", err.message ?? err);
      return {
        verified: false,
        senderAddress: "",
        amountAlgo: 0,
        confirmedRound: 0,
      };
    }
  }

  // ── Release payment from escrow to claimer ────────────────

  async releasePayment(
    claimerAddress: string,
    amountAlgo: number,
    bountyId: string
  ): Promise<{ txId: string; confirmedRound: number }> {
    if (!algosdk.isValidAddress(claimerAddress)) {
      throw new BadRequestError("Claimer wallet address is invalid");
    }

    const escrow = getEscrowAccount();
    const params = await algodClient.getTransactionParams().do();
    const amountMicroAlgo = Math.floor(amountAlgo * MICROALGOS_PER_ALGO);
    const note = new TextEncoder().encode(
      JSON.stringify({ app: "questly", action: "release", bountyId })
    );

    const txn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
      sender: getEscrowAddress(),
      receiver: claimerAddress,
      amount: amountMicroAlgo,
      note,
      suggestedParams: params,
    });

    const signedTxn = txn.signTxn(escrow.sk);
    const { txid } = await algodClient.sendRawTransaction(signedTxn).do();
    const confirmed = await algosdk.waitForConfirmation(algodClient, txid, 5);

    return {
      txId: txid,
      confirmedRound: Number(confirmed.confirmedRound ?? 0),
    };
  }

  // ── Refund creator from escrow ────────────────────────────

  async refundCreator(
    creatorAddress: string,
    amountAlgo: number,
    bountyId: string
  ): Promise<{ txId: string; confirmedRound: number }> {
    if (!algosdk.isValidAddress(creatorAddress)) {
      throw new BadRequestError("Creator wallet address is invalid");
    }

    const escrow = getEscrowAccount();
    const params = await algodClient.getTransactionParams().do();
    // Subtract min fee so escrow doesn't go below min balance
    const amountMicroAlgo =
      Math.floor(amountAlgo * MICROALGOS_PER_ALGO) - MIN_TXN_FEE;
    if (amountMicroAlgo <= 0) {
      throw new BadRequestError("Amount too small to refund after fees");
    }
    const note = new TextEncoder().encode(
      JSON.stringify({ app: "questly", action: "refund", bountyId })
    );

    const txn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
      sender: getEscrowAddress(),
      receiver: creatorAddress,
      amount: amountMicroAlgo,
      note,
      suggestedParams: params,
    });

    const signedTxn = txn.signTxn(escrow.sk);
    const { txid } = await algodClient.sendRawTransaction(signedTxn).do();
    const confirmed = await algosdk.waitForConfirmation(algodClient, txid, 5);

    return {
      txId: txid,
      confirmedRound: Number(confirmed.confirmedRound ?? 0),
    };
  }

  // ── Get wallet balance ────────────────────────────────────

  async getBalance(address: string): Promise<{
    balanceAlgo: number;
    balanceMicroAlgo: number;
    minBalance: number;
  }> {
    if (!algosdk.isValidAddress(address)) {
      throw new BadRequestError("Invalid Algorand address");
    }

    const info = await algodClient.accountInformation(address).do();
    const balanceMicro = Number(info.amount ?? 0n);
    const minBalanceMicro = Number(info.minBalance ?? 100000n);

    return {
      balanceAlgo: balanceMicro / MICROALGOS_PER_ALGO,
      balanceMicroAlgo: balanceMicro,
      minBalance: minBalanceMicro / MICROALGOS_PER_ALGO,
    };
  }

  // ── Get escrow info ───────────────────────────────────────

  async getEscrowInfo() {
    const address = getEscrowAddress();
    const balance = await this.getBalance(address).catch(() => ({
      balanceAlgo: 0,
      balanceMicroAlgo: 0,
      minBalance: 0.1,
    }));

    return {
      address,
      ...balance,
      network: process.env.ALGORAND_NETWORK ?? "testnet",
    };
  }

  // ── Generate a brand-new Algorand keypair ──────────────────

  generateWallet(): { address: string; mnemonic: string } {
    const account = algosdk.generateAccount();
    const mnemonic = algosdk.secretKeyToMnemonic(account.sk);
    return {
      address: account.addr.toString(),
      mnemonic,
    };
  }

  // ── Recover account from mnemonic ─────────────────────────

  recoverAccount(mnemonic: string) {
    return algosdk.mnemonicToSecretKey(mnemonic);
  }

  // ── Validate an Algorand address ──────────────────────────

  isValidAddress(address: string): boolean {
    return algosdk.isValidAddress(address);
  }

  // ── Local faucet — dispense ALGO from genesis account ─────
  // Works only with local devmode algod + KMD running.

  async dispense(
    recipientAddress: string,
    amountAlgo: number = 10
  ): Promise<{ txId: string; amountAlgo: number }> {
    if (!algosdk.isValidAddress(recipientAddress)) {
      throw new BadRequestError("Invalid recipient address");
    }
    if (amountAlgo <= 0 || amountAlgo > 1000) {
      throw new BadRequestError("Amount must be between 0 and 1000 ALGO");
    }

    // 1. Get the default wallet from KMD (holds genesis account)
    const walletsResp = await kmdClient.listWallets();
    const defaultWallet = walletsResp.wallets.find(
      (w: any) => w.name === "unencrypted-default-wallet"
    );
    if (!defaultWallet) {
      throw new BadRequestError(
        "KMD default wallet not found — is algod running in devmode?"
      );
    }

    // 2. Get a wallet handle
    const handleResp = await kmdClient.initWalletHandle(
      defaultWallet.id,
      ""
    );
    const handle = handleResp.wallet_handle_token;

    try {
      // 3. Get the genesis address (first key in the wallet)
      const keysResp = await kmdClient.listKeys(handle);
      const genesisAddr = keysResp.addresses[0];
      if (!genesisAddr) {
        throw new BadRequestError("No genesis address found in KMD");
      }

      // 4. Build payment transaction
      const params = await algodClient.getTransactionParams().do();
      const amountMicroAlgo = Math.floor(amountAlgo * MICROALGOS_PER_ALGO);

      const txn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
        sender: genesisAddr,
        receiver: recipientAddress,
        amount: amountMicroAlgo,
        note: new TextEncoder().encode(
          JSON.stringify({ app: "questly", action: "dispense" })
        ),
        suggestedParams: params,
      });

      // 5. Sign via KMD (genesis key never leaves the daemon)
      const signedTxnBytes = await kmdClient.signTransaction(
        handle,
        "",
        txn
      );

      // 6. Submit to network
      const { txid } = await algodClient
        .sendRawTransaction(signedTxnBytes)
        .do();

      // 7. Wait for confirmation (devmode = instant)
      await algosdk.waitForConfirmation(algodClient, txid, 5);

      return { txId: txid, amountAlgo };
    } finally {
      // Release the wallet handle
      await kmdClient.releaseWalletHandle(handle).catch(() => {});
    }
  }
}

export const algorandService = new AlgorandService();
