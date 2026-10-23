class AppConstants {
  static const String appName = 'KainWise';
  static const String appTagline = 'Smart Calorie & Nutrition Tracking';
  
  // Daily Free AI Limits (Zero-cost guardrails)
  static const int maxDailyPhotoScans = 10;
  static const int maxDailyTextLogs = 20;
  static const int maxDailyAssistantChats = 20;
  
  // Nutrition Fallbacks & Defaults
  static const int defaultDailyCalorieGoal = 2000;
  static const int defaultProteinGrams = 140;
  static const int defaultCarbsGrams = 240;
  static const int defaultFatGrams = 70;
}

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snacks');

  const MealType(this.displayName);
  final String displayName;
}

enum WeightGoal {
  loseWeight('Lose Weight', -500),
  maintainWeight('Maintain Weight', 0),
  gainWeight('Gain Weight', 350);

  const WeightGoal(this.displayName, this.calorieAdjustment);
  final String displayName;
  final int calorieAdjustment;
}

enum ActivityLevel {
  sedentary('Sedentary', 1.2, 'Little or no exercise, desk job'),
  lightlyActive('Lightly Active', 1.375, 'Light exercise 1-3 days/week'),
  moderatelyActive('Moderately Active', 1.55, 'Moderate exercise 3-5 days/week'),
  veryActive('Very Active', 1.725, 'Hard exercise 6-7 days/week');

  const ActivityLevel(this.displayName, this.multiplier, this.description);
  final String displayName;
  final double multiplier;
  final String description;
}
