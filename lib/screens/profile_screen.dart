// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart';
import 'package:intl/intl.dart';

// Import new screens
import 'edit_profile_screen.dart';
import 'password_security_screen.dart';
import 'privacy_settings_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _toggleMembership(BuildContext context, bool isPremium) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'role': isPremium ? 'premium' : 'free',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPremium
                ? 'You are now a Premium Member 🎉'
                : 'Your subscription was cancelled 💨',
          ),
          backgroundColor: isPremium ? Colors.green : Colors.orange,
        ),
      );

      // ✅ Reload current page
      (context as Element).reassemble();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating membership: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Consumer<HealthDataProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Profile', style: AppTextStyles.heading1),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile shared! 📤'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Profile Card with Gradient - Show name from database
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String displayName = 'User';
                      String role = 'free';

                      if (snapshot.hasData && snapshot.data != null) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        if (data != null) {
                          final firstName = data['firstname'] ?? '';
                          final lastName = data['lastname'] ?? '';
                          role = data['role'] ?? 'free';

                          if (firstName.isNotEmpty && lastName.isNotEmpty) {
                            displayName = '$firstName $lastName';
                          } else if (firstName.isNotEmpty) {
                            displayName = firstName;
                          }
                        }
                      }

                      final isPremium = role == 'premium';

                      return Container(
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
                            // Profile Picture
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Center(
                                child:
                                    Text('👤', style: TextStyle(fontSize: 40)),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.md),

                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPremium
                                    ? Colors.amberAccent.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPremium ? 'Premium Member' : 'Free Member',
                                style: TextStyle(
                                  color: isPremium
                                      ? Colors.yellow.shade100
                                      : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isPremium)
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user?.uid)
                                    .collection('subscriptions')
                                    .orderBy('createdAt', descending: true)
                                    .limit(1)
                                    .snapshots(),
                                builder: (context, snap) {
                                  if (!snap.hasData ||
                                      snap.data!.docs.isEmpty) {
                                    return const SizedBox(height: 8);
                                  }

                                  final sub = snap.data!.docs.first.data()
                                      as Map<String, dynamic>;
                                  final endStr =
                                      (sub['endDate'] ?? '') as String;
                                  final status =
                                      (sub['status'] ?? 'active') as String;

                                  String formatted = endStr;
                                  try {
                                    if (endStr.isNotEmpty) {
                                      final dt =
                                          DateTime.parse('${endStr}T00:00:00');
                                      formatted =
                                          DateFormat('d MMM y').format(dt);
                                    }
                                  } catch (_) {}

                                  String daysLeftText = '';
                                  try {
                                    if (endStr.isNotEmpty) {
                                      final dt =
                                          DateTime.parse('${endStr}T00:00:00');
                                      final daysLeft =
                                          dt.difference(DateTime.now()).inDays;
                                      if (daysLeft >= 0) {
                                        daysLeftText =
                                            '  •  $daysLeft day${daysLeft == 1 ? '' : 's'} left';
                                      }
                                    }
                                  } catch (_) {}

                                  final isActive = status == 'active';

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isActive
                                              ? Icons.event_available
                                              : Icons.event_busy,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isActive
                                              ? 'Premium until $formatted$daysLeftText'
                                              : 'Premium cancelled (was until $formatted)',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: AppSpacing.lg),

                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  '${provider.currentStreak}',
                                  'Day Streak',
                                  Colors.white,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                _buildStatItem(
                                  '42',
                                  'Posts',
                                  Colors.white,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                _buildStatItem(
                                  '${provider.badges.length}',
                                  'Badges',
                                  Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Premium/Cancel Button
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      final role = snapshot.data!.get('role') ?? 'free';
                      final isPremium = role == 'premium';

                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (!isPremium) {
                              // Not premium → Go to payment screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const PaymentScreen()),
                              );
                              return;
                            }

                            // Already premium → Confirm cancellation
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Cancel Premium?'),
                                content: const Text(
                                  'Are you sure you want to cancel your premium membership?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('No'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await _toggleMembership(context, false);
                            }
                          },
                          icon: Icon(isPremium ? Icons.cancel : Icons.star,
                              color: Colors.white),
                          label: Text(
                            isPremium ? 'Cancel Premium' : 'Upgrade to Premium',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPremium
                                ? Colors.redAccent
                                : Colors.amber[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Health Overview Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health Overview',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildHealthProgress(
                          'Steps',
                          provider.healthData.steps,
                          10000,
                          Icons.directions_walk,
                          const Color(0xFF6366F1),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildHealthProgress(
                          'Sleep',
                          (provider.healthData.sleep * 100).toInt(),
                          800,
                          Icons.bedtime,
                          const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildHealthProgress(
                          'Calories',
                          provider.healthData.calories,
                          2000,
                          Icons.local_fire_department,
                          const Color(0xFFEC4899),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Achievement Badges
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Achievement Badges',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: provider.badges.length,
                          itemBuilder: (context, index) {
                            final badge = provider.badges[index];
                            return Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: badge.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: badge.color.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    badge.icon,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    badge.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    badge.description,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Settings Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Settings',
                      style: AppTextStyles.heading2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildSettingItem(
                    Icons.person_outline,
                    'Edit Profile',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  _buildSettingItem(
                    Icons.lock_outline,
                    'Password & Security',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PasswordSecurityScreen()),
                      );
                    },
                  ),
                  _buildSettingItem(
                    Icons.privacy_tip_outlined,
                    'Privacy Settings',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacySettingsScreen()),
                      );
                    },
                  ),
                  _buildSettingItem(
                    Icons.help_outline,
                    'Help & Support',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen()),
                      );
                    },
                  ),
                  _buildSettingItem(
                    Icons.info_outline,
                    'About',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // App Version
                  const Text(
                    'Version 1.0.0',
                    style: AppTextStyles.caption,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthProgress(
    String label,
    int current,
    int goal,
    IconData icon,
    Color color,
  ) {
    final progress = (current / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$current / $goal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.background,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(label, style: AppTextStyles.body),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?\nYou will need to sign in again.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully 👋'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}