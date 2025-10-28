import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/health_data_provider.dart';
import '../utils/constants.dart';
import '../widgets/health_card.dart';
import 'dashboard_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Consumer<HealthDataProvider>(
        builder: (context, provider, _) {
          final data = provider.healthData;
          final steps = data.steps; // ✅ steps จาก Firestore หรือคำนวณ
          final sleep = data.sleep;
          final calories = data.calories;

          // goal progress
          final stepsProgress = (steps / 10000).clamp(0.0, 1.0);
          final sleepProgress = (sleep / 8).clamp(0.0, 1.0);
          final caloriesProgress = (calories / 2000).clamp(0.0, 1.0);
          final overallProgress =
              (stepsProgress + sleepProgress + caloriesProgress) / 3;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + kBottomNavigationBarHeight + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Header =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Health Teen', style: AppTextStyles.heading1),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // ===== Greeting =====
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String displayName = 'User';
                    if (snapshot.hasData && snapshot.data != null) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null && data['firstname'] != null) {
                        displayName = data['firstname'];
                      }
                    }
                    final hour = DateTime.now().hour;
                    final greeting = hour < 12
                        ? 'Good Morning'
                        : hour < 17
                            ? 'Good Afternoon'
                            : 'Good Evening';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$greeting, $displayName! 👋',
                            style: AppTextStyles.heading2),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          "You're doing great today!",
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===== Daily Goal Progress Card =====
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daily Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(overallProgress * 100).toInt()}% Complete',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          // Streak Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(
                                  '${provider.currentStreak} Days',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Progress Circles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCircularProgress(
                            'Steps',
                            stepsProgress,
                            '$steps',
                            '10k',
                            Colors.white,
                          ),
                          _buildCircularProgress(
                            'Sleep',
                            sleepProgress,
                            '${_fmtDouble(sleep)}h',
                            '8h',
                            Colors.white,
                          ),
                          _buildCircularProgress(
                            'Calories',
                            caloriesProgress,
                            '$calories',
                            '2k',
                            Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===== Quick Actions =====
                const Text("Quick Actions", style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        icon: Icons.directions_walk,
                        label: 'Log Steps',
                        color: const Color(0xFF6366F1),
                        onTap: () => _showLogDialog(context, 'steps'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        icon: Icons.bedtime,
                        label: 'Log Sleep',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => _showLogDialog(context, 'sleep'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        icon: Icons.restaurant,
                        label: 'Log Meal',
                        color: const Color(0xFFEC4899),
                        onTap: () => _showLogDialog(context, 'calories'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===== Today's Health =====
                const Text("Today's Health", style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.md),

                HealthCard(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: '$steps',
                  unit: 'Daily steps',
                  onView: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                  onAdd: () => _showLogDialog(context, 'steps'),
                ),
                const SizedBox(height: AppSpacing.md),
                HealthCard(
                  icon: Icons.bedtime,
                  label: 'Sleep',
                  value: '${_fmtDouble(sleep)}h',
                  unit: 'Sleep duration',
                  onView: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                  onAdd: () => _showLogDialog(context, 'sleep'),
                ),
                const SizedBox(height: AppSpacing.md),
                HealthCard(
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: '$calories',
                  unit: 'Calories burned',
                  onView: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                  onAdd: () => _showLogDialog(context, 'calories'),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===== View Dashboard Button =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DashboardScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Dashboard',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== Helper Widgets =====
  Widget _buildCircularProgress(
    String label,
    double progress,
    String value,
    String goal,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text('/$goal',
                    style:
                        TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showLogDialog(BuildContext context, String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log ${type[0].toUpperCase()}${type.substring(1)}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: type == 'sleep'
                ? 'Hours'
                : type == 'steps'
                    ? 'Steps'
                    : 'Calories',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text;
              if (value.isNotEmpty) {
                final provider = context.read<HealthDataProvider>();
                if (type == 'steps') {
                  provider.updateSteps(int.parse(value));
                } else if (type == 'sleep') {
                  provider.updateSleep(double.parse(value));
                } else if (type == 'calories') {
                  provider.updateCalories(int.parse(value));
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$type logged successfully! 🎉'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static String _fmtDouble(double v) =>
      v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
}
