import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';
import '../../../widgets/app_drawer.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/auth/providers/auth_provider.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _logger = LoggerService('RecipeListScreen');
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize user and machine type after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      final supabase = Supabase.instance.client;

      if (authProvider.userId != null) {
        try {
          // Get user's machine assignment
          final response = await supabase
              .from('machine_assignments')
              .select('machines (machine_type)')
              .eq('user_id', authProvider.userId as Object)
              .eq('status', 'active')
              .single();

          if (response['machines'] != null) {
            final machineType = response['machines']['machine_type'] as String;
            _logger.d('Setting machine type for user: $machineType');
            recipeProvider.setCurrentMachine(machineType);
          }

          // Set current user after machine type is set
          recipeProvider.setCurrentUser(authProvider.userId!);
        } catch (e) {
          _logger.e('Error getting user machine assignment: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecipeProvider, AuthProvider>(
      builder: (context, recipeProvider, authProvider, child) {
        if (authProvider.userId == null) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Recipe Management'),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _logger.i('Opening app drawer from RecipeListScreen');
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
            drawer: AppDrawer(),
            body: const Center(child: Text('Please log in first')),
          );
        }

        if (recipeProvider.currentMachineType == null) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Recipe Management'),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _logger.i('Opening app drawer from RecipeListScreen');
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
            drawer: AppDrawer(),
            body: const Center(child: Text('Please select a machine type first')),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Recipe Management'),
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _logger.i('Opening app drawer from RecipeListScreen');
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'My Recipes'),
                Tab(text: 'Public Recipes'),
              ],
            ),
          ),
          drawer: AppDrawer(),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRecipeList(context, recipeProvider.recipes, recipeProvider),
              _buildRecipeList(context, recipeProvider.publicRecipes, recipeProvider),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _logger.i('Creating new recipe');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildRecipeList(BuildContext context, List<Recipe> recipes, RecipeProvider provider) {
    if (recipes.isEmpty) {
      return const Center(
        child: Text(
          'No recipes available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              recipe.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created: ${recipe.createdAt.toString().split('.')[0]}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Version: ${recipe.version}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: recipe.createdBy == provider.currentUserId
                ? PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          if (recipe.id != null) {
                            _logger.i('Editing recipe: ${recipe.id}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(recipeId: recipe.id!),
                              ),
                            );
                          }
                          break;
                        case 'delete':
                          if (recipe.id != null) {
                            _logger.i('Deleting recipe: ${recipe.id}');
                            await provider.deleteRecipe(recipe.id!);
                          }
                          break;
                        case 'clone':
                          if (recipe.id != null) {
                            _logger.i('Cloning recipe: ${recipe.id}');
                            await provider.cloneRecipe(
                              recipe.id!,
                              'Copy of ${recipe.name}',
                            );
                          }
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      PopupMenuItem(
                        value: 'clone',
                        child: Text('Clone'),
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      if (recipe.id != null) {
                        _logger.i('Cloning recipe: ${recipe.id}');
                        await provider.cloneRecipe(
                          recipe.id!,
                          'Copy of ${recipe.name}',
                        );
                      }
                    },
                  ),
            onTap: () {
              if (recipe.id != null) {
                _logger.i('Opening recipe details: ${recipe.id}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipeId: recipe.id!),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
