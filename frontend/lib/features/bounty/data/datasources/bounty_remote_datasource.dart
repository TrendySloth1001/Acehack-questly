import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';

class BountyRemoteDataSource {
  final Dio _dio;

  BountyRemoteDataSource(this._dio);

  /// Upload multiple images for a bounty, returns list of { url, uploadId }.
  Future<Map<String, dynamic>> uploadImages(List<File> imageFiles) async {
    final formData = FormData();
    for (final file in imageFiles) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }
    final response = await _dio.post(
      ApiEndpoints.bountyUploadImages,
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createBounty(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.bounties, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listBounties({
    String? status,
    String? category,
    String? creatorId,
    int? page,
    int? limit,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (category != null) params['category'] = category;
    if (creatorId != null) params['creatorId'] = creatorId;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    final response = await _dio.get(
      ApiEndpoints.bounties,
      queryParameters: params,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBounty(String id) async {
    final response = await _dio.get(ApiEndpoints.bountyById(id));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBounty(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(ApiEndpoints.bountyById(id), data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteBounty(String id) async {
    await _dio.delete(ApiEndpoints.bountyById(id));
  }

  Future<Map<String, dynamic>> claimBounty(String id) async {
    final response = await _dio.post(ApiEndpoints.claimBounty(id));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyClaims() async {
    final response = await _dio.get(ApiEndpoints.myClaims);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitProof(
    String claimId, {
    required List<String> proofUrls,
    String? note,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.submitProof(claimId),
      data: {'proofUrls': proofUrls, if (note != null) 'note': note},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> declaim(String claimId) async {
    await _dio.delete(ApiEndpoints.declaim(claimId));
  }

  /// Approve or reject a claim (bounty owner only).
  Future<Map<String, dynamic>> resolveClaim(
    String claimId, {
    required String action,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.resolveClaim(claimId),
      data: {'action': action},
    );
    return response.data as Map<String, dynamic>;
  }
}
