import '../../../../core/network/api_client.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../models/medicine_model.dart';

class MedicinesRepositoryImpl implements MedicinesRepository {
  final ApiClient _api;
  MedicinesRepositoryImpl(this._api);

  @override
  Future<MedicineKB> analyzeByName(String name) async {
    final res = await _api.post('/medicines/analyze/name', data: {'name': name});
    return MedicineKBModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<MedicineKB> analyzeByPhoto(String base64, String mimeType) async {
    final res = await _api.post('/medicines/analyze/photo', data: {
      'image_base64': base64,
      'mime_type': mimeType,
    });
    return MedicineKBModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<MedicineKB>> searchKB(String query) async {
    final res = await _api.get('/medicines/kb/search', params: {'q': query});
    return (res.data as List)
        .map((j) => MedicineKBModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> checkCompatibility(
      String profileId, String medicineName) async {
    final res = await _api.post('/medicines/compatibility', data: {
      'profile_id': profileId,
      'new_medicine_name': medicineName,
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getRecommendation(
      String kbId, String profileId) async {
    final res = await _api.get(
      '/medicines/recommend/$kbId',
      params: {'profile_id': profileId},
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<List<ProfileMedicine>> getProfileMedicines(
      String profileId, {
      bool activeOnly = false,
  }) async {
    final res = await _api.get(
      '/medicines/profile/$profileId',
      params: {'active_only': activeOnly},
    );
    return (res.data as List)
        .map((j) => ProfileMedicineModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProfileMedicine> addToProfile(Map<String, dynamic> data) async {
    final res = await _api.post('/medicines/profile', data: data);
    return ProfileMedicineModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<ProfileMedicine> updateProfileMedicine(
      String id, Map<String, dynamic> data) async {
    final res = await _api.patch('/medicines/profile/$id', data: data);
    return ProfileMedicineModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProfileMedicine(String id) async {
    await _api.delete('/medicines/profile/$id');
  }

  @override
  Future<List<Map<String, dynamic>>> getTodaySchedule(String profileId) async {
    final res = await _api.get('/medicines/schedule/today/$profileId');
    return (res.data as List)
        .map((j) => j as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> updateIntakeLog(String logId, String status) async {
    await _api.patch('/medicines/logs/$logId', data: {'status': status});
  }
}
