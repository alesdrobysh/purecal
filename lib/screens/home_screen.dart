import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/diary_provider.dart';
import '../models/meal_type.dart';
import '../widgets/meal_section.dart';
import 'goals_screen.dart';
import 'charts_screen.dart';
import 'settings_screen.dart';
import '../config/decorations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        backgroundColor: AppColors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoalsScreen(),
                ),
              );
            },
            tooltip: l10n.setGoals,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChartsScreen(),
                ),
              );
            },
            tooltip: l10n.viewCharts,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          if (diaryProvider.isLoading && diaryProvider.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildDateSelector(context, diaryProvider),
                    _buildDailySummary(context, diaryProvider),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  MealSection(
                    mealType: MealType.breakfast,
                    initiallyExpanded: _isCurrentMeal(MealType.breakfast),
                  ),
                  MealSection(
                    mealType: MealType.lunch,
                    initiallyExpanded: _isCurrentMeal(MealType.lunch),
                  ),
                  MealSection(
                    mealType: MealType.dinner,
                    initiallyExpanded: _isCurrentMeal(MealType.dinner),
                  ),
                  MealSection(
                    mealType: MealType.snacks,
                    initiallyExpanded: _isCurrentMeal(MealType.snacks),
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isCurrentMeal(MealType mealType) {
    return MealType.fromTime(DateTime.now()) == mealType;
  }

  Widget _buildDateSelector(BuildContext context, DiaryProvider provider) {
    final isToday = _isSameDay(provider.selectedDate, DateTime.now());
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => provider.previousDay(),
          ),
          GestureDetector(
            onTap: () => _selectDate(context, provider),
            child: Text(
              DateFormat('EEEE, MMM d, yyyy', l10n.localeName)
                  .format(provider.selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: isToday ? theme.disabledColor : null,
                ),
                onPressed: isToday ? null : () => provider.nextDay(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary(BuildContext context, DiaryProvider provider) {
    final summary = provider.dailySummary;
    final goals = provider.userGoals;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.summary,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _NutrientProgress(
            label: l10n.calories,
            current: summary.calories,
            goal: goals?.caloriesGoal ?? 2000,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniNutrientProgress(
                  label: l10n.protein,
                  current: summary.proteins,
                  goal: goals?.proteinsGoal ?? 150,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniNutrientProgress(
                  label: l10n.fat,
                  current: summary.fat,
                  goal: goals?.fatGoal ?? 65,
                  color: Colors.yellow[700]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniNutrientProgress(
                  label: l10n.carbs,
                  current: summary.carbs,
                  goal: goals?.carbsGoal ?? 200,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DiaryProvider provider) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      provider.selectDate(pickedDate);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _NutrientProgress extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;

  const _NutrientProgress({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (current / goal * 100).clamp(0, 100);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                Text(
                  current.toStringAsFixed(0),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  l10n.slashSeparator + goal.toStringAsFixed(0),
                  style: TextStyle(color: theme.disabledColor),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: current / goal,
          backgroundColor: theme.colorScheme.surfaceContainer,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 12, color: theme.disabledColor),
        ),
      ],
    );
  }
}

class _MiniNutrientProgress extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;

  const _MiniNutrientProgress({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (current / goal).clamp(0, 1),
          backgroundColor: theme.colorScheme.surfaceContainer,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              current.toStringAsFixed(0) + l10n.grams,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              l10n.slashSeparator + goal.toStringAsFixed(0) + l10n.grams,
              style: TextStyle(color: theme.disabledColor),
            ),
          ],
        ),
      ],
    );
  }
}
