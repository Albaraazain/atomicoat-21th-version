import 'package:flutter/material.dart';
import '../../../core/config/theme_config.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildExpansionTile(
            'How do I start a new experiment?',
            'To start a new experiment, go to the Experiments tab and tap the "+" button. '
                'Follow the step-by-step guide to set up your experiment parameters.',
          ),
          _buildExpansionTile(
            'How do I monitor process status?',
            'You can monitor process status in real-time through the Process Monitoring screen. '
                'Access it from the Process tab and select the process you want to monitor.',
          ),
          _buildExpansionTile(
            'How do I manage machine settings?',
            'Machine settings can be configured through the Machines tab. '
                'Select a machine and use the settings icon to adjust its parameters.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Contact Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactTile(
            context,
            'Email Support',
            'support@atomicoat.com',
            Icons.email,
          ),
          _buildContactTile(
            context,
            'Phone Support',
            '+1 (555) 123-4567',
            Icons.phone,
          ),
          _buildContactTile(
            context,
            'Live Chat',
            'Start a conversation with our support team',
            Icons.chat,
          ),
          const SizedBox(height: 24),
          const Text(
            'Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildResourceTile(
            context,
            'User Manual',
            'Download the complete user manual',
            Icons.book,
          ),
          _buildResourceTile(
            context,
            'Video Tutorials',
            'Watch step-by-step guide videos',
            Icons.play_circle_outline,
          ),
          _buildResourceTile(
            context,
            'Knowledge Base',
            'Browse our extensive knowledge base',
            Icons.library_books,
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          // TODO: Implement contact actions
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $title...'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourceTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Implement resource actions
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $title...'),
            ),
          );
        },
      ),
    );
  }
}
