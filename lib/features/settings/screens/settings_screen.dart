import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/providers/auth_provider.dart';
import '../../../core/config/theme_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: ThemeConfig.teslaTheme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                subtitle: Text(authProvider.user?.email ?? 'Not signed in'),
                onTap: () {
                  // Profile settings navigation will be implemented
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security'),
                onTap: () {
                  // Security settings navigation will be implemented
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'App Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  // Notifications settings navigation will be implemented
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: const Text('English'),
                onTap: () {
                  // Language settings navigation will be implemented
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Support',
            children: [
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  // Help & Support navigation will be implemented
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  // About navigation will be implemented
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
