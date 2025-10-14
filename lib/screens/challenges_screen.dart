import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Challenges', style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.lg),
              
              Expanded(
                child: ListView(
                  children: [
                    _buildChallengeCard(
                      title: '10,000 Steps Challenge',
                      description: 'Walk 10,000 steps every day for a week',
                      progress: 0.6,
                      daysLeft: 3,
                    ),
                    _buildChallengeCard(
                      title: 'Hydration Hero',
                      description: 'Drink 8 glasses of water daily',
                      progress: 0.8,
                      daysLeft: 2,
                    ),
                    _buildChallengeCard(
                      title: 'Sleep Champion',
                      description: 'Get 8 hours of sleep for 7 days',
                      progress: 0.4,
                      daysLeft: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required String description,
    required double progress,
    required int daysLeft,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.background,
            color: AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$daysLeft days left',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
