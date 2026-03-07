import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/bounty_remote_datasource.dart';
import '../../data/models/bounty_model.dart';
import '../../data/repositories/bounty_repository.dart';

// ── Repository provider ─────────────────────────────────────

final bountyRepositoryProvider = Provider<BountyRepository>((ref) {
  final dio = ref.read(dioProvider);
  return BountyRepository(BountyRemoteDataSource(dio));
});

// ── Bounty list state ───────────────────────────────────────

class BountyListState {
  final List<BountyModel> bounties;
  final bool isLoading;
  final String? error;

  const BountyListState({
    this.bounties = const [],
    this.isLoading = false,
    this.error,
  });

  BountyListState copyWith({
    List<BountyModel>? bounties,
    bool? isLoading,
    String? error,
  }) {
    return BountyListState(
      bounties: bounties ?? this.bounties,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BountyListNotifier extends StateNotifier<BountyListState> {
  final BountyRepository _repo;

  BountyListNotifier(this._repo) : super(const BountyListState()) {
    loadBounties();
  }

  Future<void> loadBounties({String? status, String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('[BountyList] loading bounties...');
      final result = await _repo.listBounties(
        status: status,
        category: category,
        limit: 20,
      );
      debugPrint('[BountyList] loaded ${result.bounties.length} bounties');
      state = BountyListState(bounties: result.bounties);
    } catch (e, st) {
      debugPrint('[BountyList] ERROR: $e');
      debugPrint('[BountyList] stack: $st');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadBounties();
}

final bountyListProvider =
    StateNotifierProvider<BountyListNotifier, BountyListState>((ref) {
      return BountyListNotifier(ref.read(bountyRepositoryProvider));
    });

// ── My claims state ─────────────────────────────────────────

class MyClaimsState {
  final List<BountyClaimModel> claims;
  final bool isLoading;
  final String? error;

  const MyClaimsState({
    this.claims = const [],
    this.isLoading = false,
    this.error,
  });
}

class MyClaimsNotifier extends StateNotifier<MyClaimsState> {
  final BountyRepository _repo;

  MyClaimsNotifier(this._repo) : super(const MyClaimsState()) {
    load();
  }

  Future<void> load() async {
    state = const MyClaimsState(isLoading: true);
    try {
      debugPrint('[MyClaims] fetching claims...');
      final claims = await _repo.getMyClaims();
      debugPrint('[MyClaims] loaded ${claims.length} claims');
      state = MyClaimsState(claims: claims);
    } catch (e, st) {
      debugPrint('[MyClaims] ERROR: $e');
      debugPrint('[MyClaims] stack: $st');
      state = MyClaimsState(error: e.toString());
    }
  }
}

final myClaimsProvider = StateNotifierProvider<MyClaimsNotifier, MyClaimsState>(
  (ref) {
    return MyClaimsNotifier(ref.read(bountyRepositoryProvider));
  },
);

// ── My created bounties ─────────────────────────────────────

class MyBountiesState {
  final List<BountyModel> bounties;
  final bool isLoading;
  final String? error;

  const MyBountiesState({
    this.bounties = const [],
    this.isLoading = false,
    this.error,
  });
}

class MyBountiesNotifier extends StateNotifier<MyBountiesState> {
  final BountyRepository _repo;
  final String _userId;

  MyBountiesNotifier(this._repo, this._userId)
    : super(const MyBountiesState()) {
    load();
  }

  Future<void> load() async {
    state = const MyBountiesState(isLoading: true);
    try {
      final result = await _repo.listBounties(creatorId: _userId, limit: 20);
      state = MyBountiesState(bounties: result.bounties);
    } catch (e) {
      debugPrint('[MyBounties] ERROR: $e');
      state = MyBountiesState(error: e.toString());
    }
  }

  Future<void> refresh() => load();
}

final myBountiesProvider =
    StateNotifierProvider<MyBountiesNotifier, MyBountiesState>((ref) {
      final userId = ref.watch(authProvider).user?.id ?? '';
      return MyBountiesNotifier(ref.read(bountyRepositoryProvider), userId);
    });
