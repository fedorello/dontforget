import '../../domain/entities/medicine.dart';

class MedicineKBModel extends MedicineKB {
  const MedicineKBModel({
    required super.id,
    required super.nameTrade,
    super.nameGeneric,
    super.dosagePerUnit,
    super.actionSimple,
    required super.form,
    required super.category,
    required super.substance,
    required super.sideEffectsTop,
    required super.interactionsCaution,
    required super.interactionsAvoid,
    required super.contraindications,
    required super.recommendedDose,
    required super.createdAt,
  });

  factory MedicineKBModel.fromJson(Map<String, dynamic> json) {
    List<String> _strings(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return MedicineKBModel(
      id: json['id'] as String? ?? '',
      nameTrade: json['name_trade'] as String? ?? json['name'] as String? ?? '',
      nameGeneric: json['name_generic'] as String?,
      dosagePerUnit: json['dosage_per_unit'] as String?,
      actionSimple: json['action_simple'] as String?,
      form: json['form'] as String? ?? '',
      category: json['category'] as String? ?? '',
      substance: _strings(json['substance']),
      sideEffectsTop: _strings(json['side_effects_top']),
      interactionsCaution: _strings(json['interactions_caution']),
      interactionsAvoid: _strings(json['interactions_avoid']),
      contraindications: _strings(json['contraindications']),
      recommendedDose: (json['recommended_dose'] as Map<String, dynamic>?) ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class ProfileMedicineModel extends ProfileMedicine {
  const ProfileMedicineModel({
    required super.id,
    required super.profileId,
    required super.medicineKbId,
    required super.medicineName,
    required super.dose,
    required super.frequencyPerDay,
    required super.timesJson,
    super.courseDays,
    super.totalUnits,
    super.unitsRemaining,
    required super.unitsTaken,
    required super.startDate,
    required super.createdAt,
    super.endDate,
    super.notes,
    required super.isActive,
  });

  factory ProfileMedicineModel.fromJson(Map<String, dynamic> json) {
    List<String> _strings(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return ProfileMedicineModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      medicineKbId: json['medicine_kb_id'] as String? ?? '',
      medicineName: json['medicine_name'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      frequencyPerDay: json['frequency_per_day'] as int? ?? 1,
      timesJson: _strings(json['times_json']),
      courseDays: json['course_days'] as int?,
      totalUnits: json['total_units'] as int?,
      unitsRemaining: json['units_remaining'] as int?,
      unitsTaken: json['units_taken'] as int? ?? 0,
      startDate: DateTime.parse(json['start_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
