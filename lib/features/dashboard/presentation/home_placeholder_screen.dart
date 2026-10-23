import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_controller.dart';

class HomePlaceholderScreen extends ConsumerStatefulWidget {
  const HomePlaceholderScreen({super.key});

  @override
  ConsumerState<HomePlaceholderScreen> createState() =>
      _HomePlaceholderScreenState();
}

class _HomePlaceholderScreenState extends ConsumerState<HomePlaceholderScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? AppConstants.appName
            : _getTitleForIndex(_currentIndex)),
        actions: [
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            _showAddFoodQuickSheet(context);
          } else {
            setState(() => _currentIndex = index);
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
            icon: Icon(Icons.add_circle, color: AppColors.primary, size: 32),
            label: 'Add Food',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      body: _buildBodyForIndex(_currentIndex),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Food Diary';
      case 2:
        return 'Add Food';
      case 3:
        return 'Progress & Trends';
      case 4:
        return 'My Profile';
      default:
        return AppConstants.appName;
    }
  }

  Widget _buildBodyForIndex(int index) {
    switch (index) {
      case 0:
        return _buildHomeOverview();
      case 1:
        return _buildPlaceholderCard('Food Diary', 'Daily meal logs will be displayed here in Phase 7.');
      case 3:
        return _buildPlaceholderCard('Progress', 'Calorie trends & weight tracking charts in Phase 16.');
      case 4:
        return _buildPlaceholderCard('Profile', 'Account settings & calorie target configuration in Phase 4.');
      default:
        return _buildHomeOverview();
    }
  }

  Widget _buildHomeOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Calorie Summary Card
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TODAY',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Phase 1 Foundation',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Goal', '2,100', 'kcal'),
                      const Text('-', style: TextStyle(fontSize: 24, color: AppColors.textMuted)),
                      _buildStatColumn('Consumed', '0', 'kcal'),
                      const Text('=', style: TextStyle(fontSize: 24, color: AppColors.textMuted)),
                      _buildStatColumn('Remaining', '2,100', 'kcal', isHighlight: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Quick Action Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(Icons.camera_alt_outlined, 'Photo', () => _showAddFoodQuickSheet(context)),
                  _buildQuickAction(Icons.edit_note_outlined, 'Text AI', () => _showAddFoodQuickSheet(context)),
                  _buildQuickAction(Icons.qr_code_scanner_outlined, 'Barcode', () => _showAddFoodQuickSheet(context)),
                  _buildQuickAction(Icons.search_rounded, 'Search', () => _showAddFoodQuickSheet(context)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Empty State Prompt
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.dining_outlined,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'No meals logged yet today',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap below or the + button to log your first food.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddFoodQuickSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Meal'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(String title, String subtitle) {
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
                  subtitle,
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

  void _showAddFoodQuickSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log Food',
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
