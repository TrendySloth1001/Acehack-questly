import 'dart:io';
import '../datasources/bounty_remote_datasource.dart';
import '../models/bounty_model.dart';

class BountyRepository {
  final BountyRemoteDataSource _remote;

  BountyRepository(this._remote);

  /// Upload multiple images and return their URLs.
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final response = await _remote.uploadImages(imageFiles);
    final data = response['data'] as List;
    return data
        .map((e) => (e as Map<String, dynamic>)['url'] as String)
        .toList();
  }

  Future<BountyModel> createBounty(Map<String, dynamic> data) async {
    final response = await _remote.createBounty(data);
    return BountyModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<({List<BountyModel> bounties, Map<String, dynamic> pagination})>
  listBounties({
    String? status,
    String? category,
    String? creatorId,
    int? page,
    int? limit,
  }) async {
    final response = await _remote.listBounties(
      status: status,
      category: category,
      creatorId: creatorId,
      page: page,
      limit: limit,
    );
    final data = response['data'] as Map<String, dynamic>;
    final list = (data['bounties'] as List)
        .map((e) => BountyModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return (bounties: list, pagination: pagination);
  }

  Future<BountyModel> getBounty(String id) async {
    final response = await _remote.getBounty(id);
    return BountyModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteBounty(String id) async {
    await _remote.deleteBounty(id);
  }

  Future<void> claimBounty(String id) async {
    await _remote.claimBounty(id);
  }

  Future<List<BountyClaimModel>> getMyClaims() async {
    final response = await _remote.getMyClaims();
    final data = response['data'] as List;
    return data
        .map((e) => BountyClaimModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitProof(
    String claimId, {
    required List<String> proofUrls,
    String? note,
  }) async {
    await _remote.submitProof(claimId, proofUrls: proofUrls, note: note);
  }

  Future<void> declaim(String claimId) async {
    await _remote.declaim(claimId);
  }

  /// Approve or reject a claim.
  Future<void> resolveClaim(String claimId, {required String action}) async {
    await _remote.resolveClaim(claimId, action: action);
  }
}
