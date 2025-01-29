import 'package:flutter/material.dart';
import '../../../core/config/theme_config.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            'Terms of Service',
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
            '1. Acceptance of Terms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'By accessing and using the AtomiCoat application, you agree to be bound by these Terms of Service and all applicable laws and regulations.',
          ),
          SizedBox(height: 16),
          Text(
            '2. Use License',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Permission is granted to temporarily use the AtomiCoat application for personal, non-commercial transitory viewing only.',
          ),
          SizedBox(height: 16),
          Text(
            '3. Disclaimer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The materials on AtomiCoat\'s application are provided on an \'as is\' basis. AtomiCoat makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
          ),
          SizedBox(height: 16),
          Text(
            '4. Limitations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'In no event shall AtomiCoat or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on AtomiCoat\'s application.',
          ),
          SizedBox(height: 16),
          Text(
            '5. Accuracy of Materials',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The materials appearing in AtomiCoat\'s application could include technical, typographical, or photographic errors. AtomiCoat does not warrant that any of the materials on its application are accurate, complete, or current.',
          ),
          SizedBox(height: 16),
          Text(
            '6. Links',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AtomiCoat has not reviewed all of the sites linked to its application and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by AtomiCoat of the site.',
          ),
          SizedBox(height: 16),
          Text(
            '7. Modifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AtomiCoat may revise these terms of service for its application at any time without notice. By using this application you are agreeing to be bound by the then current version of these terms of service.',
          ),
        ],
      ),
    );
  }
}
