class Profile {
  final String id;
  final String name;
  final String avatarEmoji;
  final DateTime? birthDate;
  final String? gender;
  final double? weightKg;
  final String? healthNotes;
  final String? allergies;
  final bool isDefault;
  final int? age;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    this.birthDate,
    this.gender,
    this.weightKg,
    this.healthNotes,
    this.allergies,
    required this.isDefault,
    this.age,
    required this.createdAt,
  });

  Profile copyWith({
    String? name,
    String? avatarEmoji,
    DateTime? birthDate,
    String? gender,
    double? weightKg,
    String? healthNotes,
    String? allergies,
    bool? isDefault,
  }) =>
      Profile(
        id: id,
        name: name ?? this.name,
        avatarEmoji: avatarEmoji ?? this.avatarEmoji,
        birthDate: birthDate ?? this.birthDate,
        gender: gender ?? this.gender,
        weightKg: weightKg ?? this.weightKg,
        healthNotes: healthNotes ?? this.healthNotes,
        allergies: allergies ?? this.allergies,
        isDefault: isDefault ?? this.isDefault,
        age: age,
        createdAt: createdAt,
      );
}
