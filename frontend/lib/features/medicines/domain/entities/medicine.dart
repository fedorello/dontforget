class MedicineKB {
  final String id;
  final String nameTrade;
  final String? nameGeneric;
  final String? dosagePerUnit;
  final String? actionSimple;
  final String form;
  final String category;
  final List<String> substance;
  final List<String> sideEffectsTop;
  final List<String> interactionsCaution;
  final List<String> interactionsAvoid;
  final List<String> contraindications;
  final Map<String, dynamic> recommendedDose;
  final DateTime createdAt;

  const MedicineKB({
    required this.id,
    required this.nameTrade,
    this.nameGeneric,
    this.dosagePerUnit,
    this.actionSimple,
    required this.form,
    required this.category,
    required this.substance,
    required this.sideEffectsTop,
    required this.interactionsCaution,
    required this.interactionsAvoid,
    required this.contraindications,
    required this.recommendedDose,
    required this.createdAt,
  });
}

class ProfileMedicine {
  final String id;
  final String profileId;
  final String medicineKbId;
  final String medicineName;
  final String dose;
  final int frequencyPerDay;
  final List<String> timesJson;
  final int? courseDays;
  final int? totalUnits;
  final int? unitsRemaining;
  final int unitsTaken;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;

  const ProfileMedicine({
    required this.id,
    required this.profileId,
    required this.medicineKbId,
    required this.medicineName,
    required this.dose,
    required this.frequencyPerDay,
    required this.timesJson,
    this.courseDays,
    this.totalUnits,
    this.unitsRemaining,
    required this.unitsTaken,
    required this.startDate,
    required this.createdAt,
    this.endDate,
    this.notes,
    required this.isActive,
  });

  ProfileMedicine copyWith({
    bool? isActive,
    int? unitsRemaining,
  }) =>
      ProfileMedicine(
        id: id,
        profileId: profileId,
        medicineKbId: medicineKbId,
        medicineName: medicineName,
        dose: dose,
        frequencyPerDay: frequencyPerDay,
        timesJson: timesJson,
        courseDays: courseDays,
        totalUnits: totalUnits,
        unitsRemaining: unitsRemaining ?? this.unitsRemaining,
        unitsTaken: unitsTaken,
        startDate: startDate,
        createdAt: createdAt,
        endDate: endDate,
        notes: notes,
        isActive: isActive ?? this.isActive,
      );
}
