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
import '../../../../shared/widgets/df_button.dart';
import '../../../../shared/widgets/df_card.dart';

enum _InputMethod { byName, byPhoto }

class AddMedicinePage extends StatelessWidget {
  const AddMedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicinesCubit>(),
      child: const _AddMedicineView(),
    );
  }
}

class _AddMedicineView extends StatefulWidget {
  const _AddMedicineView();

  @override
  State<_AddMedicineView> createState() => _AddMedicineViewState();
}

class _AddMedicineViewState extends State<_AddMedicineView> {
  _InputMethod _method = _InputMethod.byName;
  int _step = 1;

  // Step 1
  final _nameCtrl = TextEditingController();
  String? _photoFileName;
  String? _photoBase64;
  String _photoMimeType = 'image/jpeg';

  // Step 2 - editable fields
  final _doseCtrl = TextEditingController();
  final _freqCtrl = TextEditingController(text: '1');
  final _timesCtrl = TextEditingController(text: '09:00');
  final _courseDaysCtrl = TextEditingController();

  MedicineKB? _analyzed;
  String? _selectedProfileId;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfilesCubit>().defaultProfile;
    _selectedProfileId = profile?.id;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _freqCtrl.dispose();
    _timesCtrl.dispose();
    _courseDaysCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final cubit = context.read<MedicinesCubit>();
    MedicineKB? result;

    if (_method == _InputMethod.byName) {
      if (_nameCtrl.text.trim().isEmpty) return;
      result = await cubit.analyzeByName(_nameCtrl.text.trim());
    } else {
      if (_photoBase64 == null) return;
      result = await cubit.analyzeByPhoto(_photoBase64!, _photoMimeType);
    }

    if (result != null && mounted) {
      setState(() {
        _analyzed = result;
        _step = 2;
        // Pre-fill from recommendation
        final rec = result!.recommendedDose;
        _doseCtrl.text = result.dosagePerUnit ?? '';
        _freqCtrl.text = (rec['frequency_per_day'] ?? 1).toString();
        _courseDaysCtrl.text = (rec['course_days'] ?? '').toString();
        final times = rec['times'];
        if (times is List && times.isNotEmpty) {
          _timesCtrl.text = times.join(', ');
        }
      });
    }
  }

  Future<void> _startReminders() async {
    if (_selectedProfileId == null || _analyzed == null) return;

    final times = _timesCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final data = {
      'profile_id': _selectedProfileId,
      'medicine_kb_id': _analyzed!.id,
      'medicine_name': _analyzed!.nameTrade,
      'dose': _doseCtrl.text.trim(),
      'frequency_per_day': int.tryParse(_freqCtrl.text.trim()) ?? 1,
      'times_json': times,
      if (_courseDaysCtrl.text.trim().isNotEmpty)
        'course_days': int.tryParse(_courseDaysCtrl.text.trim()),
      'start_date': DateTime.now().toIso8601String().substring(0, 10),
      'is_active': true,
    };

    await context.read<MedicinesCubit>().addToProfile(data);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;

    return BlocListener<MedicinesCubit, MedicinesState>(
      listener: (context, state) {
        if (state is MedicinesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: BackButton(
            onPressed: () {
              if (_step == 2) {
                setState(() {
                  _step = 1;
                  _analyzed = null;
                  context.read<MedicinesCubit>().clearAnalyzed();
                });
              } else {
                context.pop();
              }
            },
          ),
          title: Text(
            _step == 1 ? l10n.add_medicine : l10n.start_reminders,
            style: AppTextStyles.heading3,
          ),
        ),
        body: BlocBuilder<MedicinesCubit, MedicinesState>(
          builder: (context, state) {
            final isLoading = state is MedicinesAnalyzing;

            if (_step == 1) {
              return _buildStep1(context, l10n, isLoading);
            }
            return _buildStep2(context, l10n, state);
          },
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, AppL10n l10n, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method selector
          Row(
            children: [
              Expanded(
                child: _MethodTab(
                  label: l10n.add_medicine_by_name,
                  icon: Icons.text_fields,
                  selected: _method == _InputMethod.byName,
                  onTap: () => setState(() => _method = _InputMethod.byName),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MethodTab(
                  label: l10n.add_medicine_by_photo,
                  icon: Icons.camera_alt_outlined,
                  selected: _method == _InputMethod.byPhoto,
                  onTap: () => setState(() => _method = _InputMethod.byPhoto),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),

          if (_method == _InputMethod.byName) ...[
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: l10n.medicine_name_hint,
                prefixIcon: const Icon(Icons.medication_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => isLoading ? null : _analyze(),
            ),
          ] else ...[
            DfCard(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                children: [
                  const Icon(Icons.camera_alt_outlined,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'Photo capture available on mobile',
                    style: AppTextStyles.body2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'On web, please use the name search instead.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  if (_photoFileName != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _photoFileName!,
                      style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingL),

          DfButton(
            label: isLoading ? l10n.analyzing : l10n.add_medicine,
            isLoading: isLoading,
            icon: Icons.search,
            onTap: isLoading ? null : _analyze,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(
      BuildContext context, AppL10n l10n, MedicinesState state) {
    final profiles = context.watch<ProfilesCubit>().state;
    final profileList = profiles is ProfilesLoaded ? profiles.profiles : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine info card
          if (_analyzed != null) ...[
            DfCard(
              color: AppColors.primaryLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medication,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _analyzed!.nameTrade,
                          style: AppTextStyles.heading3,
                        ),
                      ),
                    ],
                  ),
                  if (_analyzed!.nameGeneric != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _analyzed!.nameGeneric!,
                      style: AppTextStyles.body2,
                    ),
                  ],
                  if (_analyzed!.actionSimple != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.medicine_what_it_does,
                      style: AppTextStyles.label,
                    ),
                    Text(
                      _analyzed!.actionSimple!,
                      style: AppTextStyles.body2,
                    ),
                  ],
                  if (_analyzed!.recommendedDose.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(l10n.medicine_timing, style: AppTextStyles.label),
                    Text(
                      _analyzed!.recommendedDose['timing'] as String? ?? '',
                      style: AppTextStyles.body2,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
          ],

          // Editable fields
          Text(l10n.medicine_dose, style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _doseCtrl,
            decoration: InputDecoration(
              hintText: '500mg',
              prefixIcon: const Icon(Icons.scale_outlined),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          Text(l10n.medicine_frequency, style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _freqCtrl,
            decoration: const InputDecoration(
              hintText: '1',
              suffixText: 'x/day',
              prefixIcon: Icon(Icons.repeat),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppConstants.paddingM),

          Text(l10n.medicine_timing, style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _timesCtrl,
            decoration: const InputDecoration(
              hintText: '09:00, 21:00',
              prefixIcon: Icon(Icons.access_time),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          Text(l10n.medicine_course, style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _courseDaysCtrl,
            decoration: InputDecoration(
              hintText: '30',
              suffixText: 'days',
              prefixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Profile selector
          if (profileList.isNotEmpty) ...[
            Text(l10n.profile_title, style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedProfileId,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: profileList
                  .map((p) => DropdownMenuItem<String>(
                        value: p.id,
                        child: Text('${p.avatarEmoji} ${p.name}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedProfileId = v),
            ),
            const SizedBox(height: AppConstants.paddingL),
          ],

          DfButton(
            label: l10n.start_reminders,
            icon: Icons.alarm_add,
            onTap: _startReminders,
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
