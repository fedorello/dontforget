import '../entities/medicine.dart';

abstract interface class MedicinesRepository {
  Future<MedicineKB> analyzeByName(String name);
  Future<MedicineKB> analyzeByPhoto(String base64, String mimeType);
  Future<List<MedicineKB>> searchKB(String query);
  Future<Map<String, dynamic>> checkCompatibility(
      String profileId, String medicineName);
  Future<Map<String, dynamic>> getRecommendation(
      String kbId, String profileId);
  Future<List<ProfileMedicine>> getProfileMedicines(
      String profileId, {
      bool activeOnly = false,
  });
  Future<ProfileMedicine> addToProfile(Map<String, dynamic> data);
  Future<ProfileMedicine> updateProfileMedicine(
      String id, Map<String, dynamic> data);
  Future<void> deleteProfileMedicine(String id);
  Future<List<Map<String, dynamic>>> getTodaySchedule(String profileId);
  Future<void> updateIntakeLog(String logId, String status);
}
