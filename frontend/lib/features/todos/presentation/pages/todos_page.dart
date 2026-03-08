import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../cubit/todos_cubit.dart';
import '../../domain/entities/todo.dart';
import '../../../../features/profiles/presentation/cubit/profiles_cubit.dart';
import '../../../../shared/widgets/df_empty_state.dart';
import '../../../../shared/widgets/df_loading.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<TodosCubit>();
        final profile = context.read<ProfilesCubit>().defaultProfile;
        if (profile != null) cubit.loadTodos(profile.id);
        return cubit;
      },
      child: const _TodosView(),
    );
  }
}

class _TodosView extends StatelessWidget {
  const _TodosView();

  static const _filters = ['all', 'today', 'week', 'done'];

  String _filterLabel(AppL10n l10n, String f) {
    switch (f) {
      case 'today':
        return l10n.todo_filter_today;
      case 'week':
        return l10n.todo_filter_week;
      case 'done':
        return l10n.todo_filter_done;
      default:
        return l10n.todo_filter_all;
    }
  }

  Future<void> _showAddSheet(BuildContext context, AppL10n l10n) async {
    final textCtrl = TextEditingController();
    DateTime? dueAt;
    int priority = 0;

    final profile = context.read<ProfilesCubit>().defaultProfile;
    if (profile == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: AppConstants.paddingM,
            right: AppConstants.paddingM,
            top: AppConstants.paddingM,
            bottom:
                MediaQuery.of(ctx).viewInsets.bottom + AppConstants.paddingM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.todo_add, style: AppTextStyles.heading3),
              const SizedBox(height: AppConstants.paddingM),
              TextField(
                controller: textCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.todo_add,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: AppConstants.paddingM),

              // Priority toggle
              Row(
                children: [
                  const Icon(Icons.priority_high,
                      size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Text(l10n.todo_priority_high, style: AppTextStyles.body2),
                  const Spacer(),
                  Switch(
                    value: priority == 1,
                    onChanged: (v) => setState(() => priority = v ? 1 : 0),
                    activeColor: AppColors.warning,
                  ),
                ],
              ),

              // Due date picker
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    dueAt != null
                        ? '${dueAt!.day}.${dueAt!.month}.${dueAt!.year}'
                        : l10n.todo_set_reminder,
                    style: AppTextStyles.body2,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => dueAt = picked);
                    },
                    child: Text(l10n.edit),
                  ),
                  if (dueAt != null)
                    TextButton(
                      onPressed: () => setState(() => dueAt = null),
                      child: const Text('×'),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingM),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (textCtrl.text.trim().isEmpty) return;
                      context.read<TodosCubit>().createTodo(
                            profile.id,
                            textCtrl.text.trim(),
                            dueAt: dueAt,
                            priority: priority,
                          );
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n.todos_title, style: AppTextStyles.heading3),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, l10n),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filter chips
          BlocBuilder<TodosCubit, TodosState>(
            builder: (context, state) {
              final currentFilter =
                  state is TodosLoaded ? state.filter : 'all';
              return SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM,
                    vertical: 8,
                  ),
                  children: _filters.map((f) {
                    final selected = currentFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filterLabel(l10n, f)),
                        selected: selected,
                        onSelected: (_) =>
                            context.read<TodosCubit>().changeFilter(f),
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTextStyles.body2.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        backgroundColor: AppColors.surfaceVariant,
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // Todo list
          Expanded(
            child: BlocBuilder<TodosCubit, TodosState>(
              builder: (context, state) {
                if (state is TodosLoading) return const DfLoading();

                if (state is TodosError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message, style: AppTextStyles.body2),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            final profile = context
                                .read<ProfilesCubit>()
                                .defaultProfile;
                            if (profile != null) {
                              context
                                  .read<TodosCubit>()
                                  .loadTodos(profile.id);
                            }
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TodosLoaded) {
                  if (state.todos.isEmpty) {
                    return DfEmptyState(
                      emoji: '✅',
                      message: l10n.todo_empty,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final profile = context
                          .read<ProfilesCubit>()
                          .defaultProfile;
                      if (profile != null) {
                        await context
                            .read<TodosCubit>()
                            .loadTodos(profile.id, filter: state.filter);
                      }
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 100,
                        top: AppConstants.paddingS,
                      ),
                      itemCount: state.todos.length,
                      itemBuilder: (context, i) {
                        final todo = state.todos[i];
                        return _TodoTile(
                          todo: todo,
                          onToggle: (v) => context
                              .read<TodosCubit>()
                              .toggleDone(todo.id, v),
                          onDelete: () => context
                              .read<TodosCubit>()
                              .deleteTodo(todo.id),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _TodoTile({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.paddingM),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          border: todo.priority >= 1
              ? const Border(
                  left: BorderSide(color: AppColors.warning, width: 4),
                )
              : null,
        ),
        child: ListTile(
          leading: Checkbox(
            value: todo.isDone,
            onChanged: (v) => onToggle(v ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
          ),
          title: Text(
            todo.text,
            style: AppTextStyles.body1.copyWith(
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              color: todo.isDone
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
          subtitle: todo.dueAt != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${todo.dueAt!.day}.${todo.dueAt!.month}.${todo.dueAt!.year}',
                        style: AppTextStyles.caption.copyWith(
                          color: _isDue(todo.dueAt!)
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          trailing: todo.priority >= 1
              ? const Icon(Icons.priority_high,
                  size: 18, color: AppColors.warning)
              : null,
        ),
      ),
    );
  }

  bool _isDue(DateTime dueAt) {
    final now = DateTime.now();
    return dueAt.isBefore(DateTime(now.year, now.month, now.day));
  }
}
