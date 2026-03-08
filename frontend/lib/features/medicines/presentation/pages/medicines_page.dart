import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../cubit/medicines_cubit.dart';
import '../../domain/entities/medicine.dart';
import '../widgets/medicine_card.dart';
import '../../../../features/profiles/presentation/cubit/profiles_cubit.dart';
import '../../../../shared/widgets/df_empty_state.dart';
import '../../../../shared/widgets/df_loading.dart';

class MedicinesPage extends StatelessWidget {
  const MedicinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<MedicinesCubit>();
        final profilesCubit = context.read<ProfilesCubit>();
        final profile = profilesCubit.defaultProfile;
        if (profile != null) {
          cubit.loadMedicines(profile.id);
        }
        return cubit;
      },
      child: const _MedicinesView(),
    );
  }
}

class _MedicinesView extends StatelessWidget {
  const _MedicinesView();

  String _profileName(BuildContext context) {
    final state = context.watch<ProfilesCubit>().state;
    if (state is ProfilesLoaded && state.profiles.isNotEmpty) {
      try {
        return state.profiles.firstWhere((p) => p.isDefault).name;
      } catch (_) {
        return state.profiles.first.name;
      }
    }
    return '';
  }

  Future<void> _refresh(BuildContext context) async {
    final profilesCubit = context.read<ProfilesCubit>();
    final profile = profilesCubit.defaultProfile;
    if (profile != null) {
      await context.read<MedicinesCubit>().loadMedicines(profile.id);
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
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
      context.read<MedicinesCubit>().deleteMedicine(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;
    final profileName = _profileName(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.nav_medicines, style: AppTextStyles.heading3),
            if (profileName.isNotEmpty)
              GestureDetector(
                onTap: () => context.push('/profiles'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profileName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/profiles'),
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.profiles_title,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/medicines/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.add_medicine),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: BlocBuilder<MedicinesCubit, MedicinesState>(
        builder: (context, state) {
          if (state is MedicinesLoading) {
            return DfLoading(message: l10n.loading);
          }

          if (state is MedicinesError && state.profileMedicines.isEmpty) {
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

          final medicines = state is MedicinesLoaded
              ? state.profileMedicines
              : state is MedicinesError
                  ? state.profileMedicines
                  : <ProfileMedicine>[];

          if (medicines.isEmpty) {
            return DfEmptyState(
              emoji: '💊',
              message: l10n.empty_state_medicines,
              actionLabel: l10n.add_medicine,
              onAction: () => context.push('/medicines/add'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingM,
                AppConstants.paddingM,
                100,
              ),
              itemCount: medicines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final medicine = medicines[i];
                return MedicineCard(
                  medicine: medicine,
                  onTap: () => context.push('/medicines/${medicine.id}'),
                  onDelete: () => _confirmDelete(context, medicine.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
