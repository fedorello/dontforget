import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../cubit/dashboard_cubit.dart';
import '../../../profiles/presentation/cubit/profiles_cubit.dart';
import '../../../todos/domain/entities/todo.dart';
import '../../../../shared/widgets/df_card.dart';
import '../../../../shared/widgets/df_loading.dart';
import '../../../../main.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<DashboardCubit>();
        final profile = context.read<ProfilesCubit>().defaultProfile;
        if (profile != null) cubit.load(profile.id, profile.name);
        return cubit;
      },
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  String _greeting(AppL10n l10n, String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greeting_morning(name);
    if (hour < 18) return l10n.greeting_afternoon(name);
    return l10n.greeting_evening(name);
  }

  Future<void> _refresh(BuildContext context) async {
    final profile = context.read<ProfilesCubit>().defaultProfile;
    if (profile != null) {
      await context.read<DashboardCubit>().load(profile.id, profile.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: BlocBuilder<ProfilesCubit, ProfilesState>(
          builder: (context, state) {
            final name = state is ProfilesLoaded && state.profiles.isNotEmpty
                ? (() {
                    try {
                      return state.profiles.firstWhere((p) => p.isDefault).name;
                    } catch (_) {
                      return state.profiles.first.name;
                    }
                  })()
                : '';
            return Text(
              name.isNotEmpty ? _greeting(l10n, name) : 'DontForget',
              style: AppTextStyles.heading3,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/profiles'),
            icon: const Icon(Icons.manage_accounts_outlined),
            tooltip: l10n.profiles_title,
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return DfLoading(message: l10n.loading);
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: AppTextStyles.body2),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _refresh(context),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingM,
                  AppConstants.paddingS,
                  AppConstants.paddingM,
                  100,
                ),
                children: [
                  // Take now section
                  _SectionHeader(title: l10n.take_now),
                  const SizedBox(height: AppConstants.paddingS),
                  if (state.scheduleItems.isEmpty)
                    _EmptyCard(
                      icon: Icons.check_circle_outline,
                      message: l10n.no_medicines_today,
                      color: AppColors.success,
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.scheduleItems.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final item = state.scheduleItems[i];
                          return _ScheduleCard(
                            item: item,
                            onTaken: () {
                              final logId = item['log_id'] as String?;
                              if (logId != null) {
                                context.read<DashboardCubit>().markIntake(
                                    logId, AppConstants.statusTaken);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppConstants.paddingL),

                  // Today's tasks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionHeader(title: l10n.todos_title),
                      TextButton(
                        onPressed: () => context.go('/todos'),
                        child: Text(
                          'See all',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  if (state.todayTodos.isEmpty)
                    _EmptyCard(
                      icon: Icons.task_alt,
                      message: l10n.empty_state_todos,
                      color: AppColors.secondary,
                    )
                  else
                    ...state.todayTodos.take(3).map(
                          (todo) => _TodoPreviewTile(todo: todo),
                        ),
                  if (state.todayTodos.length > 3) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/todos'),
                        child: Text(
                          '+ ${state.todayTodos.length - 3} more',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.paddingL),

                  // Language switcher
                  DfCard(
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(l10n.settings_language, style: AppTextStyles.body1),
                        const Spacer(),
                        _LangButton(
                          label: 'RU',
                          onTap: () =>
                              LocaleNotifier.of(context)?.onLocaleChange('ru'),
                        ),
                        const SizedBox(width: 8),
                        _LangButton(
                          label: 'EN',
                          onTap: () =>
                              LocaleNotifier.of(context)?.onLocaleChange('en'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.heading3);
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyCard({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DfCard(
      color: color.withOpacity(0.08),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: AppTextStyles.body2),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTaken;

  const _ScheduleCard({required this.item, required this.onTaken});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;
    final status = item['status'] as String? ?? AppConstants.statusPending;
    final isTaken = status == AppConstants.statusTaken;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: isTaken ? AppColors.successLight : AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: isTaken ? AppColors.success : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isTaken ? Icons.check_circle : Icons.medication_outlined,
                size: 18,
                color: isTaken ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                item['scheduled_time'] as String? ?? '',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['medicine_name'] as String? ?? '',
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (!isTaken)
            SizedBox(
              width: double.infinity,
              height: 28,
              child: FilledButton(
                onPressed: onTaken,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
                child: Text(l10n.taken,
                    style: const TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}

class _TodoPreviewTile extends StatelessWidget {
  final Todo todo;
  const _TodoPreviewTile({required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(
        todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: todo.isDone ? AppColors.success : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        todo.text,
        style: AppTextStyles.body1.copyWith(
          decoration: todo.isDone ? TextDecoration.lineThrough : null,
          color: todo.isDone ? AppColors.textSecondary : AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: todo.priority >= 1
          ? const Icon(Icons.priority_high, size: 16, color: AppColors.warning)
          : null,
      dense: true,
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _LangButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
