// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  role: json['role'] as String,
  phone: json['phone'] as String?,
  reason: json['reason'] as String?,
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  location: json['location'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  onboarded: json['onboarded'] as bool? ?? false,
  walletAddress: json['walletAddress'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'role': instance.role,
  'phone': instance.phone,
  'reason': instance.reason,
  'skills': instance.skills,
  'location': instance.location,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'onboarded': instance.onboarded,
  'walletAddress': instance.walletAddress,
  'createdAt': instance.createdAt.toIso8601String(),
};
