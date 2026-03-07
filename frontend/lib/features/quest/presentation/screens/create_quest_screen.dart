import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/quest_provider.dart';

class CreateQuestScreen extends ConsumerStatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  ConsumerState<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends ConsumerState<CreateQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final List<TextEditingController> _taskControllers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    for (final c in _taskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTask() {
    setState(() => _taskControllers.add(TextEditingController()));
  }

  void _removeTask(int index) {
    setState(() {
      _taskControllers[index].dispose();
      _taskControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final tasks = _taskControllers
          .where((c) => c.text.trim().isNotEmpty)
          .map((c) => {'title': c.text.trim()})
          .toList();

      await ref
          .read(questRepositoryProvider)
          .createQuest(
            title: _titleC.text.trim(),
            description: _descC.text.trim().isNotEmpty
                ? _descC.text.trim()
                : null,
            tasks: tasks.isNotEmpty ? tasks : null,
          );

      ref.read(questListProvider.notifier).refresh();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Quest')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _titleC,
                label: 'Quest Title',
                hint: 'What\'s this quest about?',
                validator: (v) => v != null && v.trim().isNotEmpty
                    ? null
                    : 'Title is required',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descC,
                label: 'Description',
                hint: 'Optional description...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tasks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addTask,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._taskControllers.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: entry.value,
                          hint: 'Task ${entry.key + 1}',
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.error),
                        onPressed: () => _removeTask(entry.key),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              AppButton(
                label: 'Create Quest',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
