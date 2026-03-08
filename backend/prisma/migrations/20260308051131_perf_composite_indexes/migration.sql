-- CreateIndex
CREATE INDEX "bounties_status_createdAt_idx" ON "bounties"("status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "bounties_creatorId_status_idx" ON "bounties"("creatorId", "status");

-- CreateIndex
CREATE INDEX "bounty_claims_bountyId_status_idx" ON "bounty_claims"("bountyId", "status");

-- CreateIndex
CREATE INDEX "bounty_claims_claimerId_createdAt_idx" ON "bounty_claims"("claimerId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "refresh_tokens_expiresAt_idx" ON "refresh_tokens"("expiresAt");

-- CreateIndex
CREATE INDEX "wallet_transactions_userId_createdAt_idx" ON "wallet_transactions"("userId", "createdAt" DESC);
