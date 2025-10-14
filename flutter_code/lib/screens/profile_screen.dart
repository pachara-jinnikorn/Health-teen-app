import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Profile', style: AppTextStyles.heading1),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Profile Picture
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 48)),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              const Text('Ethan Carter', style: AppTextStyles.heading2),
              const Text('Free Member', style: AppTextStyles.bodySmall),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Dashboard Stats
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dashboard', style: AppTextStyles.heading3),
                    const SizedBox(height: AppSpacing.md),
                    Consumer<HealthDataProvider>(
                      builder: (context, provider, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Sleep', '${provider.healthData.sleep}h'),
                            _buildStatItem('Calories', '${provider.healthData.calories}'),
                            _buildStatItem('Steps', '${provider.healthData.steps}'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Settings Options
              _buildSettingItem(Icons.lock_outline, 'Password'),
              _buildSettingItem(Icons.privacy_tip_outlined, 'Privacy'),
              _buildSettingItem(Icons.notifications_outlined, 'Notifications'),
              _buildSettingItem(Icons.emoji_events_outlined, 'Challenge'),
              _buildSettingItem(Icons.people_outline, 'Community'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.heading2),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: AppTextStyles.body),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
