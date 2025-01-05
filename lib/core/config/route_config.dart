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
import '../../features/settings/screens/settings_screen.dart';

class RouteConfig {
  // Auth routes
  static const String loginRoute = '/login';
  static const String registrationRoute = '/register';

  // Dashboard routes
  static const String mainDashboardRoute = '/dashboard';
  static const String adminDashboardRoute = '/admin';

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

  static Map<String, Widget Function(BuildContext)> routes = {
    loginRoute: (context) => const LoginScreen(),
    mainDashboardRoute: (context) => const MachineDashboard(),
    machineListRoute: (context) => const MachineListScreen(),
    machineCreateRoute: (context) => const MachineCreationScreen(),
    processListRoute: (context) => const ProcessListScreen(),
    experimentListRoute: (context) => const ExperimentListScreen(),
    recipeListRoute: (context) => const RecipeListScreen(),
    settingsRoute: (context) => const SettingsScreen(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case machineDetailsRoute:
        return MaterialPageRoute(
          builder: (_) => MachineDetailsScreen(
            machineId: settings.arguments as String,
          ),
        );
      case machineEditRoute:
        return MaterialPageRoute(
          builder: (_) => MachineEditScreen(
            machineId: settings.arguments as String,
          ),
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
