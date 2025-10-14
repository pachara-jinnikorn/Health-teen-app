import 'package:flutter/material.dart';
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
                  ElevatedButton.icon(
                    onPressed: () => _showCreateChallengeDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
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
    final activeChallenges = [
      {
        'title': '10,000 Steps Challenge',
        'description': 'Walk 10,000 steps every day for a week',
        'progress': 0.6,
        'daysLeft': 3,
        'participants': 1247,
        'difficulty': 'Medium',
        'reward': '50 points',
      },
      {
        'title': 'Hydration Hero',
        'description': 'Drink 8 glasses of water daily',
        'progress': 0.8,
        'daysLeft': 2,
        'participants': 892,
        'difficulty': 'Easy',
        'reward': '30 points',
      },
      {
        'title': 'Sleep Champion',
        'description': 'Get 8 hours of sleep for 7 days',
        'progress': 0.4,
        'daysLeft': 5,
        'participants': 654,
        'difficulty': 'Hard',
        'reward': '75 points',
      },
      {
        'title': 'Mindful Minutes',
        'description': 'Meditate for 10 minutes daily',
        'progress': 0.7,
        'daysLeft': 4,
        'participants': 523,
        'difficulty': 'Easy',
        'reward': '40 points',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: activeChallenges.length,
      itemBuilder: (context, index) {
        final challenge = activeChallenges[index];
        return _buildChallengeCard(
          title: challenge['title'] as String,
          description: challenge['description'] as String,
          progress: challenge['progress'] as double,
          daysLeft: challenge['daysLeft'] as int,
          participants: challenge['participants'] as int,
          difficulty: challenge['difficulty'] as String,
          reward: challenge['reward'] as String,
          isActive: true,
        );
      },
    );
  }

  Widget _buildCompletedChallenges() {
    final completedChallenges = [
      {
        'title': 'Morning Workout Week',
        'description': 'Complete 7 morning workouts',
        'completedDate': '2 weeks ago',
        'reward': '100 points earned',
        'difficulty': 'Hard',
      },
      {
        'title': 'Healthy Eating Streak',
        'description': '5 days of balanced meals',
        'completedDate': '1 month ago',
        'reward': '60 points earned',
        'difficulty': 'Medium',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: completedChallenges.length,
      itemBuilder: (context, index) {
        final challenge = completedChallenges[index];
        return _buildCompletedCard(
          title: challenge['title'] as String,
          description: challenge['description'] as String,
          completedDate: challenge['completedDate'] as String,
          reward: challenge['reward'] as String,
          difficulty: challenge['difficulty'] as String,
        );
      },
    );
  }

  Widget _buildDiscoverChallenges() {
    final discoverChallenges = [
      {
        'title': 'Yoga Journey',
        'description': 'Practice yoga for 30 minutes, 5 days a week',
        'duration': '2 weeks',
        'participants': 2341,
        'difficulty': 'Medium',
        'reward': '120 points',
      },
      {
        'title': 'Fruit & Veggie Power',
        'description': 'Eat 5 servings of fruits and vegetables daily',
        'duration': '1 week',
        'participants': 1876,
        'difficulty': 'Easy',
        'reward': '50 points',
      },
      {
        'title': 'No Sugar Week',
        'description': 'Avoid added sugars for 7 days',
        'duration': '1 week',
        'participants': 987,
        'difficulty': 'Hard',
        'reward': '150 points',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: discoverChallenges.length,
      itemBuilder: (context, index) {
        final challenge = discoverChallenges[index];
        return _buildDiscoverCard(
          title: challenge['title'] as String,
          description: challenge['description'] as String,
          duration: challenge['duration'] as String,
          participants: challenge['participants'] as int,
          difficulty: challenge['difficulty'] as String,
          reward: challenge['reward'] as String,
        );
      },
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required String description,
    required double progress,
    required int daysLeft,
    required int participants,
    required String difficulty,
    required String reward,
    required bool isActive,
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
                child: Text(title, style: AppTextStyles.heading3),
              ),
              _buildDifficultyBadge(difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$daysLeft days left',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.background,
                  color: AppColors.primary,
                  minHeight: 8,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Info Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(Icons.people, '$participants participants'),
              _buildInfoChip(Icons.emoji_events, reward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard({
    required String title,
    required String description,
    required String completedDate,
    required String reward,
    required String difficulty,
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
                child: Icon(Icons.check_circle, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading3),
                    Text(completedDate, style: AppTextStyles.caption),
                  ],
                ),
              ),
              _buildDifficultyBadge(difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              reward,
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCard({
    required String title,
    required String description,
    required String duration,
    required int participants,
    required String difficulty,
    required String reward,
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
                child: Text(title, style: AppTextStyles.heading3),
              ),
              _buildDifficultyBadge(difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          
          // Info Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(Icons.schedule, duration),
              _buildInfoChip(Icons.people, '$participants joined'),
              _buildInfoChip(Icons.emoji_events, reward),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Join Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Joined "$title" challenge! 🎉'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Join Challenge'),
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
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Challenge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Challenge Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Challenge created successfully! 🎉'),
                  backgroundColor: AppColors.success,
                ),
              );
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