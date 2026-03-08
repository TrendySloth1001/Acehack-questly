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

  // Gamification
  final int xp;
  final int level;
  final double? avgRating;
  final int totalReviews;
  final DateTime? lastActiveAt;

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
    this.xp = 0,
    this.level = 0,
    this.avgRating,
    this.totalReviews = 0,
    this.lastActiveAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Minecraft rank tier based on XP.
  String get rankTier {
    if (xp >= 25000) return 'NETHERITE';
    if (xp >= 10000) return 'DIAMOND';
    if (xp >= 4000) return 'GOLD';
    if (xp >= 1500) return 'IRON';
    if (xp >= 500) return 'STONE';
    return 'WOOD';
  }

  /// XP needed for next level.
  int get nextLevelXp => (level + 1) * (level + 1) * 25;
}
