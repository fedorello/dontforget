import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.avatarEmoji,
    super.birthDate,
    super.gender,
    super.weightKg,
    super.healthNotes,
    super.allergies,
    required super.isDefault,
    super.age,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarEmoji: json['avatar_emoji'] as String? ?? '👤',
        birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
        gender: json['gender'] as String?,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        healthNotes: json['health_notes'] as String?,
        allergies: json['allergies'] as String?,
        isDefault: json['is_default'] as bool? ?? false,
        age: json['age'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar_emoji': avatarEmoji,
        if (birthDate != null) 'birth_date': birthDate!.toIso8601String().substring(0, 10),
        if (gender != null) 'gender': gender,
        if (weightKg != null) 'weight_kg': weightKg,
        if (healthNotes != null) 'health_notes': healthNotes,
        if (allergies != null) 'allergies': allergies,
        'is_default': isDefault,
      };
}
