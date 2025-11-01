import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class MacroTrendChart extends StatelessWidget {
  final List<DailySummary> weeklySummaries;

  const MacroTrendChart({
    super.key,
    required this.weeklySummaries,
  });

  @override
  Widget build(BuildContext context) {
    final maxProtein = weeklySummaries
        .map((s) => s.proteins)
        .fold(0.0, (max, val) => val > max ? val : max);
    final maxFat = weeklySummaries
        .map((s) => s.fat)
        .fold(0.0, (max, val) => val > max ? val : max);
    final maxCarbs = weeklySummaries
        .map((s) => s.carbs)
        .fold(0.0, (max, val) => val > max ? val : max);

    final chartMaxY = ([maxProtein, maxFat, maxCarbs].reduce((a, b) => a > b ? a : b)) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Macro Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Protein, Fat & Carbs (grams)',
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
                        reservedSize: 40,
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
                      color: Colors.red,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Colors.red,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
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
                      color: Colors.yellow[700]!,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Colors.yellow[700]!,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
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
                      color: Colors.blue,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Colors.blue,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
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
                          final formattedDate = DateFormat('MMM d').format(date);

                          String macroName;
                          switch (touchedSpot.barIndex) {
                            case 0:
                              macroName = 'Protein';
                              break;
                            case 1:
                              macroName = 'Fat';
                              break;
                            case 2:
                              macroName = 'Carbs';
                              break;
                            default:
                              macroName = '';
                          }

                          return LineTooltipItem(
                            '$formattedDate\n$macroName: ${touchedSpot.y.toStringAsFixed(1)}g',
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
                _buildLegendItem('Protein', Colors.red),
                const SizedBox(width: 16),
                _buildLegendItem('Fat', Colors.yellow[700]!),
                const SizedBox(width: 16),
                _buildLegendItem('Carbs', Colors.blue),
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
