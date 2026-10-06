import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_challenge.dart';
import '../providers/water_provider.dart';
import '../widgets/challenge_card_widget.dart';

class CommunityChallengesScreen extends StatefulWidget {
  const CommunityChallengesScreen({super.key});

  @override
  State<CommunityChallengesScreen> createState() => _CommunityChallengesScreenState();
}

class _CommunityChallengesScreenState extends State<CommunityChallengesScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: My Challenges, 2: Completed

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WaterProvider>(context);

    final filteredChallenges = provider.challenges.where((c) {
      if (_selectedFilterIndex == 1) {
        return c.userStatus == ChallengeStatus.joined;
      }
      if (_selectedFilterIndex == 2) {
        return c.userStatus == ChallengeStatus.completed;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Community Impact Hero Banner
          Card(
            color: const Color(0xFF0284C7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.public, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'GLOBAL COMMUNITY IMPACT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.stars, color: Color(0xFFF59E0B), size: 24),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '1,240,500 Liters',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Saved collectively by 3,420 WaterSave neighborhood members this month!',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildCommunityStat(label: 'Active Challenges', value: '3'),
                      const SizedBox(width: 24),
                      _buildCommunityStat(label: 'Your Badges', value: '2'),
                      const SizedBox(width: 24),
                      _buildCommunityStat(label: 'Rank', value: '#3'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Badge Showcase Showcase
          Text(
            'Earned Conservation Badges',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBadgeTile(
                  theme,
                  title: 'Shield Master',
                  subtitle: 'Zero-Leak Week',
                  icon: Icons.verified_user,
                  color: const Color(0xFF10B981),
                  isUnlocked: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBadgeTile(
                  theme,
                  title: 'Aqua Saver',
                  subtitle: '500L Saved',
                  icon: Icons.military_tech,
                  color: const Color(0xFFF59E0B),
                  isUnlocked: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBadgeTile(
                  theme,
                  title: 'Green Thumb',
                  subtitle: 'Drip Irrigation',
                  icon: Icons.eco,
                  color: const Color(0xFF64748B),
                  isUnlocked: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Challenges Filter Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              Text(
                'Community Challenges',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('All')),
                  ButtonSegment(value: 1, label: Text('Joined')),
                  ButtonSegment(value: 2, label: Text('Completed')),
                ],
                selected: {_selectedFilterIndex},
                onSelectionChanged: (set) {
                  setState(() {
                    _selectedFilterIndex = set.first;
                  });
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Challenges List
          if (filteredChallenges.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No challenges match this filter.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredChallenges.length,
              itemBuilder: (ctx, index) {
                return ChallengeCardWidget(challenge: filteredChallenges[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommunityStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildBadgeTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isUnlocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? color.withOpacity(0.12) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? color.withOpacity(0.4) : theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isUnlocked ? color : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isUnlocked ? theme.textTheme.titleMedium?.color : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
