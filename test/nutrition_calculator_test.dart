import 'package:flutter_test/flutter_test.dart';
import 'package:kainwise/core/constants/app_constants.dart';
import 'package:kainwise/services/nutrition/nutrition_calculator_service.dart';

void main() {
  group('NutritionCalculatorService Tests', () {
    test('Calculates BMR accurately for Male using Mifflin-St Jeor', () {
      // 70kg, 175cm, 25 years, male:
      // (10 * 70) + (6.25 * 175) - (5 * 25) + 5
      // = 700 + 1093.75 - 125 + 5 = 1673.75 -> 1674
      final bmr = NutritionCalculatorService.calculateBMR(
        weightKg: 70,
        heightCm: 175,
        age: 25,
        biologicalSex: 'male',
      );
      expect(bmr, 1674);
    });

    test('Calculates BMR accurately for Female using Mifflin-St Jeor', () {
      // 60kg, 162cm, 30 years, female:
      // (10 * 60) + (6.25 * 162) - (5 * 30) - 161
      // = 600 + 1012.5 - 150 - 161 = 1301.5 -> 1302
      final bmr = NutritionCalculatorService.calculateBMR(
        weightKg: 60,
        heightCm: 162,
        age: 30,
        biologicalSex: 'female',
      );
      expect(bmr, 1302);
    });

    test('Calculates TDEE with activity multiplier', () {
      // BMR 1600 * 1.55 (Moderately Active) = 2480
      final tdee = NutritionCalculatorService.calculateTDEE(
        bmr: 1600,
        activityLevel: ActivityLevel.moderatelyActive,
      );
      expect(tdee, 2480);
    });

    test('Applies deficit for Lose Weight goal', () {
      final res = NutritionCalculatorService.calculateRecommendation(
        weightKg: 70,
        heightCm: 175,
        age: 25,
        biologicalSex: 'male',
        activityLevel: ActivityLevel.lightlyActive,
        goal: WeightGoal.loseWeight,
      );

      // BMR = 1674. TDEE = 1674 * 1.375 = 2302.
      // Deficit = 2302 - 500 = 1802.
      expect(res.recommendedCalories, 1802);
      expect(res.proteinGrams, greaterThan(0));
      expect(res.carbsGrams, greaterThan(0));
      expect(res.fatGrams, greaterThan(0));
    });
  });
}
