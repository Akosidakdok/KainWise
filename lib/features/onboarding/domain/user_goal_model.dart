class UserGoalModel {
  const UserGoalModel({
    required this.userId,
    this.dailyCalorieTarget = 2000,
    this.proteinTargetG = 140.0,
    this.carbsTargetG = 240.0,
    this.fatTargetG = 70.0,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String userId;
  final int dailyCalorieTarget;
  final double proteinTargetG;
  final double carbsTargetG;
  final double fatTargetG;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'daily_calorie_target': dailyCalorieTarget,
      'protein_target_g': proteinTargetG,
      'carbs_target_g': carbsTargetG,
      'fat_target_g': fatTargetG,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory UserGoalModel.fromJson(Map<String, dynamic> json) {
    return UserGoalModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      dailyCalorieTarget: (json['daily_calorie_target'] as num?)?.toInt() ?? 2000,
      proteinTargetG: (json['protein_target_g'] as num?)?.toDouble() ?? 140.0,
      carbsTargetG: (json['carbs_target_g'] as num?)?.toDouble() ?? 240.0,
      fatTargetG: (json['fat_target_g'] as num?)?.toDouble() ?? 70.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }
}
