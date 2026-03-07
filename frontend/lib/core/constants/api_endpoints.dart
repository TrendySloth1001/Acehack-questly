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
  static const String githubAuth = '/auth/github';

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
}
