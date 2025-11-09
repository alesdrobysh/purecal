import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/custom_colors.dart';
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
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noMacroDataForToday,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addSomeFoodToSeeMacros,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          color: context.customColors.proteinColor,
                          radius: 80,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        PieChartSectionData(
                          value: summary.fat,
                          title: '${fatPercentage.toStringAsFixed(1)}%',
                          color: context.customColors.fatColor,
                          radius: 80,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        PieChartSectionData(
                          value: summary.carbs,
                          title: '${carbsPercentage.toStringAsFixed(1)}%',
                          color: context.customColors.carbsColor,
                          radius: 80,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
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
                      context,
                      l10n.protein,
                      '${summary.proteins.toStringAsFixed(1)}g',
                      context.customColors.proteinColor,
                    ),
                    _buildLegendItem(
                      context,
                      l10n.fat,
                      '${summary.fat.toStringAsFixed(1)}g',
                      context.customColors.fatColor,
                    ),
                    _buildLegendItem(
                      context,
                      l10n.carbs,
                      '${summary.carbs.toStringAsFixed(1)}g',
                      context.customColors.carbsColor,
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

  Widget _buildLegendItem(BuildContext context, String label, String value, Color color) {
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
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
