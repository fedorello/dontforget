import '../../../../core/network/api_client.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profiles_repository.dart';
import '../models/profile_model.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  final ApiClient _api;
  ProfilesRepositoryImpl(this._api);

  @override
  Future<List<Profile>> getAll() async {
    final res = await _api.get('/profiles/');
    return (res.data as List).map((j) => ProfileModel.fromJson(j)).toList();
  }

  @override
  Future<Profile> create(Map<String, dynamic> data) async {
    final res = await _api.post('/profiles/', data: data);
    return ProfileModel.fromJson(res.data);
  }

  @override
  Future<Profile> update(String id, Map<String, dynamic> data) async {
    final res = await _api.patch('/profiles/$id', data: data);
    return ProfileModel.fromJson(res.data);
  }

  @override
  Future<void> delete(String id) async {
    await _api.delete('/profiles/$id');
  }
}
