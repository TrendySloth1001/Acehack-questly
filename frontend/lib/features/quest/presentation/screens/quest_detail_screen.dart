import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/quest_provider.dart';

class QuestDetailScreen extends ConsumerWidget {
  final String questId;

  const QuestDetailScreen({super.key, required this.questId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questAsync = ref.watch(questDetailProvider(questId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: edit quest
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Quest'),
                  content:
                      const Text('Are you sure you want to delete this quest?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref
                    .read(questRepositoryProvider)
                    .deleteQuest(questId);
                ref.read(questListProvider.notifier).removeQuest(questId);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: questAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => ErrorDisplay(
          message: e.toString(),
          onRetry: () => ref.invalidate(questDetailProvider(questId)),
        ),
        data: (quest) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quest.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (quest.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  quest.description!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 8),
              Chip(
                label: Text(quest.status),
                backgroundColor: AppColors.primary.withAlpha(25),
              ),
              if (quest.totalTaskCount > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: quest.progress,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  '${quest.completedTaskCount}/${quest.totalTaskCount} tasks completed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Tasks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              if (quest.tasks == null || quest.tasks!.isEmpty)
                const EmptyState(
                  message: 'No tasks yet',
                  icon: Icons.checklist,
                )
              else
                ...quest.tasks!.map((task) => CheckboxListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: task.description != null
                          ? Text(task.description!)
                          : null,
                      value: task.isCompleted,
                      onChanged: (val) async {
                        await ref.read(questRepositoryProvider).updateTask(
                              questId,
                              task.id,
                              {'isCompleted': val},
                            );
                        ref.invalidate(questDetailProvider(questId));
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
