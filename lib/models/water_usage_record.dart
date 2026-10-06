enum WaterCategory {
  shower,
  kitchen,
  garden,
  laundry,
  toilet,
  other;

  String get displayName {
    switch (this) {
      case WaterCategory.shower:
        return 'Shower & Bath';
      case WaterCategory.kitchen:
        return 'Kitchen & Dishes';
      case WaterCategory.garden:
        return 'Garden & Lawn';
      case WaterCategory.laundry:
        return 'Laundry';
      case WaterCategory.toilet:
        return 'Toilet Flush';
      case WaterCategory.other:
        return 'Other Usage';
    }
  }

  String get iconName {
    switch (this) {
      case WaterCategory.shower:
        return 'shower';
      case WaterCategory.kitchen:
        return 'kitchen';
      case WaterCategory.garden:
        return 'grass';
      case WaterCategory.laundry:
        return 'local_laundry_service';
      case WaterCategory.toilet:
        return 'wc';
      case WaterCategory.other:
        return 'water_drop';
    }
  }
}

class WaterUsageRecord {
  final String id;
  final DateTime timestamp;
  final double volumeLiters;
  final WaterCategory category;
  final String note;
  final bool isAnomaly;
  final double estimatedCost;

  WaterUsageRecord({
    required this.id,
    required this.timestamp,
    required this.volumeLiters,
    required this.category,
    this.note = '',
    this.isAnomaly = false,
    double? estimatedCost,
  }) : estimatedCost = estimatedCost ?? (volumeLiters * 0.0035); // Approx cost per liter
}
