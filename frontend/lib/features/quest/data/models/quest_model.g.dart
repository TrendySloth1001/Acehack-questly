// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestModel _$QuestModelFromJson(Map<String, dynamic> json) => QuestModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  status: json['status'] as String,
  userId: json['userId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  tasks: (json['tasks'] as List<dynamic>?)
      ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QuestModelToJson(QuestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tasks': instance.tasks,
    };

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  isCompleted: json['isCompleted'] as bool,
  order: (json['order'] as num).toInt(),
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'isCompleted': instance.isCompleted,
  'order': instance.order,
};
