enum LeakSeverity {
  critical,
  warning,
  info;

  String get label {
    switch (this) {
      case LeakSeverity.critical:
        return 'CRITICAL LEAK';
      case LeakSeverity.warning:
        return 'ABNORMAL FLOW';
      case LeakSeverity.info:
        return 'MINOR DRIP';
    }
  }
}

enum LeakStatus {
  active,
  acknowledged,
  valveClosed,
  resolved,
  falseAlarm;

  String get label {
    switch (this) {
      case LeakStatus.active:
        return 'ACTIVE LEAK';
      case LeakStatus.acknowledged:
        return 'ACKNOWLEDGED';
      case LeakStatus.valveClosed:
        return 'VALVE SHUT OFF';
      case LeakStatus.resolved:
        return 'RESOLVED';
      case LeakStatus.falseAlarm:
        return 'FALSE ALARM';
    }
  }
}

class LeakAlert {
  final String id;
  final String sensorId;
  final String location;
  final LeakSeverity severity;
  final double flowRateLPM; // Liters per minute
  final DateTime detectedAt;
  LeakStatus status;
  final List<String> mitigationSteps;
  final String notes;

  LeakAlert({
    required this.id,
    required this.sensorId,
    required this.location,
    required this.severity,
    required this.flowRateLPM,
    required this.detectedAt,
    this.status = LeakStatus.active,
    required this.mitigationSteps,
    this.notes = '',
  });

  LeakAlert copyWith({
    LeakStatus? status,
  }) {
    return LeakAlert(
      id: id,
      sensorId: sensorId,
      location: location,
      severity: severity,
      flowRateLPM: flowRateLPM,
      detectedAt: detectedAt,
      status: status ?? this.status,
      mitigationSteps: mitigationSteps,
      notes: notes,
    );
  }
}
