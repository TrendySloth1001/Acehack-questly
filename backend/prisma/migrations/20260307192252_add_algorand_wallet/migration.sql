-- CreateEnum
CREATE TYPE "EscrowStatus" AS ENUM ('UNFUNDED', 'FUNDED', 'RELEASED', 'REFUNDED');

-- AlterTable
ALTER TABLE "bounties" ADD COLUMN     "escrowStatus" "EscrowStatus" NOT NULL DEFAULT 'UNFUNDED',
ADD COLUMN     "escrowTxId" TEXT,
ADD COLUMN     "refundTxId" TEXT;

-- AlterTable
ALTER TABLE "bounty_claims" ADD COLUMN     "paymentTxId" TEXT;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "walletAddress" TEXT,
ADD COLUMN     "walletMnemonic" TEXT;
