import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conservation_tip.dart';
import '../providers/water_provider.dart';
import '../widgets/tip_card_widget.dart';

class ConservationTipsScreen extends StatefulWidget {
  const ConservationTipsScreen({super.key});

  @override
  State<ConservationTipsScreen> createState() => _ConservationTipsScreenState();
}

class _ConservationTipsScreenState extends State<ConservationTipsScreen> {
  TipCategory? _selectedCategory;
  bool _showSavingsCalculator = false;

  // Calculator State Variables
  double _showerMins = 10.0;
  double _flushesPerDay = 5.0;
  double _gardenMins = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context);

    final filteredTips = provider.tips.where((t) {
      if (_selectedCategory != null && t.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    // Savings Calculation
    final showerPotential = (_showerMins - 5.0).clamp(0.0, 30.0) * 12.0; // 12L/min shower
    final flushPotential = _flushesPerDay * 6.0; // Dual flush savings
    final gardenPotential = (_gardenMins * 0.4) * 15.0; // Drip vs hose
    final totalCalcPotential = showerPotential + flushPotential + gardenPotential;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Pledged Savings Impact Banner
          Card(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Conservation Impact',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${provider.totalPledgedSavings.toInt()} Liters / Day',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Estimated annual saving: \$${(provider.totalPledgedSavings * 365 * 0.0035).toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Savings Calculator Accordion Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showSavingsCalculator = !_showSavingsCalculator;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calculate_outlined, color: Colors.teal),
                            const SizedBox(width: 10),
                            Text(
                              'Interactive Savings Calculator',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _showSavingsCalculator
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                  ),
                  if (_showSavingsCalculator) ...[
                    const Divider(height: 24),
                    Text(
                      'Adjust your habits below to estimate potential daily water savings:',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text('Average Shower Duration: ${_showerMins.toInt()} mins'),
                    Slider(
                      value: _showerMins,
                      min: 3,
                      max: 25,
                      divisions: 22,
                      label: '${_showerMins.toInt()} mins',
                      onChanged: (v) => setState(() => _showerMins = v),
                    ),
                    const SizedBox(height: 8),
                    Text('Toilet Flushes per Day: ${_flushesPerDay.toInt()} flushes'),
                    Slider(
                      value: _flushesPerDay,
                      min: 1,
                      max: 15,
                      divisions: 14,
                      label: '${_flushesPerDay.toInt()}',
                      onChanged: (v) => setState(() => _flushesPerDay = v),
                    ),
                    const SizedBox(height: 8),
                    Text('Garden Hose Watering: ${_gardenMins.toInt()} mins/day'),
                    Slider(
                      value: _gardenMins,
                      min: 0,
                      max: 60,
                      divisions: 12,
                      label: '${_gardenMins.toInt()} mins',
                      onChanged: (v) => setState(() => _gardenMins = v),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimated Potential Savings:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${totalCalcPotential.toInt()} L / day',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category Chips
          Text(
            'Explore Tips by Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Tips'),
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
                ...TipCategory.values.map((cat) {
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

          // Tips List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTips.length,
            itemBuilder: (ctx, index) {
              return TipCardWidget(tip: filteredTips[index]);
            },
          ),
        ],
      ),
    );
  }
}
