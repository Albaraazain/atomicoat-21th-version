import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/services/auth_service.dart';
import '../../features/components/providers/component_provider.dart';
import '../../features/process/providers/process_provider.dart';
import '../../features/experiments/providers/experiment_provider.dart';
import '../../features/recipes/providers/recipe_provider.dart';
import '../../features/recipes/repositories/recipe_repository.dart';
import '../../features/machines/providers/machine_provider.dart';
import '../../features/machines/repositories/machine_repository.dart';
import '../../features/users/providers/user_provider.dart';
import '../../features/users/repositories/user_repository.dart';

class ProviderConfig {
  static final supabase = Supabase.instance.client;
  static final authService = AuthService(supabase);
  static final machineRepository = MachineRepository(supabase);
  static final userRepository = UserRepository(supabase);
  static final recipeRepository = RecipeRepository(supabase);

  static final List<SingleChildWidget> providers = [
    Provider<SupabaseClient>.value(value: supabase),
    Provider<AuthService>(create: (_) => authService),
    Provider<MachineRepository>(create: (_) => machineRepository),
    Provider<UserRepository>(create: (_) => userRepository),
    Provider<RecipeRepository>(create: (_) => recipeRepository),

    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(authService),
    ),
    ChangeNotifierProvider<MachineProvider>(
      create: (_) => MachineProvider(machineRepository),
    ),
    ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(userRepository),
    ),
    ChangeNotifierProvider<RecipeProvider>(
      create: (_) => RecipeProvider(recipeRepository),
    ),
    ChangeNotifierProvider<ComponentProvider>(
      create: (_) => ComponentProvider(),
    ),
    ChangeNotifierProvider<ProcessProvider>(
      create: (_) => ProcessProvider(),
    ),
    ChangeNotifierProvider<ExperimentProvider>(
      create: (_) => ExperimentProvider(),
    ),
  ];
}
