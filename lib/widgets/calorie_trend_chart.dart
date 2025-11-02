import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/user_goals.dart';
import '../config/decorations.dart';

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
    final maxCalories = weeklySummaries
        .map((s) => s.calories)
        .fold(0.0, (max, val) => val > max ? val : max);
    final goalCalories = goals?.caloriesGoal ?? 2000.0;
    final chartMaxY = (maxCalories > goalCalories ? maxCalories : goalCalories) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Calorie Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last 7 days',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
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
                              color: Colors.grey[600],
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
                          if (dayIndex < 0 || dayIndex >= 7) return const SizedBox();

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
                                color: Colors.grey[600],
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
                      color: Colors.grey[300]!,
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
                        color: AppColors.green.withAlpha((0.5 * 255).toInt()),
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
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.orange,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withAlpha((0.2 * 255).toInt()),
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
                              'Goal: ${goalCalories.toInt()} kcal',
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
                            final formattedDate = DateFormat('MMM d').format(date);

                            return LineTooltipItem(
                              '$formattedDate\n${touchedSpot.y.toInt()} kcal',
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
                _buildLegendItem('Actual', Colors.orange),
                if (goals != null) ...[
                  const SizedBox(width: 24),
                  _buildLegendItem('Goal', AppColors.green.withAlpha((0.5 * 255).toInt()), isDashed: true),
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
