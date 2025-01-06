import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth/providers/auth_provider.dart';
import '../core/config/route_config.dart';
import '../core/services/logger_service.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key}) : _logger = LoggerService('AppDrawer');
  final LoggerService _logger;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALD Control System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, RouteConfig.mainDashboardRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.precision_manufacturing),
            title: Text('Machines'),
            onTap: () {
              Navigator.pushNamed(context, RouteConfig.machineListRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.play_circle_outline),
            title: Text('Processes'),
            onTap: () {
              Navigator.pushNamed(context, RouteConfig.processListRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.science),
            title: Text('Experiments'),
            onTap: () {
              Navigator.pushNamed(context, RouteConfig.experimentListRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('Recipes'),
            onTap: () {
              Navigator.pushNamed(context, RouteConfig.recipeListRoute);
            },
          ),
          Divider(),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              _logger.d(
                'User Role: ${authProvider.userRole}, '
                'Is Admin: ${authProvider.isAdmin}, '
                'Is Super Admin: ${authProvider.isSuperAdmin}, '
                'Has Admin Privileges: ${authProvider.hasAdminPrivileges}',
              );

              if (authProvider.hasAdminPrivileges) {
                _logger.d('Showing User Management tile');
                return ListTile(
                  leading: Icon(Icons.people),
                  title: Text('User Management'),
                  onTap: () {
                    _logger.d('Navigating to User Management');
                    Navigator.pushNamed(context, RouteConfig.userManagementRoute);
                  },
                );
              }
              _logger.d('Hiding User Management tile');
              return SizedBox.shrink();
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, RouteConfig.settingsRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help'),
            onTap: () {
              Navigator.pushNamed(context, RouteConfig.helpRoute);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign Out'),
            onTap: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
            },
          ),
        ],
      ),
    );
  }
}
