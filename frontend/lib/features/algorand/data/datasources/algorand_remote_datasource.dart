import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';

/// Data source for all Algorand / escrow API calls.
class AlgorandRemoteDataSource {
  final Dio _dio;

  AlgorandRemoteDataSource(this._dio);

  /// Create an unsigned funding transaction for a bounty.
  Future<Map<String, dynamic>> fundBounty({
    required String bountyId,
    required String senderAddress,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.fundBounty(bountyId),
      data: {'senderAddress': senderAddress},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Submit a signed transaction to the blockchain.
  Future<Map<String, dynamic>> submitTransaction({
    required String signedTxn,
    required String bountyId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.submitTxn,
      data: {'signedTxn': signedTxn, 'bountyId': bountyId},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Verify a bounty's funding status on-chain.
  Future<Map<String, dynamic>> verifyFunding(String bountyId) async {
    final response = await _dio.post(ApiEndpoints.verifyFunding(bountyId));
    return response.data as Map<String, dynamic>;
  }

  /// Get balance of an Algorand address.
  Future<Map<String, dynamic>> getBalance(String address) async {
    final response = await _dio.get(ApiEndpoints.algoBalance(address));
    return response.data as Map<String, dynamic>;
  }

  /// Get escrow account info.
  Future<Map<String, dynamic>> getEscrowInfo() async {
    final response = await _dio.get(ApiEndpoints.escrowInfo);
    return response.data as Map<String, dynamic>;
  }

  /// Set or update the current user's wallet address.
  Future<Map<String, dynamic>> setWallet(String walletAddress) async {
    final response = await _dio.patch(
      ApiEndpoints.wallet,
      data: {'walletAddress': walletAddress},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get the current user's wallet address.
  Future<Map<String, dynamic>> getWallet() async {
    final response = await _dio.get(ApiEndpoints.wallet);
    return response.data as Map<String, dynamic>;
  }

  /// Auto-generate a custodial wallet for the current user.
  /// Idempotent — returns existing wallet if already generated.
  Future<Map<String, dynamic>> generateWallet() async {
    final response = await _dio.post(ApiEndpoints.generateWallet);
    return response.data as Map<String, dynamic>;
  }

  /// Dispense test ALGO from the local devmode faucet.
  Future<Map<String, dynamic>> dispense({double amount = 10}) async {
    final response = await _dio.post(
      ApiEndpoints.dispense,
      data: {'amount': amount},
    );
    return response.data as Map<String, dynamic>;
  }
}
