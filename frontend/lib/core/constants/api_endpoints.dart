/// API endpoint constants.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String googleAuth = '/auth/google';

  // ── Quests ────────────────────────────────────────────────
  static const String quests = '/quests';
  static String questById(String id) => '/quests/$id';
  static String questTasks(String questId) => '/quests/$questId/tasks';
  static String questTaskById(String questId, String taskId) =>
      '/quests/$questId/tasks/$taskId';

  // ── Uploads ───────────────────────────────────────────────
  static const String uploads = '/uploads';
  static String uploadPresigned(String id) => '/uploads/$id/presigned';
  static String uploadById(String id) => '/uploads/$id';

  // ── Bounties ──────────────────────────────────────────────
  static const String bounties = '/bounties';
  static const String bountyUploadImages = '/bounties/upload-images';
  static String bountyById(String id) => '/bounties/$id';
  static String cancelBounty(String id) => '/bounties/$id/cancel';
  static String claimBounty(String id) => '/bounties/$id/claim';
  static String acceptRequest(String claimId) =>
      '/bounties/claims/$claimId/accept';
  static String rejectRequest(String claimId) =>
      '/bounties/claims/$claimId/reject';
  static const String myClaims = '/bounties/claims/mine';
  static String submitProof(String claimId) =>
      '/bounties/claims/$claimId/proof';
  static String resolveClaim(String claimId) =>
      '/bounties/claims/$claimId/resolve';
  static String declaim(String claimId) => '/bounties/claims/$claimId';

  // ── Disputes ──────────────────────────────────────────────
  static String raiseDispute(String claimId) =>
      '/bounties/claims/$claimId/dispute';
  static String resolveDispute(String disputeId) =>
      '/bounties/disputes/$disputeId/resolve';
  static String bountyDisputes(String bountyId) =>
      '/bounties/$bountyId/disputes';

  // ── Reviews ───────────────────────────────────────────────
  static const String reviews = '/reviews';
  static String reviewsForUser(String userId) => '/reviews/user/$userId';
  static String reviewsForBounty(String bountyId) =>
      '/reviews/bounty/$bountyId';

  // ── Gamification ──────────────────────────────────────────
  static const String leaderboard = '/gamification/leaderboard';
  static const String gamificationMe = '/gamification/me';

  // ── Algorand / Escrow ─────────────────────────────────────
  static String fundBounty(String bountyId) =>
      '/algorand/fund-bounty/$bountyId';
  static const String submitTxn = '/algorand/submit-txn';
  static String verifyFunding(String bountyId) =>
      '/algorand/verify-funding/$bountyId';
  static String algoBalance(String address) => '/algorand/balance/$address';
  static const String escrowInfo = '/algorand/escrow-info';
  static const String wallet = '/algorand/wallet';
  static const String generateWallet = '/algorand/generate-wallet';
  static const String dispense = '/algorand/dispense';
  static const String transactions = '/algorand/transactions';
}
