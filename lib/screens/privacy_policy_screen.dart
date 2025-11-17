// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                      Colors.blue.shade50,
                      Colors.purple.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      size: 48,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Privacy Policy',
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
                'Introduction',
                'Health Teen ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              ),

              _buildSection(
                '1. Information We Collect',
                'We collect information that you provide directly to us:\n\n'
                '• Account Information: Name, email address, password\n'
                '• Health Data: Steps, sleep hours, calories, exercise minutes\n'
                '• Profile Information: Age, preferences, settings\n'
                '• User Content: Posts, comments, messages\n'
                '• Payment Information: Payment method details (processed securely)\n'
                '• Usage Data: App interactions, features used, time spent',
              ),

              _buildSection(
                '2. How We Use Your Information',
                'We use your information to:\n\n'
                '• Provide and maintain the App services\n'
                '• Personalize your experience\n'
                '• Generate health insights and recommendations\n'
                '• Process payments and subscriptions\n'
                '• Send notifications and updates\n'
                '• Improve our services and develop new features\n'
                '• Prevent fraud and ensure security\n'
                '• Comply with legal obligations',
              ),

              _buildSection(
                '3. Health Data Privacy',
                'Your health data is extremely important to us:\n\n'
                '• All health data is encrypted at rest and in transit\n'
                '• Health data is only visible to you by default\n'
                '• You control who can see your health information\n'
                '• We never sell your health data to third parties\n'
                '• AI coaching uses your data to provide personalized advice\n'
                '• You can delete your health data at any time',
              ),

              _buildSection(
                '4. Information Sharing',
                'We DO NOT sell your personal information. We may share your information only in these circumstances:\n\n'
                '• With Your Consent: When you choose to share with other users\n'
                '• Service Providers: Trusted partners who help us operate the App (hosting, analytics, payment processing)\n'
                '• Legal Requirements: When required by law or to protect rights and safety\n'
                '• Business Transfers: In case of merger, acquisition, or sale of assets',
              ),

              _buildSection(
                '5. Data Security',
                'We implement appropriate security measures:\n\n'
                '• SSL/TLS encryption for data transmission\n'
                '• Encrypted storage of sensitive data\n'
                '• Regular security audits\n'
                '• Access controls and authentication\n'
                '• Secure payment processing (PCI-DSS compliant)',
              ),

              _buildSection(
                '6. Your Privacy Rights',
                'You have the right to:\n\n'
                '• Access your personal information\n'
                '• Correct inaccurate data\n'
                '• Delete your account and data\n'
                '• Export your data\n'
                '• Opt-out of marketing communications\n'
                '• Control privacy settings\n'
                '• Withdraw consent at any time',
              ),

              _buildSection(
                '7. Children\'s Privacy',
                'Our App is designed for users aged 13 and above. We do not knowingly collect personal information from children under 13. If you are under 13, please do not use the App or provide any information.\n\n'
                'If we learn we have collected information from a child under 13, we will delete it immediately.',
              ),

              _buildSection(
                '8. Data Retention',
                'We retain your information for as long as your account is active or as needed to provide services. You may request deletion of your account and data at any time through the App settings.',
              ),

              _buildSection(
                '9. International Data Transfers',
                'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your information in accordance with this Privacy Policy.',
              ),

              _buildSection(
                '10. Cookies and Tracking',
                'We use cookies and similar technologies to:\n'
                '• Remember your preferences\n'
                '• Understand how you use the App\n'
                '• Improve performance and user experience\n\n'
                'You can control cookies through your device settings.',
              ),

              _buildSection(
                '11. Third-Party Services',
                'The App may contain links to third-party services. We are not responsible for their privacy practices. Please review their privacy policies before providing any information.',
              ),

              _buildSection(
                '12. Changes to Privacy Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the App and updating the "Last Updated" date.',
              ),

              _buildSection(
                '13. Contact Us',
                'If you have questions about this Privacy Policy or our data practices, please contact us:\n\n'
                'Email: privacy@healthteen.com\n'
                'Address: Bangkok, Thailand\n'
                'Phone: +66-2-123-4567\n\n'
                'Data Protection Officer: dpo@healthteen.com',
              ),

              const SizedBox(height: AppSpacing.xl),

              // Privacy Badge
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade50,
                      Colors.teal.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.verified_user, 
                      color: Colors.green.shade700, 
                      size: 40
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Your Privacy is Protected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'We use industry-standard encryption and security measures to protect your data.',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
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