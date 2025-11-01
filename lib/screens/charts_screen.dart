import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/diary_provider.dart';
import '../services/database_service.dart';
import '../widgets/macro_pie_chart.dart';
import '../widgets/calorie_trend_chart.dart';
import '../widgets/macro_trend_chart.dart';

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
          _errorMessage = 'Failed to load chart data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Charts'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.pie_chart),
              text: 'Today',
            ),
            Tab(
              icon: Icon(Icons.show_chart),
              text: 'Week',
            ),
          ],
        ),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(DiaryProvider provider) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading charts...'),
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
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_weeklySummaries == null || _todaySummary == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Today tab
        _buildTodayTab(_todaySummary!, provider),
        // Week tab
        _buildWeekTab(_weeklySummaries!, provider),
      ],
    );
  }

  Widget _buildTodayTab(DailySummary todaySummary, DiaryProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MacroPieChart(summary: todaySummary),
          const SizedBox(height: 16),
          _buildTodayStats(todaySummary, provider),
        ],
      ),
    );
  }

  Widget _buildTodayStats(DailySummary todaySummary, DiaryProvider provider) {
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
            const Text(
              'Goal Achievement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalItem(
              'Calories',
              caloriePercent,
              todaySummary.calories,
              goals.caloriesGoal,
              'kcal',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              'Protein',
              proteinPercent,
              todaySummary.proteins,
              goals.proteinsGoal,
              'g',
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              'Fat',
              fatPercent,
              todaySummary.fat,
              goals.fatGoal,
              'g',
              Colors.yellow[700] ?? Colors.yellow,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              'Carbs',
              carbsPercent,
              todaySummary.carbs,
              goals.carbsGoal,
              'g',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(
    String label,
    double percent,
    double actual,
    double goal,
    String unit,
    Color color,
  ) {
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
                color: Colors.grey[600],
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
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
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

  Widget _buildWeekTab(List<DailySummary> weeklySummaries, DiaryProvider provider) {
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
