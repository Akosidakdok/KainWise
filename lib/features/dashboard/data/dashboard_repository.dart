import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/meal_summary_model.dart';

abstract class IDashboardRepository {
  Future<DailyNutritionSummary> getDailySummary({
    required String userId,
    required DateTime date,
    required int calorieGoal,
    required double proteinGoalG,
    required double carbsGoalG,
    required double fatGoalG,
  });
}

class SupabaseDashboardRepository implements IDashboardRepository {
  SupabaseDashboardRepository(this._client);

  final SupabaseClient? _client;

  @override
  Future<DailyNutritionSummary> getDailySummary({
    required String userId,
    required DateTime date,
    required int calorieGoal,
    required double proteinGoalG,
    required double carbsGoalG,
    required double fatGoalG,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    int breakfastCals = 0;
    int lunchCals = 0;
    int dinnerCals = 0;
    int snackCals = 0;

    final client = _client;
    if (client != null) {
      try {
        final rows = await client
            .from('meals')
            .select()
            .eq('user_id', userId)
            .gte('logged_at', startOfDay)
            .lte('logged_at', endOfDay);

        for (final row in rows) {
          final cals = (row['total_calories'] as num?)?.toInt() ?? 0;
          final protein = (row['total_protein_g'] as num?)?.toDouble() ?? 0.0;
          final carbs = (row['total_carbs_g'] as num?)?.toDouble() ?? 0.0;
          final fat = (row['total_fat_g'] as num?)?.toDouble() ?? 0.0;
          final mealType = (row['meal_type'] as String? ?? '').toLowerCase();

          totalCalories += cals;
          totalProtein += protein;
          totalCarbs += carbs;
          totalFat += fat;

          if (mealType.contains('breakfast')) {
            breakfastCals += cals;
          } else if (mealType.contains('lunch')) {
            lunchCals += cals;
          } else if (mealType.contains('dinner')) {
            dinnerCals += cals;
          } else {
            snackCals += cals;
          }
        }
      } catch (_) {}
    }

    return DailyNutritionSummary(
      date: date,
      calorieGoal: calorieGoal,
      caloriesConsumed: totalCalories,
      proteinGoalG: proteinGoalG,
      proteinConsumedG: totalProtein,
      carbsGoalG: carbsGoalG,
      carbsConsumedG: totalCarbs,
      fatGoalG: fatGoalG,
      fatConsumedG: totalFat,
      breakfastCalories: breakfastCals,
      lunchCalories: lunchCals,
      dinnerCalories: dinnerCals,
      snacksCalories: snackCals,
    );
  }
}

final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseDashboardRepository(client);
});
