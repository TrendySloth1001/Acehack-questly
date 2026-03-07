import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';

class QuestRemoteDataSource {
  final Dio _dio;

  QuestRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getQuests({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final response = await _dio.get(
      ApiEndpoints.quests,
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getQuestById(String id) async {
    final response = await _dio.get(ApiEndpoints.questById(id));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createQuest({
    required String title,
    String? description,
    List<Map<String, String>>? tasks,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.quests,
      data: {
        'title': title,
        'description': description,
        // ignore: use_null_aware_elements
        if (tasks != null) 'tasks': tasks,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateQuest(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(ApiEndpoints.questById(id), data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteQuest(String id) async {
    await _dio.delete(ApiEndpoints.questById(id));
  }

  // ── Tasks ────────────────────────────────────────────────

  Future<Map<String, dynamic>> addTask(
    String questId, {
    required String title,
    String? description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.questTasks(questId),
      data: {'title': title, 'description': description},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTask(
    String questId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      ApiEndpoints.questTaskById(questId, taskId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteTask(String questId, String taskId) async {
    await _dio.delete(ApiEndpoints.questTaskById(questId, taskId));
  }
}
