import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class MealSectionCard extends StatelessWidget {
  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.calories,
    required this.onAddFood,
  });

  final MealType mealType;
  final int calories;
  final VoidCallback onAddFood;

  IconData _getIconForMeal() {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.restaurant_outlined;
      case MealType.dinner:
        return Icons.nights_stay_outlined;
      case MealType.snack:
        return Icons.cookie_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight,
              child: Icon(_getIconForMeal(), size: 20, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealType.displayName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    calories > 0 ? '$calories kcal' : 'No food logged',
                    style: TextStyle(
                      fontSize: 13,
                      color: calories > 0 ? AppColors.textPrimary : AppColors.textMuted,
                      fontWeight: calories > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
              tooltip: 'Add ${mealType.displayName}',
              onPressed: onAddFood,
            ),
          ],
        ),
      ),
    );
  }
}
