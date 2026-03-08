import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

// ── Leaderboard entry ───────────────────────────────────────

class LeaderboardEntry {
  final int rank;
  final String id;
  final String? name;
  final String? avatarUrl;
  final int xp;
  final int level;
  final double? avgRating;
  final int totalReviews;
  final String tier;

  const LeaderboardEntry({
    required this.rank,
    required this.id,
    this.name,
    this.avatarUrl,
    required this.xp,
    required this.level,
    this.avgRating,
    this.totalReviews = 0,
    required this.tier,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 0,
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'] as int? ?? 0,
      tier: json['tier'] as String? ?? 'WOOD',
    );
  }
}

// ── Gamification stats ──────────────────────────────────────

class GamificationStats {
  final int xp;
  final int level;
  final double? avgRating;
  final int totalReviews;
  final String rank;
  final int nextLevelXp;

  const GamificationStats({
    this.xp = 0,
    this.level = 0,
    this.avgRating,
    this.totalReviews = 0,
    this.rank = 'WOOD',
    this.nextLevelXp = 25,
  });

  factory GamificationStats.fromJson(Map<String, dynamic> json) {
    return GamificationStats(
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'] as int? ?? 0,
      rank: json['rank'] as String? ?? 'WOOD',
      nextLevelXp: json['nextLevelXp'] as int? ?? 25,
    );
  }
}

// ── Leaderboard provider ────────────────────────────────────

class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final Dio _dio;

  LeaderboardNotifier(this._dio) : super(const LeaderboardState()) {
    load();
  }

  Future<void> load() async {
    state = const LeaderboardState(isLoading: true);
    try {
      final response = await _dio.get(ApiEndpoints.leaderboard);
      final data = response.data['data'] as List;
      final entries = data
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      state = LeaderboardState(entries: entries);
    } catch (e) {
      debugPrint('[Leaderboard] ERROR: $e');
      state = LeaderboardState(error: e.toString());
    }
  }

  Future<void> refresh() => load();
}

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
      return LeaderboardNotifier(ref.read(dioProvider));
    });

// ── My gamification stats provider ──────────────────────────

final gamificationStatsProvider = FutureProvider<GamificationStats>((
  ref,
) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get(ApiEndpoints.gamificationMe);
    return GamificationStats.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  } catch (e) {
    debugPrint('[GamificationStats] ERROR: $e');
    return const GamificationStats();
  }
});
