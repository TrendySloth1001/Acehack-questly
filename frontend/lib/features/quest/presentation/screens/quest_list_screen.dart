import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/quest_provider.dart';
import '../widgets/quest_card.dart';

class QuestListScreen extends ConsumerWidget {
  const QuestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questState = ref.watch(questListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Quests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: search
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.go('/home/quests/new'),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: questState.isLoading && questState.quests.isEmpty
          ? const LoadingOverlay()
          : questState.error != null && questState.quests.isEmpty
          ? ErrorDisplay(
              message: questState.error!,
              onRetry: () => ref.read(questListProvider.notifier).refresh(),
            )
          : questState.quests.isEmpty
          ? EmptyState(
              message: 'No quests yet.\nTap + to create your first quest!',
              icon: Icons.explore_outlined,
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(questListProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questState.quests.length,
                itemBuilder: (context, index) {
                  final quest = questState.quests[index];
                  return QuestCard(
                    quest: quest,
                    onTap: () => context.go('/home/quests/${quest.id}'),
                  );
                },
              ),
            ),
    );
  }
}
