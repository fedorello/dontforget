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
import '../../../../features/profiles/presentation/cubit/profiles_cubit.dart';
import '../../../../shared/widgets/df_card.dart';
import '../../../../shared/widgets/df_button.dart';
import '../../../../shared/widgets/df_loading.dart';

class MedicineDetailPage extends StatelessWidget {
  final String id;
  const MedicineDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<MedicinesCubit>();
        final profile = context.read<ProfilesCubit>().defaultProfile;
        if (profile != null) cubit.loadMedicines(profile.id);
        return cubit;
      },
      child: _MedicineDetailView(id: id),
    );
  }
}

class _MedicineDetailView extends StatelessWidget {
  final String id;
  const _MedicineDetailView({required this.id});

  ProfileMedicine? _findMedicine(MedicinesState state) {
    List<ProfileMedicine> list = [];
    if (state is MedicinesLoaded) list = state.profileMedicines;
    if (state is MedicinesError) list = state.profileMedicines;
    try {
      return list.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
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
        title: Text(l10n.nav_medicines, style: AppTextStyles.heading3),
        actions: [
          IconButton(
            onPressed: () async {
              final state = context.read<MedicinesCubit>().state;
              final med = _findMedicine(state);
              if (med == null) return;
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
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<MedicinesCubit>().deleteMedicine(id);
                if (context.mounted) context.pop();
              }
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: l10n.delete,
          ),
        ],
      ),
      body: BlocBuilder<MedicinesCubit, MedicinesState>(
        builder: (context, state) {
          if (state is MedicinesLoading) return const DfLoading();

          final medicine = _findMedicine(state);
          if (medicine == null) {
            return Center(
              child: Text(l10n.error_generic, style: AppTextStyles.body2),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                DfCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: medicine.isActive
                                  ? AppColors.primaryLight
                                  : AppColors.surfaceVariant,
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusM),
                            ),
                            child: Icon(
                              Icons.medication,
                              size: 28,
                              color: medicine.isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicine.medicineName,
                                  style: AppTextStyles.heading2,
                                ),
                                Text(
                                  medicine.dose,
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: medicine.isActive,
                            onChanged: (v) => context
                                .read<MedicinesCubit>()
                                .toggleActive(id, v),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),

                // Details
                DfCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.repeat,
                        label: l10n.medicine_frequency,
                        value: l10n.per_day(medicine.frequencyPerDay),
                      ),
                      if (medicine.timesJson.isNotEmpty) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.access_time,
                          label: l10n.medicine_timing,
                          value: medicine.timesJson.join(', '),
                        ),
                      ],
                      if (medicine.courseDays != null) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: l10n.medicine_course,
                          value: l10n.days_short(medicine.courseDays!),
                        ),
                      ],
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.event,
                        label: 'Start date',
                        value:
                            '${medicine.startDate.day}.${medicine.startDate.month}.${medicine.startDate.year}',
                      ),
                      if (medicine.notes != null &&
                          medicine.notes!.isNotEmpty) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.note_outlined,
                          label: 'Notes',
                          value: medicine.notes!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),

                // Units remaining
                if (medicine.totalUnits != null && medicine.totalUnits! > 0) ...[
                  DfCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Units', style: AppTextStyles.label),
                            Text(
                              l10n.units_remaining(
                                  medicine.unitsRemaining ?? 0),
                              style: AppTextStyles.body2
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusS),
                          child: LinearProgressIndicator(
                            value: medicine.totalUnits! > 0
                                ? (medicine.unitsRemaining ?? 0) /
                                    medicine.totalUnits!
                                : 0.0,
                            minHeight: 8,
                            backgroundColor: AppColors.surfaceVariant,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                ],

                // Mark taken button
                if (medicine.isActive)
                  DfButton(
                    label: l10n.taken,
                    icon: Icons.check_circle_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${medicine.medicineName} marked as taken'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body1),
            ],
          ),
        ),
      ],
    );
  }
}
