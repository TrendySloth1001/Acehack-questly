import algosdk from "algosdk";
import { env } from "./env";

// ── Parse host + port from a URL string ───────────────────────
function parseHostPort(url: string): { host: string; port: number | string } {
  const u = new URL(url);
  return { host: `${u.protocol}//${u.hostname}`, port: u.port ? Number(u.port) : "" };
}

// ── Algorand Client (local devmode node or public AlgoNode) ─
const algod = parseHostPort(env.ALGORAND_API_URL);
export const algodClient = new algosdk.Algodv2(
  env.ALGORAND_API_TOKEN,
  algod.host,
  algod.port
);

// ── KMD Client (local devmode only — manages genesis keys) ──
const kmdParsed = parseHostPort(env.ALGORAND_KMD_URL);
export const kmdClient = new algosdk.Kmd(
  env.ALGORAND_KMD_TOKEN,
  kmdParsed.host,
  kmdParsed.port
);

// ── Escrow Account ──────────────────────────────────────────

let _escrowAccount: algosdk.Account | null = null;

export function getEscrowAccount(): algosdk.Account {
  if (!_escrowAccount) {
    if (!env.ALGORAND_ESCROW_MNEMONIC) {
      throw new Error("ALGORAND_ESCROW_MNEMONIC is not set");
    }
    _escrowAccount = algosdk.mnemonicToSecretKey(env.ALGORAND_ESCROW_MNEMONIC);
  }
  return _escrowAccount;
}

export function getEscrowAddress(): string {
  return getEscrowAccount().addr.toString();
}
