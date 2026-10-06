enum TipCategory {
  bathroom,
  kitchen,
  garden,
  laundry,
  household;

  String get displayName {
    switch (this) {
      case TipCategory.bathroom:
        return 'Bathroom';
      case TipCategory.kitchen:
        return 'Kitchen';
      case TipCategory.garden:
        return 'Garden';
      case TipCategory.laundry:
        return 'Laundry';
      case TipCategory.household:
        return 'Household General';
    }
  }
}

enum ImpactLevel {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case ImpactLevel.high:
        return 'High Impact';
      case ImpactLevel.medium:
        return 'Medium Impact';
      case ImpactLevel.low:
        return 'Easy Wins';
    }
  }
}

class ConservationTip {
  final String id;
  final String title;
  final String description;
  final TipCategory category;
  final double savingsPerDayLiters;
  final ImpactLevel impact;
  final String difficulty; // Easy, Moderate, Advanced
  bool isPledged;
  bool isCompleted;
  final String iconName;

  ConservationTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.savingsPerDayLiters,
    required this.impact,
    required this.difficulty,
    this.isPledged = false,
    this.isCompleted = false,
    required this.iconName,
  });
}
