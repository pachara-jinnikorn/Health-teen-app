import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge.dart';
import '../utils/constants.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Challenges', style: AppTextStyles.heading1),
                 // ✅ Hidden button - uncomment if you need to add more challenges
      // ElevatedButton.icon(
      //   onPressed: () => _showInitializeChallengesDialog(context),
      //   icon: const Icon(Icons.add, size: 18),
      //   label: const Text('Init DB'),
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: AppColors.primary,
      //     foregroundColor: Colors.white,
      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(20),
      //     ),
      //   ),
      // ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.text,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Discover'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveChallenges(),
                  _buildCompletedChallenges(),
                  _buildDiscoverChallenges(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChallenges() {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        if (provider.activeChallenges.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No active challenges',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join a challenge to get started!',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: provider.activeChallenges.length,
          itemBuilder: (context, index) {
            final userChallenge = provider.activeChallenges[index];
            final challenge = provider.getChallengeById(userChallenge.challengeId);
            
            if (challenge == null) return const SizedBox.shrink();

            return _buildActiveChallengeCard(
              context,
              challenge: challenge,
              userChallenge: userChallenge,
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedChallenges() {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        if (provider.completedChallenges.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed challenges yet',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete challenges to see them here!',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: provider.completedChallenges.length,
          itemBuilder: (context, index) {
            final userChallenge = provider.completedChallenges[index];
            final challenge = provider.getChallengeById(userChallenge.challengeId);
            
            if (challenge == null) return const SizedBox.shrink();

            return _buildCompletedCard(
              context,
              challenge: challenge,
              userChallenge: userChallenge,
            );
          },
        );
      },
    );
  }

  Widget _buildDiscoverChallenges() {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        if (provider.allChallenges.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: provider.allChallenges.length,
          itemBuilder: (context, index) {
            final challenge = provider.allChallenges[index];
            final hasJoined = provider.hasJoinedChallenge(challenge.id);
            
            return _buildDiscoverCard(
              context,
              challenge: challenge,
              hasJoined: hasJoined,
            );
          },
        );
      },
    );
  }

  Widget _buildActiveChallengeCard(
    BuildContext context, {
    required Challenge challenge,
    required UserChallenge userChallenge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(challenge.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(challenge.title, style: AppTextStyles.heading3),
                          Text(
                            challenge.description,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildDifficultyBadge(challenge.difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(userChallenge.progress * 100).toInt()}% Complete',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${userChallenge.daysLeft} days left',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: userChallenge.progress,
                  backgroundColor: AppColors.background,
                  color: AppColors.primary,
                  minHeight: 8,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.emoji_events, challenge.reward),
                  _buildInfoChip(Icons.schedule, challenge.duration),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _showUpdateProgressDialog(
                      context,
                      userChallenge,
                      challenge,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Update'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.error,
                    onPressed: () => _showLeaveDialog(
                      context,
                      userChallenge,
                      challenge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(
    BuildContext context, {
    required Challenge challenge,
    required UserChallenge userChallenge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title, style: AppTextStyles.heading3),
                    Text(
                      _getCompletedTimeAgo(userChallenge.completedDate!),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              _buildDifficultyBadge(challenge.difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(challenge.description, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${challenge.reward} earned',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCard(
    BuildContext context, {
    required Challenge challenge,
    required bool hasJoined,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(challenge.icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge.title, style: AppTextStyles.heading3),
                      Text(challenge.category, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
              _buildDifficultyBadge(challenge.difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(challenge.description, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          
          // Info Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(Icons.schedule, challenge.duration),
              _buildInfoChip(Icons.people, '${challenge.participants} joined'),
              _buildInfoChip(Icons.emoji_events, challenge.reward),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Join Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasJoined
                  ? null
                  : () async {
                      try {
                        await context.read<ChallengeProvider>().joinChallenge(challenge);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Joined "${challenge.title}" challenge! 🎉'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          // Switch to Active tab
                          _tabController.animateTo(0);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasJoined ? Colors.grey : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(hasJoined ? 'Already Joined' : 'Join Challenge'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Easy':
        color = AppColors.success;
        break;
      case 'Medium':
        color = AppColors.warning;
        break;
      case 'Hard':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getCompletedTimeAgo(DateTime completedDate) {
    final now = DateTime.now();
    final difference = now.difference(completedDate);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  void _showUpdateProgressDialog(
    BuildContext context,
    UserChallenge userChallenge,
    Challenge challenge,
  ) {
    final controller = TextEditingController(
      text: userChallenge.currentValue.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Progress: ${challenge.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current progress: ${userChallenge.currentValue}/${userChallenge.targetValue}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Days Completed',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text) ?? 0;
              await context.read<ChallengeProvider>().updateChallengeProgress(
                    userChallenge.id,
                    value,
                  );
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress updated! 🎯'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(
    BuildContext context,
    UserChallenge userChallenge,
    Challenge challenge,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Challenge?'),
        content: Text('Are you sure you want to leave "${challenge.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<ChallengeProvider>().leaveChallenge(
                    userChallenge.id,
                    challenge.id,
                  );
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Left challenge'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showInitializeChallengesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Initialize Challenges'),
        content: const Text(
          'This will create default challenges in Firebase. Only do this once!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Creating challenges...'),
                  duration: Duration(seconds: 2),
                ),
              );
              await context.read<ChallengeProvider>().initializeDefaultChallenges();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challenges created! 🎉'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}