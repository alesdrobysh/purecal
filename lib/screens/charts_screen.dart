import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/diary_provider.dart';
import '../services/database_service.dart';
import '../widgets/macro_pie_chart.dart';
import '../widgets/calorie_trend_chart.dart';
import '../l10n/app_localizations.dart';
import '../widgets/macro_trend_chart.dart';
import '../config/decorations.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DailySummary>? _weeklySummaries;
  DailySummary? _todaySummary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<DiaryProvider>(context, listen: false);
      final weeklySummaries = await provider.getWeeklySummaries();
      final todaySummary = await provider.getTodaySummary();

      if (mounted) {
        setState(() {
          _weeklySummaries = weeklySummaries;
          _todaySummary = todaySummary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.errorLoadingProduct(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionCharts),
        backgroundColor: AppColors.green,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.pie_chart),
              text: l10n.today,
            ),
            Tab(
              icon: const Icon(Icons.show_chart),
              text: l10n.week,
            ),
          ],
        ),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(DiaryProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingCharts),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_weeklySummaries == null || _todaySummary == null) {
      return Center(
        child: Text(l10n.noDataAvailable),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Today tab
        _TodayTab(todaySummary: _todaySummary!, provider: provider),
        // Week tab
        _WeekTab(weeklySummaries: _weeklySummaries!, provider: provider),
      ],
    );
  }
}

class _TodayTab extends StatelessWidget {
  final DailySummary todaySummary;
  final DiaryProvider provider;

  const _TodayTab({
    required this.todaySummary,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MacroPieChart(summary: todaySummary),
          const SizedBox(height: 16),
          _TodayStats(todaySummary: todaySummary, provider: provider),
        ],
      ),
    );
  }
}

class _TodayStats extends StatelessWidget {
  final DailySummary todaySummary;
  final DiaryProvider provider;

  const _TodayStats({
    required this.todaySummary,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goals = provider.userGoals;

    if (goals == null) {
      return const SizedBox.shrink();
    }

    final caloriePercent = (todaySummary.calories / goals.caloriesGoal * 100);
    final proteinPercent = (todaySummary.proteins / goals.proteinsGoal * 100);
    final fatPercent = (todaySummary.fat / goals.fatGoal * 100);
    final carbsPercent = (todaySummary.carbs / goals.carbsGoal * 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.goalAchievement,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _GoalItem(
              label: l10n.calories,
              percent: caloriePercent,
              actual: todaySummary.calories,
              goal: goals.caloriesGoal,
              unit: l10n.kcal,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _GoalItem(
              label: l10n.protein,
              percent: proteinPercent,
              actual: todaySummary.proteins,
              goal: goals.proteinsGoal,
              unit: l10n.grams,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _GoalItem(
              label: l10n.fat,
              percent: fatPercent,
              actual: todaySummary.fat,
              goal: goals.fatGoal,
              unit: l10n.grams,
              color: Colors.yellow[700] ?? Colors.yellow,
            ),
            const SizedBox(height: 12),
            _GoalItem(
              label: l10n.carbs,
              percent: carbsPercent,
              actual: todaySummary.carbs,
              goal: goals.carbsGoal,
              unit: l10n.grams,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalItem extends StatelessWidget {
  final String label;
  final double percent;
  final double actual;
  final double goal;
  final String unit;
  final Color color;

  const _GoalItem({
    required this.label,
    required this.percent,
    required this.actual,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${actual.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
              style: TextStyle(
                fontSize: 12,
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0.0, 1.0),
                backgroundColor: theme.colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              child: Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: percent > 100 ? Colors.red : color,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeekTab extends StatelessWidget {
  final List<DailySummary> weeklySummaries;
  final DiaryProvider provider;

  const _WeekTab({
    required this.weeklySummaries,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalorieTrendChart(
            weeklySummaries: weeklySummaries,
            goals: provider.userGoals,
          ),
          const SizedBox(height: 16),
          MacroTrendChart(weeklySummaries: weeklySummaries),
        ],
      ),
    );
  }
}
