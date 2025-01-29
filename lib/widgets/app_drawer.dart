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
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary,
                      0.1) ??
                  theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        onTap: () => Navigator.pushReplacementNamed(
                            context, RouteConfig.mainDashboardRoute),
                      ),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          if (authProvider.isSuperAdmin) {
                            return _buildDrawerItem(
                              context: context,
                              icon: Icons.precision_manufacturing,
                              title: 'Machines',
                              onTap: () => Navigator.pushNamed(
                                  context, RouteConfig.machineListRoute),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.play_circle_outline,
                        title: 'Processes',
                        onTap: () => Navigator.pushNamed(
                            context, RouteConfig.processListRoute),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.science,
                        title: 'Experiments',
                        onTap: () => Navigator.pushNamed(
                            context, RouteConfig.experimentListRoute),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.receipt_long,
                        title: 'Recipes',
                        onTap: () => Navigator.pushNamed(
                            context, RouteConfig.recipeListRoute),
                      ),
                      _buildDivider(context),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          if (authProvider.hasAdminPrivileges) {
                            return _buildDrawerItem(
                              context: context,
                              icon: Icons.people,
                              title: 'User Management',
                              onTap: () => Navigator.pushNamed(
                                  context, RouteConfig.userManagementRoute),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () => Navigator.pushNamed(
                            context, RouteConfig.settingsRoute),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.help_outline,
                        title: 'Help',
                        onTap: () =>
                            Navigator.pushNamed(context, RouteConfig.helpRoute),
                      ),
                      _buildDivider(context),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.logout,
                        title: 'Sign Out',
                        onTap: () async {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.signOut();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 48, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            Color.lerp(theme.colorScheme.primary, theme.colorScheme.secondary,
                    0.6) ??
                theme.colorScheme.primary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.precision_manufacturing_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'ALD Control System',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Divider(
        color: Theme.of(context).dividerColor.withOpacity(0.1),
        thickness: 1,
      ),
    );
  }
}
