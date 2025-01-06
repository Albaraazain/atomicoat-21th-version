import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/services/auth_service.dart';
import '../../features/components/providers/component_provider.dart';
import '../../features/process/providers/process_provider.dart';
import '../../features/experiments/providers/experiment_provider.dart';
import '../../features/recipes/providers/recipe_provider.dart';
import '../../features/machines/providers/machine_provider.dart';
import '../../features/machines/repositories/machine_repository.dart';
import '../../features/users/providers/user_provider.dart';
import '../../features/users/repositories/user_repository.dart';

class ProviderConfig {
  static final List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
    ChangeNotifierProvider(
      create: (_) => MachineProvider(
        MachineRepository(Supabase.instance.client),
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => UserProvider(UserRepository()),
    ),
    ChangeNotifierProvider(create: (_) => ComponentProvider()),
    ChangeNotifierProvider(create: (_) => ProcessProvider()),
    ChangeNotifierProvider(create: (_) => ExperimentProvider()),
    ChangeNotifierProvider(create: (_) => RecipeProvider()),
  ];
}
