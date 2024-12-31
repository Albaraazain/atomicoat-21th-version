import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/recipe_step.dart';

class RecipeProvider extends ChangeNotifier {
  String? currentUserId = 'mock_user_1';
  String? currentMachineId = 'mock_machine_1';

  List<Recipe> _recipes = [];
  List<Recipe> _publicRecipes = [];

  List<Recipe> get recipes => _recipes;
  List<Recipe> get publicRecipes => _publicRecipes;

  RecipeProvider() {
    // Initialize with mock data
    _recipes = [
      Recipe.mock(),
      Recipe(
        id: 'recipe_2',
        name: 'High Temperature Process',
        description: 'Advanced ALD process for high-temp applications',
        createdBy: 'mock_user_1',
        machineId: 'mock_machine_1',
        substrate: 'Sapphire',
        chamberTemperatureSetPoint: 350.0,
        pressureSetPoint: 2.0,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        steps: [
          RecipeStep(
            id: 'step_1',
            name: 'Initial Heating',
            description: 'Heat chamber to target temperature',
            type: StepType.setParameter,
            parameters: {'target': 350.0, 'rampRate': 10.0},
            subSteps: [],
          ),
        ],
        isPublic: false,
      ),
    ];

    _publicRecipes = [Recipe.mock()];
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    return _recipes.firstWhere((recipe) => recipe.id == recipeId);
  }

  Future<void> createRecipe(Recipe recipe) async {
    _recipes.add(recipe);
    notifyListeners();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _recipes[index] = recipe;
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    _recipes.removeWhere((recipe) => recipe.id == recipeId);
    notifyListeners();
  }

  void loadRecipes() {
    // Mock implementation - data is already loaded in constructor
    notifyListeners();
  }

  Future<void> cloneRecipe(String recipeId, String newName) async {
    final recipe = await getRecipeById(recipeId);
    if (recipe != null) {
      final newRecipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: newName,
        description: recipe.description,
        steps: recipe.steps,
        createdBy: currentUserId!,
        machineId: currentMachineId!,
        substrate: recipe.substrate,
        chamberTemperatureSetPoint: recipe.chamberTemperatureSetPoint,
        pressureSetPoint: recipe.pressureSetPoint,
        createdAt: DateTime.now(),
        isPublic: false,
      );
      await createRecipe(newRecipe);
    }
  }
}
