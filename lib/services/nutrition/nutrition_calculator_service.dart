import '../../core/constants/app_constants.dart';

class NutritionCalculationResult {
  const NutritionCalculationResult({
    required this.bmr,
    required this.tdee,
    required this.recommendedCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  final int bmr;
  final int tdee;
  final int recommendedCalories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
}

class NutritionCalculatorService {
  /// Calculates BMR using the scientifically established Mifflin-St Jeor equation:
  /// Men:   (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) + 5
  /// Women: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) - 161
  static int calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String biologicalSex,
  }) {
    final base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age);
    final isMale = biologicalSex.toLowerCase() == 'male';
    final bmr = isMale ? base + 5 : base - 161;
    return bmr.round().clamp(800, 4000);
  }

  /// Calculates TDEE (Total Daily Energy Expenditure) = BMR × Activity Multiplier
  static int calculateTDEE({
    required int bmr,
    required ActivityLevel activityLevel,
  }) {
    return (bmr * activityLevel.multiplier).round();
  }

  /// Calculates comprehensive daily recommendation with macros
  static NutritionCalculationResult calculateRecommendation({
    required double weightKg,
    required double heightCm,
    required int age,
    required String biologicalSex,
    required ActivityLevel activityLevel,
    required WeightGoal goal,
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      biologicalSex: biologicalSex,
    );

    final tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel);
    
    // Adjust target based on goal (clamp to safe minimum of 1,200 kcal for general adult)
    final adjustedCalories = (tdee + goal.calorieAdjustment).clamp(1200, 6000);

    // Balanced macro distribution:
    // Protein: ~2.0g per kg of body weight or 25% of calories (4 kcal/g)
    // Fat: ~25% of calories (9 kcal/g)
    // Carbs: Remaining calories (4 kcal/g)
    final proteinCalories = (adjustedCalories * 0.25);
    final fatCalories = (adjustedCalories * 0.25);
    final carbsCalories = (adjustedCalories - proteinCalories - fatCalories);

    final proteinGrams = (proteinCalories / 4.0).round();
    final fatGrams = (fatCalories / 9.0).round();
    final carbsGrams = (carbsCalories / 4.0).round();

    return NutritionCalculationResult(
      bmr: bmr,
      tdee: tdee,
      recommendedCalories: adjustedCalories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
    );
  }
}
