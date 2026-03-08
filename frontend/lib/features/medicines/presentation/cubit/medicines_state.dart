part of 'medicines_cubit.dart';

abstract class MedicinesState extends Equatable {
  const MedicinesState();
  @override
  List<Object?> get props => [];
}

class MedicinesInitial extends MedicinesState {}

class MedicinesLoading extends MedicinesState {}

class MedicinesLoaded extends MedicinesState {
  final List<ProfileMedicine> profileMedicines;
  final MedicineKB? analyzedMedicine;
  final Map<String, dynamic>? compatibilityResult;

  const MedicinesLoaded({
    required this.profileMedicines,
    this.analyzedMedicine,
    this.compatibilityResult,
  });

  MedicinesLoaded copyWith({
    List<ProfileMedicine>? profileMedicines,
    MedicineKB? analyzedMedicine,
    Map<String, dynamic>? compatibilityResult,
    bool clearAnalyzed = false,
  }) =>
      MedicinesLoaded(
        profileMedicines: profileMedicines ?? this.profileMedicines,
        analyzedMedicine:
            clearAnalyzed ? null : analyzedMedicine ?? this.analyzedMedicine,
        compatibilityResult: compatibilityResult ?? this.compatibilityResult,
      );

  @override
  List<Object?> get props => [profileMedicines, analyzedMedicine, compatibilityResult];
}

class MedicinesAnalyzing extends MedicinesState {
  final List<ProfileMedicine> profileMedicines;
  const MedicinesAnalyzing({required this.profileMedicines});
  @override
  List<Object?> get props => [profileMedicines];
}

class MedicinesError extends MedicinesState {
  final String message;
  final List<ProfileMedicine> profileMedicines;

  const MedicinesError({required this.message, this.profileMedicines = const []});

  @override
  List<Object?> get props => [message, profileMedicines];
}
