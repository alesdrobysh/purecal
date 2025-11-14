import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/custom_colors.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

class MacroTrendChart extends StatelessWidget {
  final List<DailySummary> weeklySummaries;

  const MacroTrendChart({
    super.key,
    required this.weeklySummaries,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxProtein = weeklySummaries
        .map((s) => s.proteins)
        .fold(0.0, (max, val) => val > max ? val : max);
    final maxFat = weeklySummaries
        .map((s) => s.fat)
        .fold(0.0, (max, val) => val > max ? val : max);
    final maxCarbs = weeklySummaries
        .map((s) => s.carbs)
        .fold(0.0, (max, val) => val > max ? val : max);

    final chartMaxY =
        ([maxProtein, maxFat, maxCarbs].reduce((a, b) => a > b ? a : b)) * 1.2;
    final safeChartMaxY = chartMaxY > 0 ? chartMaxY : 10.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weeklyMacroTrends,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.proteinFatCarbsGrams,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: safeChartMaxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: safeChartMaxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: safeChartMaxY / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final dayIndex = value.toInt();
                          if (dayIndex < 0 || dayIndex >= 7) {
                            return const SizedBox();
                          }

                          final today = DateTime.now();
                          final date = DateTime(
                            today.year,
                            today.month,
                            today.day - (6 - dayIndex),
                          );
                          final dayName = DateFormat('EEE').format(date);

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dayName,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    // Protein line
                    LineChartBarData(
                      spots: List.generate(
                        weeklySummaries.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          weeklySummaries[index].proteins,
                        ),
                      ),
                      isCurved: true,
                      color: context.customColors.proteinColor,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: context.customColors.proteinColor,
                            strokeWidth: 1.5,
                            strokeColor: Theme.of(context).colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Fat line
                    LineChartBarData(
                      spots: List.generate(
                        weeklySummaries.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          weeklySummaries[index].fat,
                        ),
                      ),
                      isCurved: true,
                      color: context.customColors.fatColor,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: context.customColors.fatColor,
                            strokeWidth: 1.5,
                            strokeColor: Theme.of(context).colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Carbs line
                    LineChartBarData(
                      spots: List.generate(
                        weeklySummaries.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          weeklySummaries[index].carbs,
                        ),
                      ),
                      isCurved: true,
                      color: context.customColors.carbsColor,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: context.customColors.carbsColor,
                            strokeWidth: 1.5,
                            strokeColor: Theme.of(context).colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final dayIndex = touchedSpot.x.toInt();
                          final today = DateTime.now();
                          final date = DateTime(
                            today.year,
                            today.month,
                            today.day - (6 - dayIndex),
                          );
                          final formattedDate =
                              DateFormat('MMM d').format(date);

                          String macroName;
                          switch (touchedSpot.barIndex) {
                            case 0:
                              macroName = l10n.protein;
                              break;
                            case 1:
                              macroName = l10n.fat;
                              break;
                            case 2:
                              macroName = l10n.carbs;
                              break;
                            default:
                              macroName = '';
                          }

                          return LineTooltipItem(
                            '$formattedDate\n$macroName: ${touchedSpot.y.toStringAsFixed(1)}${l10n.grams}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                    l10n.protein, context.customColors.proteinColor),
                const SizedBox(width: 16),
                _buildLegendItem(l10n.fat, context.customColors.fatColor),
                const SizedBox(width: 16),
                _buildLegendItem(l10n.carbs, context.customColors.carbsColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
