import 'package:json_annotation/json_annotation.dart';

part 'quest_model.g.dart';

@JsonSerializable()
class QuestModel {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TaskModel>? tasks;

  const QuestModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.tasks,
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) =>
      _$QuestModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestModelToJson(this);

  int get completedTaskCount => tasks?.where((t) => t.isCompleted).length ?? 0;

  int get totalTaskCount => tasks?.length ?? 0;

  double get progress =>
      totalTaskCount > 0 ? completedTaskCount / totalTaskCount : 0;
}

@JsonSerializable()
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final int order;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.order,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}
