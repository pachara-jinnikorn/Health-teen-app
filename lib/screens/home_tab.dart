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
                const Text('Health Teen', style: AppTextStyles.heading1),
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
            onPressed: () async {
              final raw = controller.text.trim();
              if (raw.isEmpty) return;

              try {
                if (type == 'steps') {
                  final v = int.parse(raw);
                  await _upsertTodayLog(context, steps: v);
                } else if (type == 'sleep') {
                  final v = double.parse(raw);
                  await _upsertTodayLog(context, sleepHours: v);
                } else if (type == 'calories') {
                  final v = int.parse(raw);
                  await _upsertTodayLog(context, calories: v);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$type logged to database! ✅'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _upsertTodayLog(
    BuildContext context, {
    int? steps,
    double? sleepHours,
    int? calories,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    final logDate = DateTime.now().toIso8601String().split('T').first;
    final logsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('healthLogs');

    // หา log ของ "วันนี้"
    final existing =
        await logsRef.where('logDate', isEqualTo: logDate).limit(1).get();

    // เตรียมข้อมูลที่จะอัปเดตเฉพาะฟิลด์ที่ผู้ใช้กรอก
    final Map<String, dynamic> updates = {
      if (steps != null) 'steps': steps,
      if (sleepHours != null)
        'sleepHours': sleepHours.round(), // เก็บเป็น int ให้ตรง schema
      if (calories != null) 'calories': calories,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (existing.docs.isNotEmpty) {
      // อัปเดตเอกสารเดิมของวันนี้
      await existing.docs.first.reference.update(updates);
    } else {
      // สร้างเอกสารใหม่ของวันนี้ (เติมค่า default ให้ครบ เพื่อหลีกเลี่ยง rule/การอ่านภายหลัง)
      await logsRef.add({
        'calories': calories ?? 0,
        'exerciseMinutes': 0, // คงไว้ 0 ถ้าไม่ได้เก็บ
        'sleepHours': (sleepHours ?? 0).round(),
        'steps': steps ?? 0,
        'logDate': logDate,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'manual',
        ...updates,
      });
    }

    // อัปเดต Provider ให้ UI เปลี่ยนทันที (ไม่ต้องรออ่านรอบใหม่)
    final provider = context.read<HealthDataProvider>();
    if (steps != null) provider.updateSteps(steps);
    if (sleepHours != null) provider.updateSleep(sleepHours);
    if (calories != null) provider.updateCalories(calories);
  }

  static String _fmtDouble(double v) =>
      v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
}
