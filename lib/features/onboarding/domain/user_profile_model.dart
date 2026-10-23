class UserProfileModel {
  const UserProfileModel({
    required this.id,
    this.displayName = '',
    this.age = 25,
    this.biologicalSex = 'male',
    this.heightCm = 170.0,
    this.currentWeightKg = 70.0,
    this.goalWeightKg = 65.0,
    this.activityLevel = 'lightly_active',
    this.weightGoal = 'lose_weight',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String displayName;
  final int age;
  final String biologicalSex;
  final double heightCm;
  final double currentWeightKg;
  final double goalWeightKg;
  final String activityLevel;
  final String weightGoal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'age': age,
      'biological_sex': biologicalSex,
      'height_cm': heightCm,
      'current_weight_kg': currentWeightKg,
      'goal_weight_kg': goalWeightKg,
      'activity_level': activityLevel,
      'weight_goal': weightGoal,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 25,
      biologicalSex: json['biological_sex'] as String? ?? 'male',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 170.0,
      currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble() ?? 70.0,
      goalWeightKg: (json['goal_weight_kg'] as num?)?.toDouble() ?? 65.0,
      activityLevel: json['activity_level'] as String? ?? 'lightly_active',
      weightGoal: json['weight_goal'] as String? ?? 'lose_weight',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }
}
