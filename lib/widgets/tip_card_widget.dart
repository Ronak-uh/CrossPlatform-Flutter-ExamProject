import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conservation_tip.dart';
import '../providers/water_provider.dart';

class TipCardWidget extends StatelessWidget {
  final ConservationTip tip;

  const TipCardWidget({
    super.key,
    required this.tip,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shower':
        return Icons.shower;
      case 'wc':
        return Icons.wc;
      case 'kitchen':
        return Icons.kitchen;
      case 'grass':
        return Icons.grass;
      case 'water_drop':
        return Icons.water_drop;
      case 'umbrella':
        return Icons.beach_access;
      default:
        return Icons.lightbulb_outline;
    }
  }

  Color _getImpactColor(ImpactLevel impact) {
    switch (impact) {
      case ImpactLevel.high:
        return const Color(0xFF10B981); // Emerald
      case ImpactLevel.medium:
        return const Color(0xFF0284C7); // Water Blue
      case ImpactLevel.low:
        return const Color(0xFF64748B); // Slate
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: tip.isCompleted
              ? const Color(0xFF10B981).withOpacity(0.5)
              : tip.isPledged
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconData(tip.iconName),
                    color: theme.colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getImpactColor(tip.impact).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tip.impact.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getImpactColor(tip.impact),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tip.category.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tip.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tip.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.opacity, size: 16, color: Color(0xFF0284C7)),
                      const SizedBox(width: 6),
                      Text(
                        'Estimated Daily Savings:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${tip.savingsPerDayLiters.toInt()} Liters / day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Difficulty: ${tip.difficulty}',
                  style: theme.textTheme.bodySmall,
                ),
                Row(
                  children: [
                    FilterChip(
                      avatar: Icon(
                        tip.isPledged ? Icons.bookmark : Icons.bookmark_border,
                        size: 16,
                        color: tip.isPledged ? Colors.white : theme.colorScheme.primary,
                      ),
                      label: Text(tip.isPledged ? 'Pledged' : 'Pledge Tip'),
                      selected: tip.isPledged,
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: tip.isPledged ? Colors.white : theme.textTheme.bodyMedium?.color,
                      ),
                      onSelected: (_) {
                        provider.toggleTipPledge(tip.id);
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: tip.isCompleted ? 'Completed!' : 'Mark Completed',
                      icon: Icon(
                        tip.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: tip.isCompleted
                            ? const Color(0xFF10B981)
                            : theme.iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: () {
                        provider.toggleTipCompleted(tip.id);
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
