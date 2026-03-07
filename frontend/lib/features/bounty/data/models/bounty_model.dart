/// Bounty model matching the backend Bounty shape.
class BountyModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double algoAmount;
  final DateTime deadline;
  final String status;
  final double? latitude;
  final double? longitude;
  final String? location;
  final List<String> imageUrls;
  final Map<String, dynamic>? extraFields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BountyCreator creator;
  final int claimCount;

  /// Only populated by getById (detail endpoint).
  final List<BountyClaimModel> claims;

  const BountyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.algoAmount,
    required this.deadline,
    required this.status,
    this.latitude,
    this.longitude,
    this.location,
    this.imageUrls = const [],
    this.extraFields,
    required this.createdAt,
    required this.updatedAt,
    required this.creator,
    this.claimCount = 0,
    this.claims = const [],
  });

  factory BountyModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>?;
    return BountyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      algoAmount: (json['algoAmount'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline'] as String),
      status: json['status'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      location: json['location'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      extraFields: json['extraFields'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      creator: BountyCreator.fromJson(json['creator'] as Map<String, dynamic>),
      claimCount: count?['claims'] as int? ?? 0,
      claims:
          (json['claims'] as List<dynamic>?)
              ?.map((e) => BountyClaimModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class BountyCreator {
  final String id;
  final String? name;
  final String? avatarUrl;

  const BountyCreator({required this.id, this.name, this.avatarUrl});

  factory BountyCreator.fromJson(Map<String, dynamic> json) {
    return BountyCreator(
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class BountyClaimModel {
  final String id;
  final String status;
  final String? proofUrl;
  final String? note;
  final DateTime? submittedAt;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final BountyCreator claimer;
  final ClaimBountyInfo? bounty;

  const BountyClaimModel({
    required this.id,
    required this.status,
    this.proofUrl,
    this.note,
    this.submittedAt,
    this.resolvedAt,
    required this.createdAt,
    required this.claimer,
    this.bounty,
  });

  /// Multiple proof URLs stored comma-separated in [proofUrl].
  List<String> get proofUrls => proofUrl != null && proofUrl!.isNotEmpty
      ? proofUrl!.split(',')
      : const [];

  factory BountyClaimModel.fromJson(Map<String, dynamic> json) {
    return BountyClaimModel(
      id: json['id'] as String,
      status: json['status'] as String,
      proofUrl: json['proofUrl'] as String?,
      note: json['note'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      claimer: BountyCreator.fromJson(json['claimer'] as Map<String, dynamic>),
      bounty: json['bounty'] != null
          ? ClaimBountyInfo.fromJson(json['bounty'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ClaimBountyInfo {
  final String id;
  final String title;
  final double algoAmount;
  final String status;
  final BountyCreator? creator;

  const ClaimBountyInfo({
    required this.id,
    required this.title,
    required this.algoAmount,
    required this.status,
    this.creator,
  });

  factory ClaimBountyInfo.fromJson(Map<String, dynamic> json) {
    return ClaimBountyInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      algoAmount: (json['algoAmount'] as num).toDouble(),
      status: json['status'] as String,
      creator: json['creator'] != null
          ? BountyCreator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
    );
  }
}
