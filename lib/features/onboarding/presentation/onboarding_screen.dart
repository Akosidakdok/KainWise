import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  final _nameController = TextEditingController(text: 'Maria Clara');
  final _ageController = TextEditingController(text: '26');
  final _heightController = TextEditingController(text: '165');
  final _weightController = TextEditingController(text: '68');
  final _goalWeightController = TextEditingController(text: '62');

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  void _syncInputs() {
    ref.read(onboardingControllerProvider.notifier).updateBiometrics(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text) ?? 25,
          heightCm: double.tryParse(_heightController.text) ?? 170.0,
          currentWeightKg: double.tryParse(_weightController.text) ?? 70.0,
          goalWeightKg: double.tryParse(_goalWeightController.text) ?? 65.0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Setup Your Calorie Target'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_currentStep + 1} of 3',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),

            if (_currentStep == 0) _buildStepBiometrics(state),
            if (_currentStep == 1) _buildStepLifestyle(state),
            if (_currentStep == 2) _buildStepTarget(state),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBiometrics(OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('About You', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Your measurements help calculate accurate daily energy expenditure.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Name',
          controller: _nameController,
          hintText: 'Your name',
          onChanged: (_) => _syncInputs(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Age',
                controller: _ageController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _syncInputs(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biological Sex', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: state.biologicalSex,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(onboardingControllerProvider.notifier).updateBiometrics(biologicalSex: val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Height (cm)',
                controller: _heightController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _syncInputs(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                label: 'Weight (kg)',
                controller: _weightController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _syncInputs(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Goal Weight (kg)',
          controller: _goalWeightController,
          keyboardType: TextInputType.number,
          onChanged: (_) => _syncInputs(),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Continue',
          onPressed: () {
            _syncInputs();
            setState(() => _currentStep = 1);
          },
        ),
      ],
    );
  }

  Widget _buildStepLifestyle(OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Lifestyle & Goal', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Choose activity level and weight objective.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        Text('Activity Level', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...ActivityLevel.values.map((lvl) {
          final isSelected = state.activityLevel == lvl;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: isSelected ? AppColors.primaryLight : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                title: Text(lvl.displayName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text(lvl.description, style: const TextStyle(fontSize: 12)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () => ref.read(onboardingControllerProvider.notifier).updateLifestyle(activityLevel: lvl),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text('Weight Goal', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...WeightGoal.values.map((g) {
          final isSelected = state.weightGoal == g;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: isSelected ? AppColors.primaryLight : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                title: Text(g.displayName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text(
                  g == WeightGoal.loseWeight
                      ? '-500 kcal/day deficit'
                      : (g == WeightGoal.gainWeight ? '+350 kcal/day surplus' : 'Maintain current weight'),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () => ref.read(onboardingControllerProvider.notifier).updateLifestyle(weightGoal: g),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'View Recommendation',
          onPressed: () => setState(() => _currentStep = 2),
        ),
      ],
    );
  }

  Widget _buildStepTarget(OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Your Daily Calorie Target', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Calculated using the Mifflin-St Jeor formula. You can customize this target anytime.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),

        // Recommended Target Card with Adjuster
        Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('RECOMMENDED TARGET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {
                        final val = state.customDailyCalorieTarget - 50;
                        ref.read(onboardingControllerProvider.notifier).updateCustomCalorieTarget(val.clamp(1000, 5000));
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          '${state.customDailyCalorieTarget}',
                          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        const Text('kcal / day', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    IconButton.filledTonal(
                      onPressed: () {
                        final val = state.customDailyCalorieTarget + 50;
                        ref.read(onboardingControllerProvider.notifier).updateCustomCalorieTarget(val.clamp(1000, 5000));
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        // Macro distribution preview
        Text('Recommended Macro Split', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMacroCard('Protein', '${state.proteinGrams} g', AppColors.protein)),
            const SizedBox(width: 10),
            Expanded(child: _buildMacroCard('Carbs', '${state.carbsGrams} g', AppColors.carbs)),
            const SizedBox(width: 10),
            Expanded(child: _buildMacroCard('Fat', '${state.fatGrams} g', AppColors.fat)),
          ],
        ),

        const SizedBox(height: 24),
        // Medical Disclaimer
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Calorie requirements are estimates based on standard population formulas and are not medical advice. Consult a healthcare provider for personalized medical nutrition guidance.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Confirm & Go to Dashboard',
          isLoading: state.isSaving,
          onPressed: () async {
            final success = await ref.read(onboardingControllerProvider.notifier).saveOnboarding();
            if (mounted && success) {
              context.go('/home');
            }
          },
        ),
      ],
    );
  }

  Widget _buildMacroCard(String name, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
