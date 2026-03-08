import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/profiles_cubit.dart';
import '../../domain/entities/profile.dart';
import '../../../../shared/widgets/df_button.dart';

class ProfileFormPage extends StatefulWidget {
  final String? profileId;
  const ProfileFormPage({super.key, this.profileId});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController(text: '👤');
  final _weightCtrl = TextEditingController();
  final _healthNotesCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  bool _isDefault = false;
  bool _loading = false;

  Profile? _existingProfile;

  @override
  void initState() {
    super.initState();
    if (widget.profileId != null) {
      _loadExisting();
    }
  }

  void _loadExisting() {
    final state = context.read<ProfilesCubit>().state;
    if (state is ProfilesLoaded) {
      try {
        _existingProfile = state.profiles.firstWhere((p) => p.id == widget.profileId);
        _nameCtrl.text = _existingProfile!.name;
        _avatarCtrl.text = _existingProfile!.avatarEmoji;
        _birthDate = _existingProfile!.birthDate;
        _gender = _existingProfile!.gender;
        _weightCtrl.text = _existingProfile!.weightKg?.toString() ?? '';
        _healthNotesCtrl.text = _existingProfile!.healthNotes ?? '';
        _allergiesCtrl.text = _existingProfile!.allergies ?? '';
        _isDefault = _existingProfile!.isDefault;
        setState(() {});
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _avatarCtrl.dispose();
    _weightCtrl.dispose();
    _healthNotesCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'avatar_emoji': _avatarCtrl.text.trim().isEmpty ? '👤' : _avatarCtrl.text.trim(),
      if (_birthDate != null)
        'birth_date': _birthDate!.toIso8601String().substring(0, 10),
      if (_gender != null) 'gender': _gender,
      if (_weightCtrl.text.trim().isNotEmpty)
        'weight_kg': double.tryParse(_weightCtrl.text.trim()),
      if (_healthNotesCtrl.text.trim().isNotEmpty)
        'health_notes': _healthNotesCtrl.text.trim(),
      if (_allergiesCtrl.text.trim().isNotEmpty)
        'allergies': _allergiesCtrl.text.trim(),
      'is_default': _isDefault,
    };

    final cubit = context.read<ProfilesCubit>();
    if (widget.profileId != null) {
      await cubit.updateProfile(widget.profileId!, data);
    } else {
      await cubit.createProfile(data);
    }

    if (mounted) {
      setState(() => _loading = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;
    final isEdit = widget.profileId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          isEdit ? l10n.edit : l10n.add_profile,
          style: AppTextStyles.heading3,
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            // Avatar emoji
            Center(
              child: GestureDetector(
                onTap: _showEmojiPicker,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _avatarCtrl.text.isEmpty ? '👤' : _avatarCtrl.text,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _showEmojiPicker,
                child: Text(
                  'Change emoji',
                  style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.profile_name),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppConstants.paddingM),

            // Birth date
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.profile_birth_date,
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                ),
                child: Text(
                  _birthDate != null
                      ? '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}'
                      : '',
                  style: AppTextStyles.body1,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),

            // Gender
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(labelText: l10n.profile_gender),
              items: [
                DropdownMenuItem(
                  value: 'male',
                  child: Text(l10n.profile_gender_male),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text(l10n.profile_gender_female),
                ),
              ],
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: AppConstants.paddingM),

            // Weight
            TextFormField(
              controller: _weightCtrl,
              decoration: InputDecoration(
                labelText: l10n.profile_weight,
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  if (double.tryParse(v.trim()) == null) return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.paddingM),

            // Health notes
            TextFormField(
              controller: _healthNotesCtrl,
              decoration: InputDecoration(labelText: l10n.profile_health_notes),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppConstants.paddingM),

            // Allergies
            TextFormField(
              controller: _allergiesCtrl,
              decoration: InputDecoration(labelText: l10n.profile_allergies),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppConstants.paddingM),

            // Is default
            SwitchListTile(
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              title: const Text('Default profile'),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppConstants.paddingL),

            DfButton(
              label: l10n.save,
              isLoading: _loading,
              onTap: _save,
            ),
            const SizedBox(height: AppConstants.paddingM),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    final emojis = [
      '👤', '😊', '👨', '👩', '👶', '🧒', '👦', '👧', '🧑', '👱',
      '🧔', '👴', '👵', '🧓', '💪', '🧘', '🏃', '🎅', '🤶', '👼',
    ];
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose avatar', style: AppTextStyles.heading3),
              const SizedBox(height: AppConstants.paddingM),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: emojis.map((e) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _avatarCtrl.text = e);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _avatarCtrl.text == e
                            ? AppColors.primaryLight
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: _avatarCtrl.text == e
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.paddingM),
            ],
          ),
        ),
      ),
    );
  }
}
