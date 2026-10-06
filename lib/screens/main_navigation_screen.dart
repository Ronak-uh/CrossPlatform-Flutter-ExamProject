import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import 'dashboard_screen.dart';
import 'usage_history_screen.dart';
import 'leak_alert_screen.dart';
import 'conservation_tips_screen.dart';
import 'community_challenges_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context);
    final activeAlerts = provider.activeAlertsCount;
    final isWideScreen = MediaQuery.of(context).size.width >= 768;

    final pages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const UsageHistoryScreen(),
      const LeakAlertScreen(),
      const ConservationTipsScreen(),
      const CommunityChallengesScreen(),
    ];

    final titles = [
      'WaterSave Dashboard',
      'Usage History & Analytics',
      'Leak Alert & Sensor Hub',
      'Conservation Tips',
      'Community Challenges',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.water_drop,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titles[_currentIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                // Alert Badge Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Leak Alerts',
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => _onTabTapped(2),
                    ),
                    if (activeAlerts > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$activeAlerts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Settings Modal Icon
                IconButton(
                  tooltip: 'Daily Goal Settings',
                  icon: const Icon(Icons.tune),
                  onPressed: () => _showSettingsDialog(context, provider),
                ),
                // Dark/Light Theme Toggle Action
                IconButton(
                  tooltip: provider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  icon: Icon(
                    provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () {
                    provider.toggleTheme();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabTapped,
              labelType: NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: Text('Usage'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: activeAlerts > 0,
                    label: Text('$activeAlerts'),
                    child: const Icon(Icons.warning_amber_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: activeAlerts > 0,
                    label: Text('$activeAlerts'),
                    child: const Icon(Icons.warning_amber),
                  ),
                  label: const Text('Leak Alert'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.lightbulb_outline),
                  selectedIcon: Icon(Icons.lightbulb),
                  label: Text('Tips'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: Text('Community'),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabTapped,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Usage',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: activeAlerts > 0,
                    label: Text('$activeAlerts'),
                    child: const Icon(Icons.warning_amber_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: activeAlerts > 0,
                    label: Text('$activeAlerts'),
                    child: const Icon(Icons.warning_amber),
                  ),
                  label: 'Leak Alert',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.lightbulb_outline),
                  selectedIcon: Icon(Icons.lightbulb),
                  label: 'Tips',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: 'Community',
                ),
              ],
            ),
    );
  }

  void _showSettingsDialog(BuildContext context, WaterProvider provider) {
    final controller = TextEditingController(
      text: provider.dailyGoalLiters.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.tune, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('Water Goal Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set your daily household water consumption target (in Liters):',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Goal (Liters)',
                border: OutlineInputBorder(),
                suffixText: 'L/day',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 10) {
                provider.setDailyGoal(val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Daily water target updated to ${val.toInt()} Liters!'),
                  ),
                );
              }
            },
            child: const Text('Save Goal'),
          ),
        ],
      ),
    );
  }
}
