import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/medicine.dart';
import '../../../../shared/widgets/df_card.dart';

class MedicineCard extends StatelessWidget {
  final ProfileMedicine medicine;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? compatibilityStatus;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTap,
    this.onDelete,
    this.compatibilityStatus,
  });

  Color get _compatColor {
    switch (compatibilityStatus) {
      case AppConstants.compatOk:
        return AppColors.compatOk;
      case AppConstants.compatCaution:
        return AppColors.compatCaution;
      case AppConstants.compatDanger:
        return AppColors.compatDanger;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(medicine.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        if (onDelete != null) {
          onDelete!();
          return false; // Let the cubit handle the list update
        }
        return false;
      },
      child: DfCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Row(
          children: [
            // Compatibility dot
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: AppConstants.paddingM),
              decoration: BoxDecoration(
                color: _compatColor,
                shape: BoxShape.circle,
              ),
            ),

            // Medicine icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: medicine.isActive
                    ? AppColors.primaryLight
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(
                Icons.medication_outlined,
                color: medicine.isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicineName,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: medicine.isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medicine.dose,
                    style: AppTextStyles.body2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (medicine.timesJson.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          medicine.timesJson.join(', '),
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Right side: frequency + active indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    '${medicine.frequencyPerDay}x/day',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!medicine.isActive) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Text(
                      'Paused',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
