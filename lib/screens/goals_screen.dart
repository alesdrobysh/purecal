import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/diary_provider.dart';
import '../models/user_goals.dart';
import '../widgets/custom_input_decoration.dart';
import '../config/decorations.dart';
import '../l10n/app_localizations.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinsController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();
    final goals =
        Provider.of<DiaryProvider>(context, listen: false).userGoals ??
            UserGoals.defaultGoals();

    _caloriesController =
        TextEditingController(text: goals.caloriesGoal.toStringAsFixed(0));
    _proteinsController =
        TextEditingController(text: goals.proteinsGoal.toStringAsFixed(0));
    _fatController =
        TextEditingController(text: goals.fatGoal.toStringAsFixed(0));
    _carbsController =
        TextEditingController(text: goals.carbsGoal.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    final l10n = AppLocalizations.of(context)!;
    final calories = double.tryParse(_caloriesController.text);
    final proteins = double.tryParse(_proteinsController.text);
    final fat = double.tryParse(_fatController.text);
    final carbs = double.tryParse(_carbsController.text);

    if (calories == null ||
        proteins == null ||
        fat == null ||
        carbs == null ||
        calories <= 0 ||
        proteins <= 0 ||
        fat <= 0 ||
        carbs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.valueMustBeNonNegative),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<DiaryProvider>(context, listen: false);
    final currentGoals = provider.userGoals;

    final newGoals = UserGoals(
      id: currentGoals?.id,
      caloriesGoal: calories,
      proteinsGoal: proteins,
      fatGoal: fat,
      carbsGoal: carbs,
    );

    provider.updateGoals(newGoals);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.goalsUpdatedSuccessfully),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(l10n.setYourGoals),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyNutritionGoals,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.setDailyTargets,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            _buildGoalInput(
              context: context,
              controller: _caloriesController,
              label: l10n.calories,
              suffix: l10n.kcal,
              icon: Icons.local_fire_department,
              color: Colors.orange,
              hint: 'e.g., 2000',
            ),
            const SizedBox(height: 20),
            _buildGoalInput(
              context: context,
              controller: _proteinsController,
              label: l10n.protein,
              suffix: l10n.grams,
              icon: Icons.egg,
              color: Colors.red,
              hint: 'e.g., 150',
            ),
            const SizedBox(height: 20),
            _buildGoalInput(
              context: context,
              controller: _fatController,
              label: l10n.fat,
              suffix: l10n.grams,
              icon: Icons.water_drop,
              color: Colors.yellow[700]!,
              hint: 'e.g., 65',
            ),
            const SizedBox(height: 20),
            _buildGoalInput(
              context: context,
              controller: _carbsController,
              label: l10n.carbohydrates,
              suffix: l10n.grams,
              icon: Icons.grain,
              color: Colors.blue,
              hint: 'e.g., 200',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppShapes.greenInfoBox(context),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.goalsRecommendation,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.saveGoals,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInput({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: customInputDecoration(context).copyWith(
            hintText: hint,
            suffixText: suffix,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
