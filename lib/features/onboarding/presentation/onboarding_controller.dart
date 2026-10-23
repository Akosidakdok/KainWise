import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/nutrition/nutrition_calculator_service.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/onboarding_repository.dart';
import '../domain/user_goal_model.dart';
import '../domain/user_profile_model.dart';

class OnboardingState {
  const OnboardingState({
    this.name = '',
    this.age = 26,
    this.biologicalSex = 'male',
    this.heightCm = 170.0,
    this.currentWeightKg = 70.0,
    this.goalWeightKg = 65.0,
    this.activityLevel = ActivityLevel.lightlyActive,
    this.weightGoal = WeightGoal.loseWeight,
    this.calculatedCalories = 2000,
    this.customDailyCalorieTarget = 2000,
    this.proteinGrams = 140,
    this.carbsGrams = 240,
    this.fatGrams = 70,
    this.isSaving = false,
  });

  final String name;
  final int age;
  final String biologicalSex;
  final double heightCm;
  final double currentWeightKg;
  final double goalWeightKg;
  final ActivityLevel activityLevel;
  final WeightGoal weightGoal;
  final int calculatedCalories;
  final int customDailyCalorieTarget;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final bool isSaving;

  OnboardingState copyWith({
    String? name,
    int? age,
    String? biologicalSex,
    double? heightCm,
    double? currentWeightKg,
    double? goalWeightKg,
    ActivityLevel? activityLevel,
    WeightGoal? weightGoal,
    int? calculatedCalories,
    int? customDailyCalorieTarget,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
    bool? isSaving,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      age: age ?? this.age,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      weightGoal: weightGoal ?? this.weightGoal,
      calculatedCalories: calculatedCalories ?? this.calculatedCalories,
      customDailyCalorieTarget:
          customDailyCalorieTarget ?? this.customDailyCalorieTarget,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final state = const OnboardingState();
    return _recompute(state);
  }

  OnboardingState _recompute(OnboardingState current) {
    final res = NutritionCalculatorService.calculateRecommendation(
      weightKg: current.currentWeightKg,
      heightCm: current.heightCm,
      age: current.age,
      biologicalSex: current.biologicalSex,
      activityLevel: current.activityLevel,
      goal: current.weightGoal,
    );
    return current.copyWith(
      calculatedCalories: res.recommendedCalories,
      customDailyCalorieTarget: res.recommendedCalories,
      proteinGrams: res.proteinGrams,
      carbsGrams: res.carbsGrams,
      fatGrams: res.fatGrams,
    );
  }

  void updateBiometrics({
    String? name,
    int? age,
    String? biologicalSex,
    double? heightCm,
    double? currentWeightKg,
    double? goalWeightKg,
  }) {
    final updated = state.copyWith(
      name: name,
      age: age,
      biologicalSex: biologicalSex,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      goalWeightKg: goalWeightKg,
    );
    state = _recompute(updated);
  }

  void updateLifestyle({
    ActivityLevel? activityLevel,
    WeightGoal? weightGoal,
  }) {
    final updated = state.copyWith(
      activityLevel: activityLevel,
      weightGoal: weightGoal,
    );
    state = _recompute(updated);
  }

  void updateCustomCalorieTarget(int calories) {
    state = state.copyWith(customDailyCalorieTarget: calories);
  }

  Future<bool> saveOnboarding() async {
    state = state.copyWith(isSaving: true);
    try {
      final user = ref.read(authControllerProvider).value;
      final userId = user?.id ?? 'guest-user';

      final repo = ref.read(onboardingRepositoryProvider);

      final profile = UserProfileModel(
        id: userId,
        displayName: state.name.isNotEmpty ? state.name : 'User',
        age: state.age,
        biologicalSex: state.biologicalSex,
        heightCm: state.heightCm,
        currentWeightKg: state.currentWeightKg,
        goalWeightKg: state.goalWeightKg,
        activityLevel: state.activityLevel.name,
        weightGoal: state.weightGoal.name,
      );

      final goal = UserGoalModel(
        userId: userId,
        dailyCalorieTarget: state.customDailyCalorieTarget,
        proteinTargetG: state.proteinGrams.toDouble(),
        carbsTargetG: state.carbsGrams.toDouble(),
        fatTargetG: state.fatGrams.toDouble(),
      );

      await repo.saveProfile(profile);
      await repo.saveGoal(goal);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
        OnboardingNotifier.new);

final userActiveGoalProvider = FutureProvider<UserGoalModel?>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest-user';
  return ref.watch(onboardingRepositoryProvider).getGoal(userId);
});
