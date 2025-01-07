import 'package:atomicoat/features/recipes/screens/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import '../../features/machines/screens/machine_list_screen.dart';
import '../../features/machines/screens/machine_creation_screen.dart';
import '../../features/machines/screens/machine_details_screen.dart';
import '../../features/machines/screens/machine_edit_screen.dart';
import '../../features/dashboard/screens/machine_dashboard_screen.dart';
import '../../features/process/screens/process_list_screen.dart';
import '../../features/process/screens/process_details_screen.dart';
import '../../features/process/screens/process_monitoring_screen.dart';
import '../../features/experiments/screens/experiment_list_screen.dart';
import '../../features/experiments/screens/experiment_details_screen.dart';
import '../../features/recipes/screens/recipe_creation_screen.dart';
import '../../core/auth/screens/login_screen.dart';
import '../../core/auth/screens/account_deletion_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/help_support_screen.dart';
import '../../features/users/screens/user_management_screen.dart';
import 'package:provider/provider.dart';
import '../auth/providers/auth_provider.dart';

class RouteConfig {
  // Auth routes
  static const String loginRoute = '/login';
  static const String registrationRoute = '/register';

  // Dashboard routes
  static const String mainDashboardRoute = '/dashboard';
  static const String adminDashboardRoute = '/admin';

  // User management route
  static const String userManagementRoute = '/users/manage';

  // Machine routes
  static const String machineListRoute = '/machines';
  static const String machineCreateRoute = '/machines/create';
  static const String machineDetailsRoute = '/machines/details';
  static const String machineEditRoute = '/machines/edit';

  // Process routes
  static const String processListRoute = '/processes';
  static const String processDetailsRoute = '/processes/details';
  static const String processMonitoringRoute = '/processes/monitor';

  // Experiment routes
  static const String experimentListRoute = '/experiments';
  static const String experimentDetailsRoute = '/experiments/details';

  // Recipe routes
  static const String recipeListRoute = '/recipes';
  static const String recipeDetailsRoute = '/recipes/details';
  static const String recipeCreateRoute = '/recipes/create';

  // Settings route
  static const String settingsRoute = '/settings';

  // Help route
  static const String helpRoute = '/help';

  // Account management routes
  static const String accountDeletionRoute = '/account/delete';

  static Map<String, Widget Function(BuildContext)> routes = {
    loginRoute: (context) => const LoginScreen(),
    mainDashboardRoute: (context) => const MachineDashboard(),
    adminDashboardRoute: (context) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAdmin && !authProvider.isSuperAdmin) {
        return Scaffold(
          appBar: AppBar(title: const Text('Access Denied')),
          body: const Center(
            child: Text('You do not have permission to access this page'),
          ),
        );
      }
      return const MachineDashboard();
    },
    machineListRoute: (context) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isSuperAdmin) {
        return Scaffold(
          appBar: AppBar(title: const Text('Machines')),
          body: const Center(
            child: Text('Only Super Admins can access the machines management'),
          ),
        );
      }
      return const MachineListScreen();
    },
    machineCreateRoute: (context) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isSuperAdmin) {
        return Scaffold(
          appBar: AppBar(title: const Text('Create Machine')),
          body: const Center(
            child: Text('Only Super Admins can create machines'),
          ),
        );
      }
      return const MachineCreationScreen();
    },
    processListRoute: (context) => const ProcessListScreen(),
    experimentListRoute: (context) => const ExperimentListScreen(),
    recipeListRoute: (context) => const RecipeListScreen(),
    settingsRoute: (context) => const SettingsScreen(),
    helpRoute: (context) => const HelpSupportScreen(),
    userManagementRoute: (context) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.hasAdminPrivileges) {
        return Scaffold(
          appBar: AppBar(title: const Text('User Management')),
          body: const Center(
            child: Text('You do not have permission to access this page'),
          ),
        );
      }
      return const UserManagementScreen();
    },
    accountDeletionRoute: (context) => const AccountDeletionScreen(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case machineDetailsRoute:
        return MaterialPageRoute(
          builder: (context) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (!authProvider.isSuperAdmin) {
              return Scaffold(
                appBar: AppBar(title: const Text('Machine Details')),
                body: const Center(
                  child: Text('Only Super Admins can view machine details'),
                ),
              );
            }
            return MachineDetailsScreen(
              machineId: settings.arguments as String,
            );
          },
        );
      case machineEditRoute:
        return MaterialPageRoute(
          builder: (context) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (!authProvider.isSuperAdmin) {
              return Scaffold(
                appBar: AppBar(title: const Text('Edit Machine')),
                body: const Center(
                  child: Text('Only Super Admins can edit machines'),
                ),
              );
            }
            return MachineEditScreen(
              machineId: settings.arguments as String,
            );
          },
        );
      case processDetailsRoute:
        return MaterialPageRoute(
          builder: (_) => ProcessDetailsScreen(
            processId: settings.arguments as String,
          ),
        );
      case processMonitoringRoute:
        return MaterialPageRoute(
          builder: (_) => ProcessMonitoringScreen(
            processId: settings.arguments as String,
          ),
        );
      case experimentDetailsRoute:
        return MaterialPageRoute(
          builder: (_) => ExperimentDetailsScreen(
            experimentId: settings.arguments as String,
          ),
        );
      case recipeCreateRoute:
        return MaterialPageRoute(
          builder: (_) => RecipeCreationScreen(
            machineId: settings.arguments as String,
          ),
        );
      default:
        return null;
    }
  }
}
