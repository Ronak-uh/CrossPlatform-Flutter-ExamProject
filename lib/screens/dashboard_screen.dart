import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/water_usage_record.dart';
import '../providers/water_provider.dart';
import '../widgets/water_meter_widget.dart';
import '../widgets/usage_chart_widget.dart';
import '../widgets/add_usage_modal.dart';
import '../widgets/tip_card_widget.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context);
    final activeAlerts = provider.activeAlertsCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner for Active Leak Alerts if present
          if (activeAlerts > 0) ...[
            GestureDetector(
              onTap: () => onNavigateTab(2), // Navigate to Leak Detector tab
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$activeAlerts Active Leak Alert${activeAlerts > 1 ? 's' : ''} Detected!',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEF4444),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tap to review sensor location & control valve',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFEF4444)),
                  ],
                ),
              ),
            ),
          ],

          // Water Gauge Header Card
          const WaterMeterWidget(),

          const SizedBox(height: 16),

          // Quick Action Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'Log Usage',
                    color: theme.colorScheme.primary,
                    onTap: () => AddUsageModal.show(context),
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: provider.isSmartValveOpen
                        ? Icons.water_drop_outlined
                        : Icons.power_off_outlined,
                    label: provider.isSmartValveOpen ? 'Valve Open' : 'Valve Off',
                    color: provider.isSmartValveOpen ? Colors.teal : Colors.purple,
                    onTap: () => onNavigateTab(2),
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: provider.isLiveSimulationRunning
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    label: provider.isLiveSimulationRunning ? 'Sim: ON' : 'Live Sim',
                    color: provider.isLiveSimulationRunning ? const Color(0xFF10B981) : Colors.orange,
                    onTap: () {
                      provider.toggleLiveSimulation();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.isLiveSimulationRunning
                                ? 'Live Smart Meter stream started!'
                                : 'Live simulation paused.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.lightbulb_outline,
                    label: 'Tips',
                    color: Colors.amber.shade700,
                    onTap: () => onNavigateTab(3),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Weekly Trend Preview Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              Text(
                '7-Day Consumption Trend',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => onNavigateTab(1),
                child: const Text('View Detailed Logs'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  UsageChartWidget(
                    dailyData: provider.past7DaysUsage,
                    dailyGoal: provider.dailyGoalLiters,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Appliance & Room Breakdown
          Text(
            'Today\'s Usage by Activity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: WaterCategory.values.map((cat) {
                  final catLiters = provider.todayCategoryBreakdown[cat] ?? 0.0;
                  final totalLiters = provider.todayTotalLiters;
                  final double pct = totalLiters > 0 ? (catLiters / totalLiters) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _getCategoryIconWidget(cat, theme),
                                const SizedBox(width: 10),
                                Text(
                                  cat.displayName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${catLiters.toStringAsFixed(1)} L (${(pct * 100).toStringAsFixed(0)}%)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                            color: _getCategoryColor(cat),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Featured Conservation Tip
          if (provider.tips.isNotEmpty) ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                Text(
                  'Daily Conservation Guidance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(3),
                  child: const Text('All Tips'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TipCardWidget(tip: provider.tips.first),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIconWidget(WaterCategory cat, ThemeData theme) {
    IconData icon;
    switch (cat) {
      case WaterCategory.shower:
        icon = Icons.shower;
        break;
      case WaterCategory.kitchen:
        icon = Icons.soup_kitchen;
        break;
      case WaterCategory.garden:
        icon = Icons.grass;
        break;
      case WaterCategory.laundry:
        icon = Icons.local_laundry_service;
        break;
      case WaterCategory.toilet:
        icon = Icons.wc;
        break;
      case WaterCategory.other:
        icon = Icons.water_drop;
        break;
    }
    return Icon(icon, size: 18, color: _getCategoryColor(cat));
  }

  Color _getCategoryColor(WaterCategory cat) {
    switch (cat) {
      case WaterCategory.shower:
        return const Color(0xFF0284C7);
      case WaterCategory.kitchen:
        return const Color(0xFF06B6D4);
      case WaterCategory.garden:
        return const Color(0xFF10B981);
      case WaterCategory.laundry:
        return const Color(0xFF8B5CF6);
      case WaterCategory.toilet:
        return const Color(0xFFF59E0B);
      case WaterCategory.other:
        return const Color(0xFF64748B);
    }
  }
}
