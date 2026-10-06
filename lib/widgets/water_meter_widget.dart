import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';

class WaterMeterWidget extends StatelessWidget {
  const WaterMeterWidget({super.key});

  @override
  Widget build(BuildContext me) {
    final provider = Provider.of<WaterProvider>(me);
    final todayLiters = provider.todayTotalLiters;
    final goalLiters = provider.dailyGoalLiters;
    final percent = (todayLiters / goalLiters).clamp(0.0, 1.0);
    final theme = Theme.of(me);

    Color getProgressColor() {
      if (percent < 0.6) return const Color(0xFF06B6D4); // Cyan/Aqua
      if (percent < 0.85) return const Color(0xFF0284C7); // Ocean Blue
      if (percent <= 1.0) return const Color(0xFFF59E0B); // Amber Warning
      return const Color(0xFFEF4444); // Red Over limit
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Consumption',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Goal: ${goalLiters.toStringAsFixed(0)} Liters / day',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.todaySavingsPercentage >= 0
                        ? const Color(0xFF10B981).withOpacity(0.15)
                        : const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.todaySavingsPercentage >= 0
                            ? Icons.trending_down
                            : Icons.trending_up,
                        size: 16,
                        color: provider.todaySavingsPercentage >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.todaySavingsPercentage.abs().toStringAsFixed(0)}% ${provider.todaySavingsPercentage >= 0 ? 'Saved' : 'Over'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: provider.todaySavingsPercentage >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CircularPercentIndicator(
              radius: 95.0,
              lineWidth: 16.0,
              animation: true,
              percent: percent,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: getProgressColor(),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 32,
                    color: getProgressColor(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    todayLiters.toStringAsFixed(1),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'LITERS USED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${((1 - percent) * goalLiters).clamp(0, goalLiters).toStringAsFixed(0)}L remaining',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: getProgressColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubStat(
                  theme,
                  label: 'Est. Cost',
                  value: '\$${(todayLiters * 0.0035).toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  iconColor: Colors.teal,
                ),
                Container(height: 30, width: 1, color: theme.dividerColor.withOpacity(0.3)),
                _buildSubStat(
                  theme,
                  label: 'Baseline',
                  value: '${provider.householdBaselineLiters.toStringAsFixed(0)} L',
                  icon: Icons.analytics_outlined,
                  iconColor: Colors.blueAccent,
                ),
                Container(height: 30, width: 1, color: theme.dividerColor.withOpacity(0.3)),
                _buildSubStat(
                  theme,
                  label: 'Status',
                  value: percent <= 1.0 ? 'Optimal' : 'Exceeded',
                  icon: percent <= 1.0 ? Icons.check_circle : Icons.warning_amber,
                  iconColor: percent <= 1.0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubStat(
    ThemeData theme, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
