import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicines_repository.dart';

part 'medicines_state.dart';

class MedicinesCubit extends Cubit<MedicinesState> {
  final MedicinesRepository _repo;

  MedicinesCubit(this._repo) : super(MedicinesInitial());

  List<ProfileMedicine> get _currentMedicines {
    final s = state;
    if (s is MedicinesLoaded) return s.profileMedicines;
    if (s is MedicinesAnalyzing) return s.profileMedicines;
    if (s is MedicinesError) return s.profileMedicines;
    return [];
  }

  Future<void> loadMedicines(String profileId) async {
    emit(MedicinesLoading());
    try {
      final medicines = await _repo.getProfileMedicines(profileId);
      emit(MedicinesLoaded(profileMedicines: medicines));
    } catch (e) {
      emit(MedicinesError(message: e.toString()));
    }
  }

  Future<MedicineKB?> analyzeByName(String name) async {
    final current = _currentMedicines;
    emit(MedicinesAnalyzing(profileMedicines: current));
    try {
      final kb = await _repo.analyzeByName(name);
      emit(MedicinesLoaded(profileMedicines: current, analyzedMedicine: kb));
      return kb;
    } catch (e) {
      emit(MedicinesError(message: e.toString(), profileMedicines: current));
      return null;
    }
  }

  Future<MedicineKB?> analyzeByPhoto(String base64, String mimeType) async {
    final current = _currentMedicines;
    emit(MedicinesAnalyzing(profileMedicines: current));
    try {
      final kb = await _repo.analyzeByPhoto(base64, mimeType);
      emit(MedicinesLoaded(profileMedicines: current, analyzedMedicine: kb));
      return kb;
    } catch (e) {
      emit(MedicinesError(message: e.toString(), profileMedicines: current));
      return null;
    }
  }

  Future<void> addToProfile(Map<String, dynamic> data) async {
    final current = _currentMedicines;
    try {
      final medicine = await _repo.addToProfile(data);
      final updated = [...current, medicine];
      emit(MedicinesLoaded(profileMedicines: updated));
    } catch (e) {
      emit(MedicinesError(message: e.toString(), profileMedicines: current));
    }
  }

  Future<void> deleteMedicine(String id) async {
    final current = _currentMedicines;
    try {
      await _repo.deleteProfileMedicine(id);
      final updated = current.where((m) => m.id != id).toList();
      if (state is MedicinesLoaded) {
        emit((state as MedicinesLoaded).copyWith(profileMedicines: updated));
      } else {
        emit(MedicinesLoaded(profileMedicines: updated));
      }
    } catch (e) {
      emit(MedicinesError(message: e.toString(), profileMedicines: current));
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    final current = _currentMedicines;
    try {
      final updated = await _repo.updateProfileMedicine(id, {'is_active': isActive});
      final list = current.map((m) => m.id == id ? updated : m).toList();
      if (state is MedicinesLoaded) {
        emit((state as MedicinesLoaded).copyWith(profileMedicines: list));
      } else {
        emit(MedicinesLoaded(profileMedicines: list));
      }
    } catch (e) {
      emit(MedicinesError(message: e.toString(), profileMedicines: current));
    }
  }

  void clearAnalyzed() {
    if (state is MedicinesLoaded) {
      emit((state as MedicinesLoaded).copyWith(clearAnalyzed: true));
    }
  }
}
