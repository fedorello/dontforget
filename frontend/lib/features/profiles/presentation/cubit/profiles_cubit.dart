import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profiles_repository.dart';

part 'profiles_state.dart';

class ProfilesCubit extends Cubit<ProfilesState> {
  final ProfilesRepository _repo;
  ProfilesCubit(this._repo) : super(ProfilesInitial());

  Future<void> loadProfiles() async {
    emit(ProfilesLoading());
    try {
      final profiles = await _repo.getAll();
      emit(ProfilesLoaded(profiles));
    } catch (e) {
      emit(ProfilesError(e.toString()));
    }
  }

  Future<void> createProfile(Map<String, dynamic> data) async {
    try {
      await _repo.create(data);
      await loadProfiles();
    } catch (e) {
      emit(ProfilesError(e.toString()));
    }
  }

  Future<void> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      await _repo.update(id, data);
      await loadProfiles();
    } catch (e) {
      emit(ProfilesError(e.toString()));
    }
  }

  Future<void> deleteProfile(String id) async {
    try {
      await _repo.delete(id);
      await loadProfiles();
    } catch (e) {
      emit(ProfilesError(e.toString()));
    }
  }

  Profile? get defaultProfile {
    final s = state;
    if (s is ProfilesLoaded) {
      try {
        return s.profiles.firstWhere((p) => p.isDefault);
      } catch (_) {
        return s.profiles.isNotEmpty ? s.profiles.first : null;
      }
    }
    return null;
  }
}
