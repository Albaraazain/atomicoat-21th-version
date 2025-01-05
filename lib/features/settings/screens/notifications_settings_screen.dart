import 'package:flutter/material.dart';
import '../../../core/config/theme_config.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _experimentNotifications = true;
  bool _processNotifications = true;
  bool _machineNotifications = true;
  bool _maintenanceAlerts = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: ThemeConfig.teslaTheme.primaryColor,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notification Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Experiment Updates'),
            subtitle:
                const Text('Get notified about experiment status changes'),
            value: _experimentNotifications,
            onChanged: (bool value) {
              setState(() {
                _experimentNotifications = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Process Alerts'),
            subtitle:
                const Text('Receive alerts about process status and completion'),
            value: _processNotifications,
            onChanged: (bool value) {
              setState(() {
                _processNotifications = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Machine Status'),
            subtitle: const Text('Get updates about machine status changes'),
            value: _machineNotifications,
            onChanged: (bool value) {
              setState(() {
                _machineNotifications = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Maintenance Alerts'),
            subtitle:
                const Text('Receive notifications about required maintenance'),
            value: _maintenanceAlerts,
            onChanged: (bool value) {
              setState(() {
                _maintenanceAlerts = value;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notification Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: _emailNotifications,
            onChanged: (bool value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications on this device'),
            value: _pushNotifications,
            onChanged: (bool value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Quiet Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Set Quiet Hours'),
            subtitle: const Text('No notifications during specified hours'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Implement quiet hours settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quiet hours settings coming soon'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}