import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/water_usage_record.dart';
import '../providers/water_provider.dart';

class AddUsageModal extends StatefulWidget {
  const AddUsageModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddUsageModal(),
    );
  }

  @override
  State<AddUsageModal> createState() => _AddUsageModalState();
}

class _AddUsageModalState extends State<AddUsageModal> {
  final _formKey = GlobalKey<FormState>();
  WaterCategory _selectedCategory = WaterCategory.shower;
  double _volumeLiters = 25.0;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _volumeTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _volumeTextController.text = _volumeLiters.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _volumeTextController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: bottomInset + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Water Usage',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Category',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WaterCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    avatar: Icon(
                      _getCategoryIcon(cat),
                      size: 18,
                      color: isSelected ? Colors.white : theme.colorScheme.primary,
                    ),
                    label: Text(cat.displayName),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Volume (Liters)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      controller: _volumeTextController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                        suffixText: 'L',
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null && parsed >= 0.1 && parsed <= 500) {
                          setState(() {
                            _volumeLiters = parsed;
                          });
                        }
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        final p = double.tryParse(val);
                        if (p == null || p <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: _volumeLiters.clamp(1.0, 200.0),
                min: 1.0,
                max: 200.0,
                divisions: 199,
                label: '${_volumeLiters.toStringAsFixed(1)} L',
                activeColor: theme.colorScheme.primary,
                onChanged: (val) {
                  setState(() {
                    _volumeLiters = val;
                    _volumeTextController.text = val.toStringAsFixed(1);
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Notes (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'e.g., Quick 5-min shower, Car wash, Dishwashing',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add_task),
                  label: const Text('Save Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<WaterProvider>(context, listen: false);
      provider.addUsageRecord(
        volumeLiters: _volumeLiters,
        category: _selectedCategory,
        note: _noteController.text.trim(),
      );
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${_volumeLiters.toStringAsFixed(1)}L of ${_selectedCategory.displayName}!',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }
}
