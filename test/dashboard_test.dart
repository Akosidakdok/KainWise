import 'package:flutter_test/flutter_test.dart';
import 'package:kainwise/features/dashboard/domain/meal_summary_model.dart';

void main() {
  group('DailyNutritionSummary Tests', () {
    test('Calculates remaining calories accurately', () {
      const summary = DailyNutritionSummary(
        calorieGoal: 2100,
        caloriesConsumed: 1350,
      );

      // Remaining = 2100 - 1350 = 750
      expect(summary.remainingCalories, 750);
      expect(summary.calorieProgress, closeTo(1350 / 2100, 0.01));
    });

    test('Clamps remaining calories to zero when exceeding goal', () {
      const summary = DailyNutritionSummary(
        calorieGoal: 2000,
        caloriesConsumed: 2500,
      );

      expect(summary.remainingCalories, 0);
      expect(summary.calorieProgress, 1.0);
    });

    test('Calculates macro progress ratios properly', () {
      const summary = DailyNutritionSummary(
        proteinGoalG: 140,
        proteinConsumedG: 70,
        carbsGoalG: 240,
        carbsConsumedG: 120,
        fatGoalG: 70,
        fatConsumedG: 35,
      );

      expect(summary.proteinProgress, 0.5);
      expect(summary.carbsProgress, 0.5);
      expect(summary.fatProgress, 0.5);
    });
  });
}
