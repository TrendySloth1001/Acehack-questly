import 'datasources/algorand_remote_datasource.dart';

/// Repository wrapping Algorand API calls with typed responses.
class AlgorandRepository {
  final AlgorandRemoteDataSource _ds;

  AlgorandRepository(this._ds);

  /// Create unsigned funding txn → returns { unsignedTxn, txnId, escrowAddress, ... }
  Future<FundingTxn> fundBounty({
    required String bountyId,
    required String senderAddress,
  }) async {
    final res = await _ds.fundBounty(
      bountyId: bountyId,
      senderAddress: senderAddress,
    );
    final data = res['data'] as Map<String, dynamic>;
    return FundingTxn.fromJson(data);
  }

  /// Submit signed txn → returns { txId, confirmedRound }
  Future<TxnResult> submitTransaction({
    required String signedTxn,
    required String bountyId,
  }) async {
    final res = await _ds.submitTransaction(
      signedTxn: signedTxn,
      bountyId: bountyId,
    );
    final data = res['data'] as Map<String, dynamic>;
    return TxnResult.fromJson(data);
  }

  /// Verify funding on-chain.
  Future<Map<String, dynamic>> verifyFunding(String bountyId) async {
    final res = await _ds.verifyFunding(bountyId);
    return res['data'] as Map<String, dynamic>;
  }

  /// Get wallet balance.
  Future<WalletBalance> getBalance(String address) async {
    final res = await _ds.getBalance(address);
    final data = res['data'] as Map<String, dynamic>;
    return WalletBalance.fromJson(data);
  }

  /// Get escrow info.
  Future<EscrowInfo> getEscrowInfo() async {
    final res = await _ds.getEscrowInfo();
    final data = res['data'] as Map<String, dynamic>;
    return EscrowInfo.fromJson(data);
  }

  /// Save wallet address on backend.
  Future<void> setWallet(String walletAddress) async {
    await _ds.setWallet(walletAddress);
  }

  /// Get user's saved wallet address.
  Future<String?> getWallet() async {
    final res = await _ds.getWallet();
    final data = res['data'] as Map<String, dynamic>;
    return data['walletAddress'] as String?;
  }

  /// Auto-generate a custodial wallet (idempotent).
  /// Returns { walletAddress, isNew, balance }.
  Future<GeneratedWallet> generateWallet() async {
    final res = await _ds.generateWallet();
    final data = res['data'] as Map<String, dynamic>;
    return GeneratedWallet.fromJson(data);
  }

  /// Dispense test ALGO from local faucet.
  Future<DispenseResult> dispense({double amount = 10}) async {
    final res = await _ds.dispense(amount: amount);
    final data = res['data'] as Map<String, dynamic>;
    return DispenseResult.fromJson(data);
  }

  /// Get the current user's wallet transaction history.
  Future<List<WalletTxn>> getTransactions() async {
    final res = await _ds.getTransactions();
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => WalletTxn.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ── Models ──────────────────────────────────────────────────

class FundingTxn {
  final String unsignedTxn;
  final String txnId;
  final String escrowAddress;
  final int amountMicroAlgo;
  final double amountAlgo;

  const FundingTxn({
    required this.unsignedTxn,
    required this.txnId,
    required this.escrowAddress,
    required this.amountMicroAlgo,
    required this.amountAlgo,
  });

  factory FundingTxn.fromJson(Map<String, dynamic> json) => FundingTxn(
    unsignedTxn: json['unsignedTxn'] as String,
    txnId: json['txnId'] as String,
    escrowAddress: json['escrowAddress'] as String,
    amountMicroAlgo: json['amountMicroAlgo'] as int,
    amountAlgo: (json['amountAlgo'] as num).toDouble(),
  );
}

class TxnResult {
  final String txId;
  final int confirmedRound;

  const TxnResult({required this.txId, required this.confirmedRound});

  factory TxnResult.fromJson(Map<String, dynamic> json) => TxnResult(
    txId: json['txId'] as String,
    confirmedRound: json['confirmedRound'] as int? ?? 0,
  );
}

class WalletBalance {
  final double balanceAlgo;
  final int balanceMicroAlgo;
  final double minBalance;

  const WalletBalance({
    required this.balanceAlgo,
    required this.balanceMicroAlgo,
    required this.minBalance,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
    balanceAlgo: (json['balanceAlgo'] as num).toDouble(),
    balanceMicroAlgo: json['balanceMicroAlgo'] as int,
    minBalance: (json['minBalance'] as num).toDouble(),
  );
}

class EscrowInfo {
  final String address;
  final double balanceAlgo;
  final int balanceMicroAlgo;
  final double minBalance;
  final String network;

  const EscrowInfo({
    required this.address,
    required this.balanceAlgo,
    required this.balanceMicroAlgo,
    required this.minBalance,
    required this.network,
  });

  factory EscrowInfo.fromJson(Map<String, dynamic> json) => EscrowInfo(
    address: json['address'] as String,
    balanceAlgo: (json['balanceAlgo'] as num).toDouble(),
    balanceMicroAlgo: json['balanceMicroAlgo'] as int,
    minBalance: (json['minBalance'] as num).toDouble(),
    network: json['network'] as String? ?? 'testnet',
  );
}

class GeneratedWallet {
  final String walletAddress;
  final bool isNew;
  final WalletBalance? balance;

  const GeneratedWallet({
    required this.walletAddress,
    required this.isNew,
    this.balance,
  });

  factory GeneratedWallet.fromJson(Map<String, dynamic> json) {
    WalletBalance? balance;
    if (json['balance'] != null) {
      balance = WalletBalance.fromJson(json['balance'] as Map<String, dynamic>);
    }
    return GeneratedWallet(
      walletAddress: json['walletAddress'] as String,
      isNew: json['isNew'] as bool? ?? false,
      balance: balance,
    );
  }
}

class DispenseResult {
  final String txId;
  final double amountAlgo;
  final WalletBalance? balance;

  const DispenseResult({
    required this.txId,
    required this.amountAlgo,
    this.balance,
  });

  factory DispenseResult.fromJson(Map<String, dynamic> json) {
    WalletBalance? balance;
    if (json['balance'] != null) {
      balance = WalletBalance.fromJson(json['balance'] as Map<String, dynamic>);
    }
    return DispenseResult(
      txId: json['txId'] as String,
      amountAlgo: (json['amountAlgo'] as num).toDouble(),
      balance: balance,
    );
  }
}

class WalletTxn {
  final String id;
  final String type; // 'DEBIT' | 'CREDIT'
  final double amountAlgo;
  final String? txId;
  final String? bountyId;
  final String? bountyTitle;
  final String? counterpartyAddress;
  final String description;
  final DateTime createdAt;

  const WalletTxn({
    required this.id,
    required this.type,
    required this.amountAlgo,
    this.txId,
    this.bountyId,
    this.bountyTitle,
    this.counterpartyAddress,
    required this.description,
    required this.createdAt,
  });

  bool get isDebit => type == 'DEBIT';

  factory WalletTxn.fromJson(Map<String, dynamic> json) => WalletTxn(
    id: json['id'] as String,
    type: json['type'] as String,
    amountAlgo: (json['amountAlgo'] as num).toDouble(),
    txId: json['txId'] as String?,
    bountyId: json['bountyId'] as String?,
    bountyTitle: json['bountyTitle'] as String?,
    counterpartyAddress: json['counterpartyAddress'] as String?,
    description: json['description'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
