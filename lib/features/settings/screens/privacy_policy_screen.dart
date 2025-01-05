import 'package:flutter/material.dart';
import '../../../core/config/theme_config.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: ThemeConfig.teslaTheme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Last Updated: January 1, 2024',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          Text(
            '1. Information We Collect',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We collect information that you provide directly to us, including but not limited to your name, email address, and any other information you choose to provide. We also automatically collect certain information about your device when you use our services.',
          ),
          SizedBox(height: 16),
          Text(
            '2. How We Use Your Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We use the information we collect to provide, maintain, and improve our services, to develop new services, and to protect AtomiCoat and our users. We also use this information to communicate with you.',
          ),
          SizedBox(height: 16),
          Text(
            '3. Information Sharing and Disclosure',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We do not share your personal information with companies, organizations, or individuals outside of AtomiCoat except in the following cases: with your consent, for legal reasons, or to protect rights, property, or safety.',
          ),
          SizedBox(height: 16),
          Text(
            '4. Data Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We work hard to protect AtomiCoat and our users from unauthorized access to or unauthorized alteration, disclosure, or destruction of information we hold.',
          ),
          SizedBox(height: 16),
          Text(
            '5. Data Retention',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We retain your personal information for as long as necessary to fulfill the purposes we collected it for, including for the purposes of satisfying any legal, accounting, or reporting requirements.',
          ),
          SizedBox(height: 16),
          Text(
            '6. Your Rights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You have the right to access, update, or delete your information and to object to or restrict certain processing of your information. You may also have the right to data portability.',
          ),
          SizedBox(height: 16),
          Text(
            '7. Changes to This Policy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We may change this privacy policy from time to time. We will post any privacy policy changes on this page and, if the changes are significant, we will provide a more prominent notice.',
          ),
          SizedBox(height: 16),
          Text(
            '8. Contact Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'If you have any questions about this privacy policy or our treatment of your personal data, please contact us at privacy@atomicoat.com.',
          ),
        ],
      ),
    );
  }
}