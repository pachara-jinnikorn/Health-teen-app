import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HealthCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final VoidCallback onView;
  final VoidCallback onAdd;

  const HealthCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.onView,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onView,
                    child: const Text('View'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                    onPressed: onAdd,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.heading1),
          Text(unit, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
