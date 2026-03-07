import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/quest_remote_datasource.dart';
import '../../data/models/quest_model.dart';
import '../../data/repositories/quest_repository.dart';

// ── Repository ──────────────────────────────────────────────

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  final dio = ref.read(dioProvider);
  return QuestRepository(QuestRemoteDataSource(dio));
});

// ── Quest list state ────────────────────────────────────────

class QuestListState {
  final List<QuestModel> quests;
  final PaginationMeta? meta;
  final bool isLoading;
  final String? error;

  const QuestListState({
    this.quests = const [],
    this.meta,
    this.isLoading = false,
    this.error,
  });

  QuestListState copyWith({
    List<QuestModel>? quests,
    PaginationMeta? meta,
    bool? isLoading,
    String? error,
  }) {
    return QuestListState(
      quests: quests ?? this.quests,
      meta: meta ?? this.meta,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class QuestListNotifier extends StateNotifier<QuestListState> {
  final QuestRepository _repo;

  QuestListNotifier(this._repo) : super(const QuestListState()) {
    loadQuests();
  }

  Future<void> loadQuests({
    int page = 1,
    String? status,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.getQuests(
        page: page,
        status: status,
        search: search,
      );
      state = QuestListState(
        quests: page == 1 ? result.quests : [...state.quests, ...result.quests],
        meta: result.meta,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadQuests();

  Future<void> loadMore() {
    final meta = state.meta;
    if (meta == null || !meta.hasNextPage || state.isLoading) {
      return Future.value();
    }
    return loadQuests(page: meta.page + 1);
  }

  void removeQuest(String id) {
    state = state.copyWith(
      quests: state.quests.where((q) => q.id != id).toList(),
    );
  }
}

final questListProvider =
    StateNotifierProvider<QuestListNotifier, QuestListState>((ref) {
      return QuestListNotifier(ref.read(questRepositoryProvider));
    });

// ── Single quest ────────────────────────────────────────────

final questDetailProvider = FutureProvider.family<QuestModel, String>((
  ref,
  id,
) async {
  return ref.read(questRepositoryProvider).getQuestById(id);
});
