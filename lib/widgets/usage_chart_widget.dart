import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UsageChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;
  final double dailyGoal;

  const UsageChartWidget({
    super.key,
    required this.dailyData,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxUsage = dailyData.fold<double>(
      dailyGoal * 1.2,
      (max, item) => (item['liters'] as double) > max ? (item['liters'] as double) : max,
    );

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, left: 0, top: 12, bottom: 8),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxUsage * 1.1,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => theme.colorScheme.primaryContainer,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final day = dailyData[groupIndex]['day'];
                  final liters = (dailyData[groupIndex]['liters'] as double).toStringAsFixed(1);
                  return BarTooltipItem(
                    '$day\n$liters Liters',
                    TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    if (value % 50 == 0 && value > 0) {
                      return Text(
                        '${value.toInt()}L',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < dailyData.length) {
                      final isToday = dailyData[index]['isToday'] as bool;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dailyData[index]['day'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            color: isToday
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 50,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: theme.dividerColor.withOpacity(0.15),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              },
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: dailyGoal,
                  color: const Color(0xFFF59E0B),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 8, bottom: 2),
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    labelResolver: (line) => 'Goal (${dailyGoal.toInt()}L)',
                  ),
                ),
              ],
            ),
            barGroups: dailyData.asMap().entries.map((entry) {
              final idx = entry.key;
              final val = entry.value['liters'] as double;
              final isToday = entry.value['isToday'] as bool;
              final isOverGoal = val > dailyGoal;

              return BarChartGroupData(
                x: idx,
                barRods: [
                  BarChartRodData(
                    toY: val,
                    gradient: LinearGradient(
                      colors: isOverGoal
                          ? [const Color(0xFFF87171), const Color(0xFFEF4444)]
                          : isToday
                              ? [const Color(0xFF38BDF8), const Color(0xFF0284C7)]
                              : [const Color(0xFF94A3B8), const Color(0xFF64748B)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: isToday ? 16 : 14,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
