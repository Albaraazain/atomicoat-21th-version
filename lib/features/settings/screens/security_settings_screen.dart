import 'package:flutter/material.dart';
import '../../../core/config/theme_config.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactorEnabled = false;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: ThemeConfig.teslaTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement password change
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated successfully')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.teslaTheme.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Update Password'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Two-Factor Authentication',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Two-Factor Authentication'),
              subtitle: const Text(
                'Add an extra layer of security to your account',
              ),
              value: _twoFactorEnabled,
              onChanged: (bool value) {
                setState(() {
                  _twoFactorEnabled = value;
                });
                // TODO: Implement 2FA toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Two-factor authentication enabled'
                          : 'Two-factor authentication disabled',
                    ),
                  ),
                );
              },
            ),
            if (_twoFactorEnabled) ...[
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.phone_android),
                title: Text('Authenticator App'),
                subtitle: Text('Set up an authenticator app'),
              ),
              const ListTile(
                leading: Icon(Icons.message),
                title: Text('SMS Authentication'),
                subtitle: Text('Use SMS codes as backup'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}