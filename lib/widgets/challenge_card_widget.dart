import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_challenge.dart';
import '../providers/water_provider.dart';

class ChallengeCardWidget extends StatelessWidget {
  final CommunityChallenge challenge;

  const ChallengeCardWidget({
    super.key,
    required this.challenge,
  });

  IconData _getBadgeIcon(String iconName) {
    switch (iconName) {
      case 'military_tech':
        return Icons.military_tech;
      case 'verified_user':
        return Icons.verified_user;
      case 'eco':
        return Icons.eco;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: challenge.userStatus == ChallengeStatus.completed
              ? const Color(0xFF10B981)
              : challenge.userStatus == ChallengeStatus.joined
                  ? theme.colorScheme.primary
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getBadgeIcon(challenge.badgeIcon),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              challenge.badgeName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${challenge.daysRemaining} days left',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              challenge.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target: ${challenge.targetSavingsLiters.toInt()} L Savings',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(challenge.progressPercentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: challenge.userStatus == ChallengeStatus.completed
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: challenge.progressPercentage,
                    minHeight: 10,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                    color: challenge.userStatus == ChallengeStatus.completed
                        ? const Color(0xFF10B981)
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.participantsCount} participants',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showLeaderboardDialog(context, challenge),
                      icon: const Icon(Icons.leaderboard, size: 16),
                      label: const Text('Leaderboard'),
                    ),
                    _buildActionButton(context, provider, challenge),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WaterProvider provider,
    CommunityChallenge challenge,
  ) {
    switch (challenge.userStatus) {
      case ChallengeStatus.notJoined:
        return ElevatedButton(
          onPressed: () {
            provider.joinChallenge(challenge.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Joined "${challenge.title}"!'),
                backgroundColor: const Color(0xFF0284C7),
              ),
            );
          },
          child: const Text('Join'),
        );
      case ChallengeStatus.joined:
        return OutlinedButton.icon(
          onPressed: () {
            provider.completeChallenge(challenge.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Congratulations! Completed "${challenge.title}"!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          },
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Complete'),
        );
      case ChallengeStatus.completed:
        return const Chip(
          avatar: Icon(Icons.verified, size: 16, color: Colors.white),
          label: Text('Completed'),
          backgroundColor: Color(0xFF10B981),
          labelStyle: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        );
    }
  }

  void _showLeaderboardDialog(BuildContext context, CommunityChallenge challenge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Leaderboard - ${challenge.title}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: challenge.leaderboard.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: entry.isCurrentUser
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: entry.isCurrentUser
                      ? Border.all(color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: entry.rank == '1'
                          ? const Color(0xFFF59E0B)
                          : entry.rank == '2'
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFFB45309),
                      child: Text(
                        '#${entry.rank}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.userName,
                            style: TextStyle(
                              fontWeight:
                                  entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            entry.badgeTitle,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${entry.litersSaved.toInt()} L',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
