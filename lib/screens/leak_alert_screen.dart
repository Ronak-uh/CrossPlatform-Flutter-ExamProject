import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/leak_alert.dart';
import '../providers/water_provider.dart';
import '../widgets/leak_card_widget.dart';

class LeakAlertScreen extends StatefulWidget {
  const LeakAlertScreen({super.key});

  @override
  State<LeakAlertScreen> createState() => _LeakAlertScreenState();
}

class _LeakAlertScreenState extends State<LeakAlertScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Active, 2: Resolved

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context);

    final alerts = provider.leakAlerts.where((a) {
      if (_selectedFilterIndex == 1) {
        return a.status == LeakStatus.active || a.status == LeakStatus.acknowledged;
      }
      if (_selectedFilterIndex == 2) {
        return a.status == LeakStatus.resolved ||
            a.status == LeakStatus.valveClosed ||
            a.status == LeakStatus.falseAlarm;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Smart Main Water Valve Controller Card
          Card(
            color: provider.isSmartValveOpen
                ? theme.colorScheme.surface
                : const Color(0xFF8B5CF6).withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: provider.isSmartValveOpen
                    ? const Color(0xFF10B981).withOpacity(0.4)
                    : const Color(0xFF8B5CF6),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: provider.isSmartValveOpen
                                  ? const Color(0xFF10B981).withOpacity(0.15)
                                  : const Color(0xFF8B5CF6).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              provider.isSmartValveOpen
                                  ? Icons.water_drop
                                  : Icons.power_settings_new,
                              color: provider.isSmartValveOpen
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF8B5CF6),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Main Valve',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                provider.isSmartValveOpen
                                    ? 'Water Supply: ACTIVE (4.2 Bar)'
                                    : 'Water Supply: SHUT OFF / SECURED',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: provider.isSmartValveOpen
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: provider.isSmartValveOpen,
                        activeColor: const Color(0xFF10B981),
                        inactiveThumbColor: const Color(0xFF8B5CF6),
                        onChanged: (val) {
                          provider.toggleSmartValve();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                val ? 'Main Water Valve OPENED.' : 'Main Water Valve SHUT OFF.',
                              ),
                              backgroundColor:
                                  val ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Auto-Shutoff on Critical Leak:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ENABLED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Smart Sensors Network Section
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              Text(
                'IoT Sensor Network Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  provider.triggerSimulatedLeak();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚡ Triggered Simulated Pipe Leak Alert!'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                },
                icon: const Icon(Icons.bolt, size: 16, color: Color(0xFFEF4444)),
                label: const Text(
                  'Simulate Leak',
                  style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Sensors Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildSensorTile(
                theme,
                name: 'Master Bathroom',
                sensorId: 'SN-402',
                status: 'Normal',
                flowLPM: 0.0,
                isWarning: false,
              ),
              _buildSensorTile(
                theme,
                name: 'Garden Irrigation',
                sensorId: 'SN-GARDEN-02',
                status: 'Leak Detected',
                flowLPM: 6.4,
                isWarning: true,
              ),
              _buildSensorTile(
                theme,
                name: 'Kitchen Sink',
                sensorId: 'SN-105',
                status: 'Normal',
                flowLPM: 0.0,
                isWarning: false,
              ),
              _buildSensorTile(
                theme,
                name: 'Laundry Hookup',
                sensorId: 'SN-309',
                status: 'Normal',
                flowLPM: 0.0,
                isWarning: false,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Leak Alert Filter Tabs
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              Text(
                'Leak Alerts Log',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('All')),
                  ButtonSegment(value: 1, label: Text('Active')),
                  ButtonSegment(value: 2, label: Text('Resolved')),
                ],
                selected: {_selectedFilterIndex},
                onSelectionChanged: (set) {
                  setState(() {
                    _selectedFilterIndex = set.first;
                  });
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Alerts List
          if (alerts.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.shield_outlined, size: 52, color: Color(0xFF10B981)),
                    const SizedBox(height: 12),
                    Text(
                      'No alerts in this category.',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your smart water system is operating leak-free!',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length,
              itemBuilder: (ctx, index) {
                return LeakCardWidget(alert: alerts[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorTile(
    ThemeData theme, {
    required String name,
    required String sensorId,
    required String status,
    required double flowLPM,
    required bool isWarning,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFEF4444).withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFEF4444).withOpacity(0.5)
              : theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                isWarning ? Icons.sensors_off : Icons.sensors,
                color: isWarning ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                size: 20,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isWarning ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$sensorId • ${flowLPM > 0 ? '${flowLPM.toStringAsFixed(1)} L/m' : status}',
                style: TextStyle(
                  fontSize: 11,
                  color: isWarning ? const Color(0xFFEF4444) : theme.textTheme.bodySmall?.color,
                  fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
