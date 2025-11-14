import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/custom_colors.dart';
import '../services/database_service.dart';
import '../models/user_goals.dart';
import '../l10n/app_localizations.dart';

class CalorieTrendChart extends StatelessWidget {
  final List<DailySummary> weeklySummaries;
  final UserGoals? goals;

  const CalorieTrendChart({
    super.key,
    required this.weeklySummaries,
    this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxCalories = weeklySummaries
        .map((s) => s.calories)
        .fold(0.0, (max, val) => val > max ? val : max);
    final goalCalories = goals?.caloriesGoal ?? 2000.0;
    final chartMaxY =
        (maxCalories > goalCalories ? maxCalories : goalCalories) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weeklyCalorieTrend,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.last7Days,
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
                  maxY: chartMaxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: chartMaxY / 5,
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
                        reservedSize: 50,
                        interval: chartMaxY / 5,
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
                    // Goal line
                    if (goals != null)
                      LineChartBarData(
                        spots: [
                          FlSpot(0, goalCalories),
                          FlSpot(6, goalCalories),
                        ],
                        isCurved: false,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha((0.5 * 255).toInt()),
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        dashArray: [5, 5],
                        belowBarData: BarAreaData(show: false),
                      ),
                    // Actual calories line
                    LineChartBarData(
                      spots: List.generate(
                        weeklySummaries.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          weeklySummaries[index].calories,
                        ),
                      ),
                      isCurved: true,
                      color: context.customColors.caloriesColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: context.customColors.caloriesColor,
                            strokeWidth: 2,
                            strokeColor: Theme.of(context).colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: context.customColors.caloriesColor
                            .withAlpha((0.2 * 255).toInt()),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          if (touchedSpot.barIndex == 0 && goals != null) {
                            // Goal line
                            return LineTooltipItem(
                              '${l10n.goal}: ${goalCalories.toInt()} ${l10n.kcal}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          } else {
                            // Actual calories line
                            final dayIndex = touchedSpot.x.toInt();
                            final today = DateTime.now();
                            final date = DateTime(
                              today.year,
                              today.month,
                              today.day - (6 - dayIndex),
                            );
                            final formattedDate =
                                DateFormat('MMM d').format(date);

                            return LineTooltipItem(
                              '$formattedDate\n${touchedSpot.y.toInt()} ${l10n.kcal}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }
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
                    l10n.actual, context.customColors.caloriesColor),
                if (goals != null) ...[
                  const SizedBox(width: 24),
                  _buildLegendItem(
                      l10n.goal,
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha((0.5 * 255).toInt()),
                      isDashed: true),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
          ),
          child: isDashed
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 8),
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

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
