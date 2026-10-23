import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../data/dashboard_repository.dart';
import '../domain/meal_summary_model.dart';

class SelectedDashboardDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
  void previousDay() => state = state.subtract(const Duration(days: 1));
  void nextDay() => state = state.add(const Duration(days: 1));
}

final selectedDashboardDateProvider =
    NotifierProvider<SelectedDashboardDateNotifier, DateTime>(
        SelectedDashboardDateNotifier.new);

class MealUpdateTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() => state++;
}

final mealUpdateTriggerProvider =
    NotifierProvider<MealUpdateTriggerNotifier, int>(
        MealUpdateTriggerNotifier.new);

final dailyNutritionSummaryProvider =
    FutureProvider<DailyNutritionSummary>((ref) async {
  final selectedDate = ref.watch(selectedDashboardDateProvider);
  ref.watch(mealUpdateTriggerProvider);

  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest-user';

  final goalAsync = await ref.watch(userActiveGoalProvider.future);
  final calorieGoal = goalAsync?.dailyCalorieTarget ?? 2000;
  final proteinGoal = goalAsync?.proteinTargetG ?? 140.0;
  final carbsGoal = goalAsync?.carbsTargetG ?? 240.0;
  final fatGoal = goalAsync?.fatTargetG ?? 70.0;

  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDailySummary(
    userId: userId,
    date: selectedDate,
    calorieGoal: calorieGoal,
    proteinGoalG: proteinGoal,
    carbsGoalG: carbsGoal,
    fatGoalG: fatGoal,
  );
});
