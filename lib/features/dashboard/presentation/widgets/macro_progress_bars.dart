import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/meal_summary_model.dart';

class MacroProgressBars extends StatelessWidget {
  const MacroProgressBars({
    super.key,
    required this.summary,
  });

  final DailyNutritionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MACRONUTRIENTS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMacroRow(
              name: 'Protein',
              consumed: summary.proteinConsumedG,
              goal: summary.proteinGoalG,
              progress: summary.proteinProgress,
              color: AppColors.protein,
            ),
            const SizedBox(height: 14),
            _buildMacroRow(
              name: 'Carbs',
              consumed: summary.carbsConsumedG,
              goal: summary.carbsGoalG,
              progress: summary.carbsProgress,
              color: AppColors.carbs,
            ),
            const SizedBox(height: 14),
            _buildMacroRow(
              name: 'Fat',
              consumed: summary.fatConsumedG,
              goal: summary.fatGoalG,
              progress: summary.fatProgress,
              color: AppColors.fat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow({
    required String name,
    required double consumed,
    required double goal,
    required double progress,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              '${consumed.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} g',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
