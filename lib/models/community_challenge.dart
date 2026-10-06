enum ChallengeStatus {
  notJoined,
  joined,
  completed;

  String get label {
    switch (this) {
      case ChallengeStatus.notJoined:
        return 'Join Challenge';
      case ChallengeStatus.joined:
        return 'In Progress';
      case ChallengeStatus.completed:
        return 'Completed 🎉';
    }
  }
}

class LeaderboardEntry {
  final String rank;
  final String userName;
  final double litersSaved;
  final String badgeTitle;
  final String avatarUrl;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userName,
    required this.litersSaved,
    required this.badgeTitle,
    this.avatarUrl = '',
    this.isCurrentUser = false,
  });
}

class CommunityChallenge {
  final String id;
  final String title;
  final String description;
  final double targetSavingsLiters;
  double currentProgressLiters;
  final DateTime startDate;
  final DateTime endDate;
  int participantsCount;
  ChallengeStatus userStatus;
  final String badgeName;
  final String badgeIcon; // Icon key or image name
  final List<LeaderboardEntry> leaderboard;

  CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetSavingsLiters,
    required this.currentProgressLiters,
    required this.startDate,
    required this.endDate,
    required this.participantsCount,
    this.userStatus = ChallengeStatus.notJoined,
    required this.badgeName,
    required this.badgeIcon,
    required this.leaderboard,
  });

  double get progressPercentage {
    if (targetSavingsLiters <= 0) return 0.0;
    return (currentProgressLiters / targetSavingsLiters).clamp(0.0, 1.0);
  }

  int get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}
