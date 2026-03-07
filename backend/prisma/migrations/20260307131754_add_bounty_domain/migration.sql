-- CreateEnum
CREATE TYPE "BountyStatus" AS ENUM ('OPEN', 'CLAIMED', 'IN_REVIEW', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ClaimStatus" AS ENUM ('ACTIVE', 'SUBMITTED', 'APPROVED', 'REJECTED');

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "latitude" DOUBLE PRECISION,
ADD COLUMN     "location" TEXT,
ADD COLUMN     "longitude" DOUBLE PRECISION,
ADD COLUMN     "onboarded" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "phone" TEXT,
ADD COLUMN     "reason" TEXT,
ADD COLUMN     "skills" TEXT[] DEFAULT ARRAY[]::TEXT[];

-- CreateTable
CREATE TABLE "bounties" (
    "id" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "algoAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "deadline" TIMESTAMP(3) NOT NULL,
    "status" "BountyStatus" NOT NULL DEFAULT 'OPEN',
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "location" TEXT,
    "extraFields" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "bounties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bounty_claims" (
    "id" TEXT NOT NULL,
    "bountyId" TEXT NOT NULL,
    "claimerId" TEXT NOT NULL,
    "status" "ClaimStatus" NOT NULL DEFAULT 'ACTIVE',
    "proofUrl" TEXT,
    "note" TEXT,
    "submittedAt" TIMESTAMP(3),
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bounty_claims_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "bounties_creatorId_idx" ON "bounties"("creatorId");

-- CreateIndex
CREATE INDEX "bounties_status_idx" ON "bounties"("status");

-- CreateIndex
CREATE INDEX "bounties_deadline_idx" ON "bounties"("deadline");

-- CreateIndex
CREATE INDEX "bounty_claims_bountyId_idx" ON "bounty_claims"("bountyId");

-- CreateIndex
CREATE INDEX "bounty_claims_claimerId_idx" ON "bounty_claims"("claimerId");

-- CreateIndex
CREATE UNIQUE INDEX "bounty_claims_bountyId_claimerId_key" ON "bounty_claims"("bountyId", "claimerId");

-- AddForeignKey
ALTER TABLE "bounties" ADD CONSTRAINT "bounties_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bounty_claims" ADD CONSTRAINT "bounty_claims_bountyId_fkey" FOREIGN KEY ("bountyId") REFERENCES "bounties"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bounty_claims" ADD CONSTRAINT "bounty_claims_claimerId_fkey" FOREIGN KEY ("claimerId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
