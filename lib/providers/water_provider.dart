import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/water_usage_record.dart';
import '../models/leak_alert.dart';
import '../models/conservation_tip.dart';
import '../models/community_challenge.dart';

class WaterProvider extends ChangeNotifier {
  // Settings & Budget
  double _dailyGoalLiters = 180.0;
  double get dailyGoalLiters => _dailyGoalLiters;

  double _householdBaselineLiters = 220.0;
  double get householdBaselineLiters => _householdBaselineLiters;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isSmartValveOpen = true;
  bool get isSmartValveOpen => _isSmartValveOpen;

  bool _isLiveSimulationRunning = false;
  bool get isLiveSimulationRunning => _isLiveSimulationRunning;

  Timer? _simulationTimer;

  // Usage Records
  final List<WaterUsageRecord> _usageRecords = [];
  List<WaterUsageRecord> get usageRecords => List.unmodifiable(_usageRecords);

  // Leak Alerts
  final List<LeakAlert> _leakAlerts = [];
  List<LeakAlert> get leakAlerts => List.unmodifiable(_leakAlerts);

  // Conservation Tips
  final List<ConservationTip> _tips = [];
  List<ConservationTip> get tips => List.unmodifiable(_tips);

  // Community Challenges
  final List<CommunityChallenge> _challenges = [];
  List<CommunityChallenge> get challenges => List.unmodifiable(_challenges);

  WaterProvider() {
    _initializeSeedData();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDailyGoal(double newGoal) {
    _dailyGoalLiters = newGoal;
    notifyListeners();
  }

  void toggleSmartValve() {
    _isSmartValveOpen = !_isSmartValveOpen;
    // If valve is closed, set active critical leaks status to valveClosed
    if (!_isSmartValveOpen) {
      for (var i = 0; i < _leakAlerts.length; i++) {
        if (_leakAlerts[i].status == LeakStatus.active ||
            _leakAlerts[i].status == LeakStatus.acknowledged) {
          _leakAlerts[i] = _leakAlerts[i].copyWith(status: LeakStatus.valveClosed);
        }
      }
    }
    notifyListeners();
  }

  // Calculated Metrics
  double get todayTotalLiters {
    final now = DateTime.now();
    return _usageRecords
        .where((r) =>
            r.timestamp.year == now.year &&
            r.timestamp.month == now.month &&
            r.timestamp.day == now.day)
        .fold(0.0, (sum, r) => sum + r.volumeLiters);
  }

  double get todaySavingsPercentage {
    if (_householdBaselineLiters <= 0) return 0;
    final saved = _householdBaselineLiters - todayTotalLiters;
    final pct = (saved / _householdBaselineLiters) * 100;
    return pct.clamp(-100.0, 100.0);
  }

  double get todayProgress {
    if (_dailyGoalLiters <= 0) return 0;
    return (todayTotalLiters / _dailyGoalLiters).clamp(0.0, 1.5);
  }

  int get activeAlertsCount {
    return _leakAlerts
        .where((a) =>
            a.status == LeakStatus.active ||
            a.status == LeakStatus.acknowledged)
        .length;
  }

  double get totalPledgedSavings {
    return _tips
        .where((t) => t.isPledged || t.isCompleted)
        .fold(0.0, (sum, t) => sum + t.savingsPerDayLiters);
  }

  // Category breakdown for today
  Map<WaterCategory, double> get todayCategoryBreakdown {
    final now = DateTime.now();
    final todayRecs = _usageRecords.where((r) =>
        r.timestamp.year == now.year &&
        r.timestamp.month == now.month &&
        r.timestamp.day == now.day);

    final map = <WaterCategory, double>{
      for (var cat in WaterCategory.values) cat: 0.0,
    };

    for (var r in todayRecs) {
      map[r.category] = (map[r.category] ?? 0) + r.volumeLiters;
    }
    return map;
  }

  // Daily usage history for past 7 days
  List<Map<String, dynamic>> get past7DaysUsage {
    final list = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final total = _usageRecords
          .where((r) =>
              r.timestamp.year == date.year &&
              r.timestamp.month == date.month &&
              r.timestamp.day == date.day)
          .fold(0.0, (sum, r) => sum + r.volumeLiters);

      final daysName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      list.add({
        'day': daysName[date.weekday - 1],
        'date': date,
        'liters': total,
        'isToday': i == 0,
      });
    }
    return list;
  }

  // Usage Record Operations
  void addUsageRecord({
    required double volumeLiters,
    required WaterCategory category,
    required String note,
    DateTime? timestamp,
  }) {
    final record = WaterUsageRecord(
      id: 'REC-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: timestamp ?? DateTime.now(),
      volumeLiters: volumeLiters,
      category: category,
      note: note,
      isAnomaly: volumeLiters > 70.0,
    );
    _usageRecords.insert(0, record);

    // Update challenge progress if user is in joined status
    for (var ch in _challenges) {
      if (ch.userStatus == ChallengeStatus.joined) {
        ch.currentProgressLiters += (volumeLiters * 0.1); // bonus progress for active tracking
        if (ch.currentProgressLiters >= ch.targetSavingsLiters) {
          ch.userStatus = ChallengeStatus.completed;
        }
      }
    }

    notifyListeners();
  }

  void deleteUsageRecord(String id) {
    _usageRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Leak Alert Operations
  void updateLeakStatus(String alertId, LeakStatus newStatus) {
    final index = _leakAlerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _leakAlerts[index] = _leakAlerts[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void triggerSimulatedLeak() {
    final sensors = [
      {'name': 'Master Bath Sink Pipe', 'id': 'SN-402', 'flow': 3.8},
      {'name': 'Garden Irrigation Valve', 'id': 'SN-809', 'flow': 8.5},
      {'name': 'Kitchen Dishwasher Line', 'id': 'SN-105', 'flow': 5.2},
    ];

    final pick = sensors[Random().nextInt(sensors.length)];

    final newAlert = LeakAlert(
      id: 'ALERT-${DateTime.now().millisecondsSinceEpoch}',
      sensorId: pick['id'] as String,
      location: pick['name'] as String,
      severity: (pick['flow'] as double) > 5.0 ? LeakSeverity.critical : LeakSeverity.warning,
      flowRateLPM: pick['flow'] as double,
      detectedAt: DateTime.now(),
      status: LeakStatus.active,
      mitigationSteps: [
        'Close nearest isolation valve immediately.',
        'Check sensor junction box for physical dampness.',
        'Turn off Smart Main Water Valve from WaterSave app if unattended.',
        'Contact certified plumber if pressure persists.',
      ],
      notes: 'Continuous abnormal flow detected for over 8 minutes.',
    );

    _leakAlerts.insert(0, newAlert);
    notifyListeners();
  }

  // Conservation Tips Operations
  void toggleTipPledge(String tipId) {
    final tip = _tips.firstWhere((t) => t.id == tipId);
    tip.isPledged = !tip.isPledged;
    notifyListeners();
  }

  void toggleTipCompleted(String tipId) {
    final tip = _tips.firstWhere((t) => t.id == tipId);
    tip.isCompleted = !tip.isCompleted;
    if (tip.isCompleted) {
      tip.isPledged = true;
    }
    notifyListeners();
  }

  // Community Challenges Operations
  void joinChallenge(String challengeId) {
    final ch = _challenges.firstWhere((c) => c.id == challengeId);
    if (ch.userStatus == ChallengeStatus.notJoined) {
      ch.userStatus = ChallengeStatus.joined;
      ch.participantsCount += 1;
      notifyListeners();
    }
  }

  void completeChallenge(String challengeId) {
    final ch = _challenges.firstWhere((c) => c.id == challengeId);
    ch.userStatus = ChallengeStatus.completed;
    ch.currentProgressLiters = ch.targetSavingsLiters;
    notifyListeners();
  }

  // Live Simulation mode
  void toggleLiveSimulation() {
    _isLiveSimulationRunning = !_isLiveSimulationRunning;
    if (_isLiveSimulationRunning) {
      _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!_isSmartValveOpen) return; // valve shut, no water flow
        // simulate a small trickle of usage
        final cats = WaterCategory.values;
        final randomCat = cats[Random().nextInt(cats.length)];
        final flowAmount = (Random().nextDouble() * 3.5 + 0.5);

        addUsageRecord(
          volumeLiters: double.parse(flowAmount.toStringAsFixed(1)),
          category: randomCat,
          note: 'Automated Smart Meter Stream',
        );
      });
    } else {
      _simulationTimer?.cancel();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  // Initialize realistic initial mock data
  void _initializeSeedData() {
    final now = DateTime.now();

    // Usage records seed
    _usageRecords.addAll([
      WaterUsageRecord(
        id: 'REC-1',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        volumeLiters: 42.0,
        category: WaterCategory.shower,
        note: 'Morning Eco-Shower (8 mins)',
      ),
      WaterUsageRecord(
        id: 'REC-2',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 10)),
        volumeLiters: 15.5,
        category: WaterCategory.kitchen,
        note: 'Breakfast dishes & cooking',
      ),
      WaterUsageRecord(
        id: 'REC-3',
        timestamp: now.subtract(const Duration(hours: 5, minutes: 45)),
        volumeLiters: 35.0,
        category: WaterCategory.laundry,
        note: 'Eco-cycle laundry load',
      ),
      WaterUsageRecord(
        id: 'REC-4',
        timestamp: now.subtract(const Duration(hours: 7)),
        volumeLiters: 12.0,
        category: WaterCategory.toilet,
        note: 'Dual flush usage',
      ),
      // Yesterday records
      WaterUsageRecord(
        id: 'REC-5',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        volumeLiters: 55.0,
        category: WaterCategory.shower,
        note: 'Evening shower',
      ),
      WaterUsageRecord(
        id: 'REC-6',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        volumeLiters: 28.0,
        category: WaterCategory.garden,
        note: 'Drip irrigation for vegetable patch',
      ),
      WaterUsageRecord(
        id: 'REC-7',
        timestamp: now.subtract(const Duration(days: 2, hours: 4)),
        volumeLiters: 48.0,
        category: WaterCategory.shower,
      ),
      WaterUsageRecord(
        id: 'REC-8',
        timestamp: now.subtract(const Duration(days: 3, hours: 3)),
        volumeLiters: 65.0,
        category: WaterCategory.laundry,
      ),
      WaterUsageRecord(
        id: 'REC-9',
        timestamp: now.subtract(const Duration(days: 4, hours: 6)),
        volumeLiters: 30.0,
        category: WaterCategory.kitchen,
      ),
      WaterUsageRecord(
        id: 'REC-10',
        timestamp: now.subtract(const Duration(days: 5, hours: 1)),
        volumeLiters: 40.0,
        category: WaterCategory.garden,
      ),
    ]);

    // Leak Alerts seed
    _leakAlerts.addAll([
      LeakAlert(
        id: 'ALERT-101',
        sensorId: 'SN-GARDEN-02',
        location: 'Garden Irrigation Main Joint',
        severity: LeakSeverity.critical,
        flowRateLPM: 6.4,
        detectedAt: now.subtract(const Duration(minutes: 42)),
        status: LeakStatus.active,
        mitigationSteps: [
          'Turn off Garden Line Isolation Valve in meter box.',
          'Inspect hose washer ring and coupler coupling.',
          'Replace worn rubber gasket before reopening line.',
        ],
        notes: 'High flow detected while garden timer was inactive.',
      ),
      LeakAlert(
        id: 'ALERT-102',
        sensorId: 'SN-BATH-01',
        location: 'Guest Bathroom Toilet Tank',
        severity: LeakSeverity.warning,
        flowRateLPM: 1.2,
        detectedAt: now.subtract(const Duration(hours: 14)),
        status: LeakStatus.acknowledged,
        mitigationSteps: [
          'Check flapper valve seating in toilet tank.',
          'Adjust fill valve float level pin.',
        ],
        notes: 'Slow continuous trickle detected overnight.',
      ),
    ]);

    // Conservation Tips seed
    _tips.addAll([
      ConservationTip(
        id: 'TIP-1',
        title: '5-Minute Power Shower Challenge',
        description:
            'Shortening your shower by just 3 minutes saves up to 35 Liters of fresh water every single day.',
        category: TipCategory.bathroom,
        savingsPerDayLiters: 35.0,
        impact: ImpactLevel.high,
        difficulty: 'Easy',
        isPledged: true,
        iconName: 'shower',
      ),
      ConservationTip(
        id: 'TIP-2',
        title: 'Fix Running Toilets Promptly',
        description:
            'A leaking toilet flapper can waste over 200 Liters of water daily without making a loud sound.',
        category: TipCategory.bathroom,
        savingsPerDayLiters: 150.0,
        impact: ImpactLevel.high,
        difficulty: 'Moderate',
        isCompleted: true,
        iconName: 'wc',
      ),
      ConservationTip(
        id: 'TIP-3',
        title: 'Full Load Dishwasher Operation',
        description:
            'Only run your dishwasher when completely full to save up to 25 Liters per load compared to hand washing.',
        category: TipCategory.kitchen,
        savingsPerDayLiters: 25.0,
        impact: ImpactLevel.medium,
        difficulty: 'Easy',
        isPledged: true,
        iconName: 'kitchen',
      ),
      ConservationTip(
        id: 'TIP-4',
        title: 'Mulch Garden Beds & Drip Irrigation',
        description:
            'Applying a 2-inch layer of organic mulch retains soil moisture and cuts garden watering needs in half.',
        category: TipCategory.garden,
        savingsPerDayLiters: 60.0,
        impact: ImpactLevel.high,
        difficulty: 'Moderate',
        isPledged: false,
        iconName: 'grass',
      ),
      ConservationTip(
        id: 'TIP-5',
        title: 'Turn Off Tap While Brushing Teeth',
        description:
            'Running water while brushing wastes 12 Liters a minute. Turn it off to save effortless gallons.',
        category: TipCategory.bathroom,
        savingsPerDayLiters: 24.0,
        impact: ImpactLevel.low,
        difficulty: 'Easy',
        isPledged: true,
        isCompleted: true,
        iconName: 'water_drop',
      ),
      ConservationTip(
        id: 'TIP-6',
        title: 'Collect Rainwater for Outdoor Plants',
        description:
            'Install a simple rain barrel under downspouts to harvest rainwater for flowers and car washing.',
        category: TipCategory.garden,
        savingsPerDayLiters: 80.0,
        impact: ImpactLevel.high,
        difficulty: 'Advanced',
        isPledged: false,
        iconName: 'umbrella',
      ),
    ]);

    // Community Challenges seed
    _challenges.addAll([
      CommunityChallenge(
        id: 'CH-1',
        title: 'Neighborhood 500L Aqua Saver',
        description:
            'Keep your 7-day total usage under 500 Liters to help our community reach the 1,000,000 Liters milestone!',
        targetSavingsLiters: 500.0,
        currentProgressLiters: 340.0,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        participantsCount: 1420,
        userStatus: ChallengeStatus.joined,
        badgeName: 'Aqua Hero 2026',
        badgeIcon: 'military_tech',
        leaderboard: [
          LeaderboardEntry(rank: '1', userName: 'Elena Rostova', litersSaved: 620.0, badgeTitle: 'Gold Saver'),
          LeaderboardEntry(rank: '2', userName: 'Marcus Vance', litersSaved: 580.0, badgeTitle: 'Gold Saver'),
          LeaderboardEntry(rank: '3', userName: 'You (WaterSave User)', litersSaved: 340.0, badgeTitle: 'Silver Saver', isCurrentUser: true),
          LeaderboardEntry(rank: '4', userName: 'Aisha Patel', litersSaved: 310.0, badgeTitle: 'Bronze Saver'),
          LeaderboardEntry(rank: '5', userName: 'David Kim', litersSaved: 290.0, badgeTitle: 'Bronze Saver'),
        ],
      ),
      CommunityChallenge(
        id: 'CH-2',
        title: 'Zero Leak Sentinel Week',
        description:
            'Verify all home pipe sensors and maintain zero leak alerts for 7 consecutive days.',
        targetSavingsLiters: 200.0,
        currentProgressLiters: 200.0,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 3)),
        participantsCount: 890,
        userStatus: ChallengeStatus.completed,
        badgeName: 'Leak Shield Master',
        badgeIcon: 'verified_user',
        leaderboard: [
          LeaderboardEntry(rank: '1', userName: 'You (WaterSave User)', litersSaved: 200.0, badgeTitle: 'Shield Champion', isCurrentUser: true),
          LeaderboardEntry(rank: '2', userName: 'Sophia Chen', litersSaved: 200.0, badgeTitle: 'Shield Champion'),
          LeaderboardEntry(rank: '3', userName: 'Liam O\'Connor', litersSaved: 190.0, badgeTitle: 'Defender'),
        ],
      ),
      CommunityChallenge(
        id: 'CH-3',
        title: 'Smart Lawn & Garden Sprint',
        description:
            'Switch garden irrigation to early morning drip cycles and save 150L this week.',
        targetSavingsLiters: 150.0,
        currentProgressLiters: 0.0,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        participantsCount: 650,
        userStatus: ChallengeStatus.notJoined,
        badgeName: 'Green Thumb Guardian',
        badgeIcon: 'eco',
        leaderboard: [
          LeaderboardEntry(rank: '1', userName: 'Carlos Mendez', litersSaved: 120.0, badgeTitle: 'Master Planter'),
          LeaderboardEntry(rank: '2', userName: 'Priya Sharma', litersSaved: 95.0, badgeTitle: 'Sprout Saver'),
        ],
      ),
    ]);
  }
}
