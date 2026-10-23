import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/meal_summary_model.dart';
import 'dashboard_controller.dart';
import 'widgets/calorie_ring_card.dart';
import 'widgets/macro_progress_bars.dart';
import 'widgets/meal_section_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dailyNutritionSummaryProvider);
    final selectedDate = ref.watch(selectedDashboardDateProvider);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              _currentTab == 0
                  ? AppConstants.appName
                  : _getTabTitle(_currentTab),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Setup / Edit Goals',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.go('/onboarding'),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openAddFoodModal(context),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              icon: const Icon(Icons.add),
              label: const Text('Add Food', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (idx) {
          if (idx == 2) {
            _openAddFoodModal(context);
          } else {
            setState(() => _currentTab = idx);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book_rounded),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: AppColors.surface, size: 22),
            ),
            label: 'Add Food',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      body: _buildCurrentTab(summaryAsync, selectedDate),
    );
  }

  String _getTabTitle(int tab) {
    switch (tab) {
      case 1:
        return 'Daily Diary';
      case 2:
        return 'Add Food';
      case 3:
        return 'Progress';
      case 4:
        return 'Profile';
      default:
        return AppConstants.appName;
    }
  }

  Widget _buildCurrentTab(
    AsyncValue<DailyNutritionSummary> summaryAsync,
    DateTime selectedDate,
  ) {
    if (_currentTab != 0) {
      return _buildPlaceholderView(_getTabTitle(_currentTab));
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(mealUpdateTriggerProvider.notifier).trigger();
        ref.invalidate(dailyNutritionSummaryProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Navigation Header
            _buildDateSelector(selectedDate),
            const SizedBox(height: 12),

            summaryAsync.when(
              data: (summary) => Column(
                children: [
                  CalorieRingCard(summary: summary),
                  const SizedBox(height: 14),
                  MacroProgressBars(summary: summary),
                  const SizedBox(height: 18),
                  _buildMealList(summary),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error loading dashboard: $err'),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final dateLabel = isToday ? 'Today, ${DateFormat('MMM d').format(date)}' : DateFormat('EEE, MMM d').format(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(selectedDashboardDateProvider.notifier).previousDay();
            },
          ),
          Text(
            dateLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(selectedDashboardDateProvider.notifier).nextDay();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealList(DailyNutritionSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEALS',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        MealSectionCard(
          mealType: MealType.breakfast,
          calories: summary.breakfastCalories,
          onAddFood: () => _openAddFoodModal(context, mealType: MealType.breakfast),
        ),
        MealSectionCard(
          mealType: MealType.lunch,
          calories: summary.lunchCalories,
          onAddFood: () => _openAddFoodModal(context, mealType: MealType.lunch),
        ),
        MealSectionCard(
          mealType: MealType.dinner,
          calories: summary.dinnerCalories,
          onAddFood: () => _openAddFoodModal(context, mealType: MealType.dinner),
        ),
        MealSectionCard(
          mealType: MealType.snack,
          calories: summary.snacksCalories,
          onAddFood: () => _openAddFoodModal(context, mealType: MealType.snack),
        ),
      ],
    );
  }

  Widget _buildPlaceholderView(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '$title features will be active in upcoming phases.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAddFoodModal(BuildContext context, {MealType? mealType}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                mealType != null ? 'Add to ${mealType.displayName}' : 'Log Food',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.camera_alt_outlined, color: AppColors.primaryDark),
                ),
                title: const Text('Take Photo (AI Vision)'),
                subtitle: const Text('Phase 13'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.edit_note_outlined, color: AppColors.primaryDark),
                ),
                title: const Text('Describe Meal (AI Text)'),
                subtitle: const Text('Phase 12'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.qr_code_scanner_outlined, color: AppColors.primaryDark),
                ),
                title: const Text('Scan Barcode (Open Food Facts)'),
                subtitle: const Text('Phase 9'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.search_rounded, color: AppColors.primaryDark),
                ),
                title: const Text('Search Food Database'),
                subtitle: const Text('Phase 8'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.edit_rounded, color: AppColors.primaryDark),
                ),
                title: const Text('Add Manually'),
                subtitle: const Text('Phase 6'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
