import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../utils/constants.dart';
import '../widgets/health_card.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
              const SizedBox(height: AppSpacing.lg),
              
              // Today's Health Section
              const Text("Today's Health", style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.md),
              
              Consumer<HealthDataProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      HealthCard(
                        icon: Icons.directions_walk,
                        label: 'Steps',
                        value: provider.healthData.steps.toString(),
                        unit: 'Daily steps',
                        onView: () => _showLogDialog(context, 'steps'),
                        onAdd: () => _showLogDialog(context, 'steps'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      HealthCard(
                        icon: Icons.bedtime,
                        label: 'Sleep',
                        value: '${provider.healthData.sleep}h',
                        unit: 'Sleep duration',
                        onView: () => _showLogDialog(context, 'sleep'),
                        onAdd: () => _showLogDialog(context, 'sleep'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      HealthCard(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: provider.healthData.calories.toString(),
                        unit: 'Calories burned',
                        onView: () => _showLogDialog(context, 'calories'),
                        onAdd: () => _showLogDialog(context, 'calories'),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // View Dashboard Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Dashboard', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
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
            labelText: type == 'sleep' ? 'Hours' : type == 'steps' ? 'Steps' : 'Calories',
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
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
