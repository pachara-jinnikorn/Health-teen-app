// lib/screens/terms_screen.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Terms of Service',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Last Updated: November 17, 2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Introduction
              _buildSection(
                '1. Acceptance of Terms',
                'By accessing and using Health Teen ("the App"), you accept and agree to be bound by the terms and conditions of this agreement. If you do not agree to these terms, please do not use the App.',
              ),

              _buildSection(
                '2. Description of Service',
                'Health Teen is a health tracking and wellness platform designed for teenagers. The App provides features including:\n\n'
                '• Health data tracking (steps, sleep, calories)\n'
                '• AI-powered health coaching\n'
                '• Community features and social interaction\n'
                '• Challenge participation\n'
                '• Premium subscription services',
              ),

              _buildSection(
                '3. User Eligibility',
                'You must be at least 13 years old to use this App. If you are under 18, you must have permission from a parent or guardian. By using the App, you represent that you meet these age requirements.',
              ),

              _buildSection(
                '4. User Account',
                'You are responsible for:\n'
                '• Maintaining the confidentiality of your account credentials\n'
                '• All activities that occur under your account\n'
                '• Notifying us immediately of any unauthorized access\n'
                '• Providing accurate and complete information',
              ),

              _buildSection(
                '5. Health Information Disclaimer',
                'The App provides general health and wellness information for educational purposes only. It is NOT a substitute for professional medical advice, diagnosis, or treatment.\n\n'
                'Always seek the advice of your physician or qualified health provider with any questions about a medical condition. Never disregard professional medical advice or delay seeking it because of something you read in this App.',
              ),

              _buildSection(
                '6. User Content and Conduct',
                'You agree NOT to:\n'
                '• Post harmful, offensive, or inappropriate content\n'
                '• Harass, bully, or threaten other users\n'
                '• Share false or misleading health information\n'
                '• Violate any applicable laws or regulations\n'
                '• Attempt to hack or compromise the App security',
              ),

              _buildSection(
                '7. Premium Subscription',
                'Premium features require a paid subscription:\n'
                '• Subscriptions auto-renew unless cancelled\n'
                '• You may cancel anytime before the renewal date\n'
                '• Refunds are subject to our refund policy\n'
                '• Prices are subject to change with notice',
              ),

              _buildSection(
                '8. Intellectual Property',
                'All content, features, and functionality of the App are owned by Health Teen and protected by international copyright, trademark, and other intellectual property laws.',
              ),

              _buildSection(
                '9. Data Collection and Privacy',
                'We collect and use your data as described in our Privacy Policy. By using the App, you consent to our data practices.',
              ),

              _buildSection(
                '10. Termination',
                'We reserve the right to terminate or suspend your account at any time for violation of these Terms, without prior notice or liability.',
              ),

              _buildSection(
                '11. Limitation of Liability',
                'Health Teen shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the App.',
              ),

              _buildSection(
                '12. Changes to Terms',
                'We reserve the right to modify these Terms at any time. We will notify users of any material changes. Your continued use of the App after such modifications constitutes acceptance of the updated Terms.',
              ),

              _buildSection(
                '13. Contact Information',
                'For questions about these Terms, please contact us at:\n\n'
                'Email: legal@healthteen.com\n'
                'Address: Bangkok, Thailand\n'
                'Phone: +66-2-123-4567',
              ),

              const SizedBox(height: AppSpacing.xl),

              // Accept Button
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'By using Health Teen, you agree to these Terms of Service.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}