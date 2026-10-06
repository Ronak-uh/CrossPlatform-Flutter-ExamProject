import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/water_usage_record.dart';
import '../providers/water_provider.dart';
import '../widgets/add_usage_modal.dart';
import '../widgets/usage_chart_widget.dart';

class UsageHistoryScreen extends StatefulWidget {
  const UsageHistoryScreen({super.key});

  @override
  State<UsageHistoryScreen> createState() => _UsageHistoryScreenState();
}

class _UsageHistoryScreenState extends State<UsageHistoryScreen> {
  WaterCategory? _selectedCategory;
  String _searchQuery = '';
  int _selectedPeriodIndex = 0; // 0: 7 Days, 1: Month

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context);

    // Filter records
    final filteredRecords = provider.usageRecords.where((rec) {
      if (_selectedCategory != null && rec.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final catMatch = rec.category.displayName.toLowerCase().contains(q);
        final noteMatch = rec.note.toLowerCase().contains(q);
        if (!catMatch && !noteMatch) return false;
      }
      return true;
    }).toList();

    final totalFilteredVolume = filteredRecords.fold<double>(
      0.0,
      (sum, r) => sum + r.volumeLiters,
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Toggle & Metrics Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 10,
                      children: [
                        Text(
                          'Consumption History',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 0, label: Text('7 Days')),
                            ButtonSegment(value: 1, label: Text('Records')),
                          ],
                          selected: {_selectedPeriodIndex},
                          onSelectionChanged: (set) {
                            setState(() {
                              _selectedPeriodIndex = set.first;
                            });
                          },
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryColumn(
                          theme,
                          title: 'Filtered Total',
                          value: '${totalFilteredVolume.toStringAsFixed(1)} L',
                          color: theme.colorScheme.primary,
                        ),
                        Container(height: 30, width: 1, color: theme.dividerColor.withOpacity(0.3)),
                        _buildSummaryColumn(
                          theme,
                          title: 'Total Logs',
                          value: '${filteredRecords.length}',
                          color: Colors.teal,
                        ),
                        Container(height: 30, width: 1, color: theme.dividerColor.withOpacity(0.3)),
                        _buildSummaryColumn(
                          theme,
                          title: 'Est. Total Cost',
                          value: '\$${(totalFilteredVolume * 0.0035).toStringAsFixed(2)}',
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Interactive fl_chart for past 7 days
            if (_selectedPeriodIndex == 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Breakdown (Liters)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      UsageChartWidget(
                        dailyData: provider.past7DaysUsage,
                        dailyGoal: provider.dailyGoalLiters,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Search & Category Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search notes or activity...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Categories'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ...WaterCategory.values.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat.displayName),
                        selected: isSel,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Records List
            if (filteredRecords.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.history_toggle_off, size: 48, color: theme.disabledColor),
                      const SizedBox(height: 12),
                      Text(
                        'No usage logs found for this filter.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRecords.length,
                itemBuilder: (ctx, index) {
                  final record = filteredRecords[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(record.category).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(record.category),
                          color: _getCategoryColor(record.category),
                        ),
                      ),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            record.category.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (record.isAnomaly) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'High Usage',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (record.note.isNotEmpty)
                            Text(
                              record.note,
                              style: theme.textTheme.bodySmall,
                            ),
                          Text(
                            DateFormat('E, MMM d • h:mm a').format(record.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${record.volumeLiters.toStringAsFixed(1)} L',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '\$${record.estimatedCost.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddUsageModal.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Usage'),
      ),
    );
  }

  Widget _buildSummaryColumn(
    ThemeData theme, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(WaterCategory cat) {
    switch (cat) {
      case WaterCategory.shower:
        return Icons.shower;
      case WaterCategory.kitchen:
        return Icons.soup_kitchen;
      case WaterCategory.garden:
        return Icons.grass;
      case WaterCategory.laundry:
        return Icons.local_laundry_service;
      case WaterCategory.toilet:
        return Icons.wc;
      case WaterCategory.other:
        return Icons.water_drop;
    }
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
