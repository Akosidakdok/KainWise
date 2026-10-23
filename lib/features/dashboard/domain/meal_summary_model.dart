class DailyNutritionSummary {
  const DailyNutritionSummary({
    this.date,
    this.calorieGoal = 2000,
    this.caloriesConsumed = 0,
    this.proteinGoalG = 140,
    this.proteinConsumedG = 0,
    this.carbsGoalG = 240,
    this.carbsConsumedG = 0,
    this.fatGoalG = 70,
    this.fatConsumedG = 0,
    this.breakfastCalories = 0,
    this.lunchCalories = 0,
    this.dinnerCalories = 0,
    this.snacksCalories = 0,
  });

  final DateTime? date;
  final int calorieGoal;
  final int caloriesConsumed;
  final double proteinGoalG;
  final double proteinConsumedG;
  final double carbsGoalG;
  final double carbsConsumedG;
  final double fatGoalG;
  final double fatConsumedG;

  final int breakfastCalories;
  final int lunchCalories;
  final int dinnerCalories;
  final int snacksCalories;

  int get remainingCalories => (calorieGoal - caloriesConsumed).clamp(0, 99999);
  double get calorieProgress =>
      calorieGoal > 0 ? (caloriesConsumed / calorieGoal).clamp(0.0, 1.0) : 0.0;

  double get proteinProgress =>
      proteinGoalG > 0 ? (proteinConsumedG / proteinGoalG).clamp(0.0, 1.0) : 0.0;
  double get carbsProgress =>
      carbsGoalG > 0 ? (carbsConsumedG / carbsGoalG).clamp(0.0, 1.0) : 0.0;
  double get fatProgress =>
      fatGoalG > 0 ? (fatConsumedG / fatGoalG).clamp(0.0, 1.0) : 0.0;
}
