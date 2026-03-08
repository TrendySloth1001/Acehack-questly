import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

// ── Review model ────────────────────────────────────────────

class ReviewModel {
  final String id;
  final int stars;
  final String? comment;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerAvatarUrl;
  final String? reviewerId;
  final String? bountyTitle;
  final String? bountyId;

  const ReviewModel({
    required this.id,
    required this.stars,
    this.comment,
    required this.createdAt,
    this.reviewerName,
    this.reviewerAvatarUrl,
    this.reviewerId,
    this.bountyTitle,
    this.bountyId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    final bounty = json['bounty'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      stars: json['stars'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewerName: reviewer?['name'] as String?,
      reviewerAvatarUrl: reviewer?['avatarUrl'] as String?,
      reviewerId: reviewer?['id'] as String?,
      bountyTitle: bounty?['title'] as String?,
      bountyId: bounty?['id'] as String?,
    );
  }
}

// ── Submit review ───────────────────────────────────────────

Future<void> submitReview(
  Dio dio, {
  required String bountyId,
  required String revieweeId,
  required int stars,
  String? comment,
}) async {
  await dio.post(ApiEndpoints.reviews, data: {
    'bountyId': bountyId,
    'revieweeId': revieweeId,
    'stars': stars,
    if (comment != null && comment.isNotEmpty) 'comment': comment,
  });
}

// ── User reviews provider ───────────────────────────────────

final userReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, userId) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get(ApiEndpoints.reviewsForUser(userId));
    final data = response.data['data'] as List;
    return data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('[UserReviews] ERROR: $e');
    return [];
  }
});

// ── Bounty reviews provider ─────────────────────────────────

final bountyReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, bountyId) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get(ApiEndpoints.reviewsForBounty(bountyId));
    final data = response.data['data'] as List;
    return data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('[BountyReviews] ERROR: $e');
    return [];
  }
});
