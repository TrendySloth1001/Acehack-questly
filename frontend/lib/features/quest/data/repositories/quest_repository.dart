import '../../../../core/network/api_response.dart';
import '../datasources/quest_remote_datasource.dart';
import '../models/quest_model.dart';

class QuestRepository {
  final QuestRemoteDataSource _remote;

  QuestRepository(this._remote);

  Future<({List<QuestModel> quests, PaginationMeta? meta})> getQuests({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    final response = await _remote.getQuests(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );

    final data = response['data'] as List<dynamic>;
    final quests = data
        .map((e) => QuestModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = response['meta'] != null
        ? PaginationMeta.fromJson(response['meta'] as Map<String, dynamic>)
        : null;

    return (quests: quests, meta: meta);
  }

  Future<QuestModel> getQuestById(String id) async {
    final response = await _remote.getQuestById(id);
    return QuestModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<QuestModel> createQuest({
    required String title,
    String? description,
    List<Map<String, String>>? tasks,
  }) async {
    final response = await _remote.createQuest(
      title: title,
      description: description,
      tasks: tasks,
    );
    return QuestModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<QuestModel> updateQuest(String id, Map<String, dynamic> data) async {
    final response = await _remote.updateQuest(id, data);
    return QuestModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteQuest(String id) async {
    await _remote.deleteQuest(id);
  }

  Future<TaskModel> addTask(
    String questId, {
    required String title,
    String? description,
  }) async {
    final response = await _remote.addTask(
      questId,
      title: title,
      description: description,
    );
    return TaskModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask(
    String questId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    final response = await _remote.updateTask(questId, taskId, data);
    return TaskModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTask(String questId, String taskId) async {
    await _remote.deleteTask(questId, taskId);
  }
}
