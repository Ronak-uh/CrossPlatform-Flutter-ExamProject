import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/leak_alert.dart';
import '../providers/water_provider.dart';

class LeakCardWidget extends StatelessWidget {
  final LeakAlert alert;

  const LeakCardWidget({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context, listen: false);

    Color getSeverityColor() {
      switch (alert.severity) {
        case LeakSeverity.critical:
          return const Color(0xFFEF4444);
        case LeakSeverity.warning:
          return const Color(0xFFF59E0B);
        case LeakSeverity.info:
          return const Color(0xFF3B82F6);
      }
    }

    Color getStatusColor() {
      switch (alert.status) {
        case LeakStatus.active:
          return const Color(0xFFEF4444);
        case LeakStatus.acknowledged:
          return const Color(0xFFF59E0B);
        case LeakStatus.valveClosed:
          return const Color(0xFF8B5CF6);
        case LeakStatus.resolved:
          return const Color(0xFF10B981);
        case LeakStatus.falseAlarm:
          return const Color(0xFF64748B);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: alert.status == LeakStatus.active
              ? getSeverityColor().withOpacity(0.6)
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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: getSeverityColor().withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    alert.severity == LeakSeverity.critical
                        ? Icons.warning_sharp
                        : Icons.water_damage_outlined,
                    color: getSeverityColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.location,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sensor ${alert.sensorId} • ${DateFormat('MMM d, h:mm a').format(alert.detectedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alert.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 18, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Flow Rate:',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Text(
                    '${alert.flowRateLPM.toStringAsFixed(1)} Liters / min',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: getSeverityColor(),
                    ),
                  ),
                ],
              ),
            ),
            if (alert.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                alert.notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Recommended Mitigation Steps:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ...alert.mitigationSteps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          step,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (alert.status == LeakStatus.active)
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.updateLeakStatus(alert.id, LeakStatus.acknowledged);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Leak alert acknowledged.')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Acknowledge'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                if (alert.status == LeakStatus.active ||
                    alert.status == LeakStatus.acknowledged) ...[
                  ElevatedButton.icon(
                    onPressed: () => _showEmergencyValveDialog(context, provider),
                    icon: const Icon(Icons.power_settings_new, size: 16),
                    label: const Text('Shut Off Main Valve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.updateLeakStatus(alert.id, LeakStatus.resolved);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Leak marked as resolved!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    icon: const Icon(Icons.task_alt, size: 16),
                    label: const Text('Mark Resolved'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
                if (alert.status == LeakStatus.valveClosed ||
                    alert.status == LeakStatus.resolved)
                  Chip(
                    avatar: const Icon(Icons.check, size: 14, color: Colors.white),
                    label: const Text('Resolved / Secured'),
                    backgroundColor: const Color(0xFF10B981),
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyValveDialog(BuildContext context, WaterProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Emergency Water Valve'),
          ],
        ),
        content: const Text(
          'Are you sure you want to close the Smart Main Water Valve? This will shut off water supply to the entire household to stop active leaks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.toggleSmartValve();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Smart Main Water Valve SHUT OFF.'),
                  backgroundColor: Color(0xFF8B5CF6),
                ),
              );
            },
            child: const Text('CONFIRM SHUT OFF'),
          ),
        ],
      ),
    );
  }
}
