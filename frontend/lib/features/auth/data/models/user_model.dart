import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String role;
  final String? phone;
  final String? reason;
  final List<String> skills;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool onboarded;
  final String? walletAddress;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.role,
    this.phone,
    this.reason,
    this.skills = const [],
    this.location,
    this.latitude,
    this.longitude,
    this.onboarded = false,
    this.walletAddress,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
