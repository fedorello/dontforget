import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../cubit/shopping_cubit.dart';
import '../../domain/entities/shopping.dart';
import '../../../../features/profiles/presentation/cubit/profiles_cubit.dart';
import '../../../../shared/widgets/df_card.dart';
import '../../../../shared/widgets/df_empty_state.dart';
import '../../../../shared/widgets/df_loading.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ShoppingCubit>();
        final profile = context.read<ProfilesCubit>().defaultProfile;
        if (profile != null) cubit.loadLists(profile.id);
        return cubit;
      },
      child: const _ShoppingView(),
    );
  }
}

class _ShoppingView extends StatelessWidget {
  const _ShoppingView();

  Future<void> _showCreateDialog(BuildContext context, AppL10n l10n) async {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '🛒';

    final emojis = ['🛒', '🥦', '🍎', '🥩', '🧴', '💊', '🏠', '👗', '📚', '🎁'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: AppConstants.paddingM,
            right: AppConstants.paddingM,
            top: AppConstants.paddingM,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppConstants.paddingM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.shopping_new_list, style: AppTextStyles.heading3),
              const SizedBox(height: AppConstants.paddingM),

              // Emoji row
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: emojis.map((e) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: selectedEmoji == e
                              ? AppColors.primaryLight
                              : AppColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(
                            color: selectedEmoji == e
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child:
                              Text(e, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),

              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: l10n.shopping_list_name,
                  prefixText: '$selectedEmoji  ',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
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
                      if (nameCtrl.text.trim().isEmpty) return;
                      final profileState =
                          context.read<ProfilesCubit>().state;
                      String? profileId;
                      if (profileState is ProfilesLoaded &&
                          profileState.profiles.isNotEmpty) {
                        try {
                          profileId = profileState.profiles
                              .firstWhere((p) => p.isDefault)
                              .id;
                        } catch (_) {
                          profileId = profileState.profiles.first.id;
                        }
                      }
                      if (profileId != null) {
                        context.read<ShoppingCubit>().createList(
                              profileId,
                              nameCtrl.text.trim(),
                              selectedEmoji,
                            );
                      }
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

  Future<void> _confirmDelete(
      BuildContext context, AppL10n l10n, ShoppingList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.confirm_delete),
        content: Text('"${list.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ShoppingCubit>().deleteList(list.id);
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
        title: Text(l10n.shopping_title, style: AppTextStyles.heading3),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.shopping_new_list),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: BlocBuilder<ShoppingCubit, ShoppingState>(
        builder: (context, state) {
          if (state is ShoppingLoading) return const DfLoading();

          if (state is ShoppingError) {
            return Center(child: Text(state.message, style: AppTextStyles.body2));
          }

          if (state is ShoppingLoaded) {
            if (state.lists.isEmpty) {
              return DfEmptyState(
                emoji: '🛒',
                message: l10n.shopping_empty,
                actionLabel: l10n.shopping_new_list,
                onAction: () => _showCreateDialog(context, l10n),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingM,
                AppConstants.paddingM,
                100,
              ),
              itemCount: state.lists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final list = state.lists[i];
                return _ShoppingListCard(
                  list: list,
                  onTap: () => context.push('/shopping/${list.id}'),
                  onLongPress: () => _confirmDelete(context, l10n, list),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ShoppingListCard extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ShoppingListCard({
    required this.list,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final progress = list.itemCount > 0 ? list.doneCount / list.itemCount : 0.0;

    return DfCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Center(
                child: Text(list.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(list.name, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${list.doneCount}/${list.itemCount} items',
                        style: AppTextStyles.body2,
                      ),
                      if (list.itemCount > 0 && list.doneCount == list.itemCount) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle,
                            size: 14, color: AppColors.success),
                      ],
                    ],
                  ),
                  if (list.itemCount > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceVariant,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
