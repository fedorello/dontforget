import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/profiles_cubit.dart';
import '../../domain/entities/profile.dart';
import '../../../../shared/widgets/df_card.dart';
import '../../../../shared/widgets/df_empty_state.dart';
import '../../../../shared/widgets/df_loading.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfilesCubit>().loadProfiles();
  }

  Future<void> _confirmDelete(BuildContext context, Profile profile) async {
    final l10n = AppL10n.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.confirm_delete),
        content: Text(l10n.confirm_delete_message),
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
      context.read<ProfilesCubit>().deleteProfile(profile.id);
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
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.profiles_title, style: AppTextStyles.heading3),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/profiles/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.add_profile),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: BlocBuilder<ProfilesCubit, ProfilesState>(
        builder: (context, state) {
          if (state is ProfilesLoading) {
            return const DfLoading();
          }
          if (state is ProfilesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: AppTextStyles.body2),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<ProfilesCubit>().loadProfiles(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          if (state is ProfilesLoaded) {
            if (state.profiles.isEmpty) {
              return DfEmptyState(
                emoji: '👤',
                message: l10n.add_profile,
                actionLabel: l10n.add_profile,
                onAction: () => context.push('/profiles/new'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingM,
                AppConstants.paddingM,
                100,
              ),
              itemCount: state.profiles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final profile = state.profiles[i];
                return _ProfileCard(
                  profile: profile,
                  onEdit: () => context.push('/profiles/${profile.id}/edit'),
                  onDelete: () => _confirmDelete(context, profile),
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

class _ProfileCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProfileCard({
    required this.profile,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;

    return DfCard(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(
              child: Text(
                profile.avatarEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(profile.name, style: AppTextStyles.heading3),
                    if (profile.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          'default',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (profile.age != null) ...[
                      Text('${profile.age} y.o.', style: AppTextStyles.body2),
                      const SizedBox(width: 8),
                    ],
                    if (profile.gender != null)
                      Text(
                        profile.gender == 'male'
                            ? l10n.profile_gender_male
                            : l10n.profile_gender_female,
                        style: AppTextStyles.body2,
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.textSecondary,
            tooltip: l10n.edit,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.error,
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }
}
