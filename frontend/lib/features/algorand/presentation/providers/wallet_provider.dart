import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/algorand_repository.dart';
import '../../data/datasources/algorand_remote_datasource.dart';
import '../../data/pera_wallet_service.dart';

// ── Repository provider ─────────────────────────────────────

final algorandRepositoryProvider = Provider<AlgorandRepository>((ref) {
  final dio = ref.read(dioProvider);
  return AlgorandRepository(AlgorandRemoteDataSource(dio));
});

// ── Wallet state ────────────────────────────────────────────

class WalletState {
  final String? address;
  final WalletBalance? balance;
  final EscrowInfo? escrowInfo;
  final List<WalletTxn> transactions;
  final bool isLoading;
  final bool txnsLoading;
  final String? error;

  const WalletState({
    this.address,
    this.balance,
    this.escrowInfo,
    this.transactions = const [],
    this.isLoading = false,
    this.txnsLoading = false,
    this.error,
  });

  WalletState copyWith({
    String? address,
    WalletBalance? balance,
    EscrowInfo? escrowInfo,
    List<WalletTxn>? transactions,
    bool? isLoading,
    bool? txnsLoading,
    String? error,
  }) {
    return WalletState(
      address: address ?? this.address,
      balance: balance ?? this.balance,
      escrowInfo: escrowInfo ?? this.escrowInfo,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      txnsLoading: txnsLoading ?? this.txnsLoading,
      error: error,
    );
  }
}

// ── Wallet notifier ─────────────────────────────────────────

class WalletNotifier extends StateNotifier<WalletState> {
  final AlgorandRepository _repo;

  WalletNotifier(this._repo) : super(const WalletState());

  /// Clear all wallet state (called on logout / user switch).
  void reset() {
    state = const WalletState();
  }

  /// Load saved wallet and escrow info.
  /// If no wallet exists, auto-generates one server-side.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check if wallet already exists
      final address = await _repo.getWallet();

      if (address == null || address.isEmpty) {
        // Auto-generate a custodial wallet
        await _autoGenerate();
        return;
      }

      // Has wallet — fetch balance + escrow info
      final escrow = await _repo.getEscrowInfo();
      WalletBalance? balance;
      try {
        balance = await _repo.getBalance(address);
      } catch (_) {}

      state = WalletState(
        address: address,
        balance: balance,
        escrowInfo: escrow,
      );

      // Load transaction history in background
      await loadTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load wallet in Pera mode. Reads the saved Pera address from secure
  /// storage — if found, fetches balance; if not, stays at empty state
  /// (never auto-generates a custodial wallet for Pera users).
  Future<void> loadPera() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final saved = await PeraWalletService.instance.getSavedAddress();
      if (saved == null || saved.isEmpty) {
        state = const WalletState(); // pristine — show connect screen
        return;
      }
      WalletBalance? balance;
      try {
        balance = await _repo.getBalance(saved);
      } catch (_) {}
      state = WalletState(address: saved, balance: balance);
      await loadTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Explicitly generate a wallet (called from UI or auto on load).
  Future<bool> generateWallet() async {
    state = state.copyWith(isLoading: true, error: null);
    return _autoGenerate();
  }

  Future<bool> _autoGenerate() async {
    try {
      final generated = await _repo.generateWallet();
      final escrow = await _repo.getEscrowInfo();

      WalletBalance? balance = generated.balance;
      if (balance == null && generated.walletAddress.isNotEmpty) {
        try {
          balance = await _repo.getBalance(generated.walletAddress);
        } catch (_) {}
      }

      state = WalletState(
        address: generated.walletAddress,
        balance: balance,
        escrowInfo: escrow,
      );
      await loadTransactions();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Save wallet address.
  Future<bool> setWallet(String address) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.setWallet(address);
      WalletBalance? balance;
      try {
        balance = await _repo.getBalance(address);
      } catch (_) {}
      state = state.copyWith(
        address: address,
        balance: balance,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Fund a bounty (create unsigned txn).
  Future<FundingTxn?> fundBounty({
    required String bountyId,
    required String senderAddress,
  }) async {
    try {
      return await _repo.fundBounty(
        bountyId: bountyId,
        senderAddress: senderAddress,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Load transaction history.
  Future<void> loadTransactions() async {
    state = state.copyWith(txnsLoading: true);
    try {
      final txns = await _repo.getTransactions();
      state = state.copyWith(transactions: txns, txnsLoading: false);
    } catch (_) {
      state = state.copyWith(txnsLoading: false);
    }
  }

  /// Submit a signed transaction (backend signs with custodial mnemonic).
  Future<TxnResult?> submitTransaction({
    required String signedTxn,
    required String bountyId,
  }) async {
    try {
      final result = await _repo.submitTransaction(
        signedTxn: signedTxn,
        bountyId: bountyId,
      );
      // Refresh balance + history after successful funding
      await refreshBalance();
      await loadTransactions();
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Verify funding on-chain.
  Future<bool> verifyFunding(String bountyId) async {
    try {
      final data = await _repo.verifyFunding(bountyId);
      return data['verified'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Refresh balance for current wallet.
  Future<void> refreshBalance() async {
    if (state.address == null || state.address!.isEmpty) return;
    try {
      final balance = await _repo.getBalance(state.address!);
      state = state.copyWith(balance: balance);
    } catch (_) {}
  }

  /// Dispense test ALGO from local faucet into user's wallet.
  Future<bool> dispense({double amount = 10}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.dispense(amount: amount);
      // Update balance from dispense response
      if (result.balance != null) {
        state = state.copyWith(balance: result.balance, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
        await refreshBalance();
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  final repo = ref.read(algorandRepositoryProvider);
  final notifier = WalletNotifier(repo);

  // Clear wallet state when user logs out so the next user
  // doesn't see the previous user's balance.
  ref.listen<AuthState>(authProvider, (prev, next) {
    if (next.status == AuthStatus.unauthenticated) {
      notifier.reset();
    }
  });

  return notifier;
});
