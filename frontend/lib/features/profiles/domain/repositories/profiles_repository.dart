import '../entities/profile.dart';

abstract interface class ProfilesRepository {
  Future<List<Profile>> getAll();
  Future<Profile> create(Map<String, dynamic> data);
  Future<Profile> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}
