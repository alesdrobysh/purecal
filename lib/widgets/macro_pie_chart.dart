import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

class MacroPieChart extends StatelessWidget {
  final DailySummary summary;

  const MacroPieChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalMacros = summary.proteins + summary.fat + summary.carbs;

    // Handle case with no data
    if (totalMacros == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                l10n.noMacroDataForToday,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addSomeFoodToSeeMacros,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final proteinPercentage = (summary.proteins / totalMacros * 100);
    final fatPercentage = (summary.fat / totalMacros * 100);
    final carbsPercentage = (summary.carbs / totalMacros * 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todaysMacroBreakdown,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: summary.proteins,
                          title: '${proteinPercentage.toStringAsFixed(1)}%',
                          color: Colors.red,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: summary.fat,
                          title: '${fatPercentage.toStringAsFixed(1)}%',
                          color: Colors.yellow[700]!,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: summary.carbs,
                          title: '${carbsPercentage.toStringAsFixed(1)}%',
                          color: Colors.blue,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      pieTouchData: PieTouchData(
                        touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(
                      l10n.protein,
                      '${summary.proteins.toStringAsFixed(1)}g',
                      Colors.red,
                    ),
                    _buildLegendItem(
                      l10n.fat,
                      '${summary.fat.toStringAsFixed(1)}g',
                      Colors.yellow[700]!,
                    ),
                    _buildLegendItem(
                      l10n.carbs,
                      '${summary.carbs.toStringAsFixed(1)}g',
                      Colors.blue,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
