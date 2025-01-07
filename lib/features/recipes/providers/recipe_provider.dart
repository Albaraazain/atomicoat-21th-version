import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';
import '../../../core/services/logger_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repository;
  final LoggerService _logger;

  List<Recipe> _recipes = [];
  List<Recipe> _publicRecipes = [];
  bool _isLoading = false;
  String? _error;
  String? _currentMachineType;
  String? _currentUserId;

  RecipeProvider(this._repository) : _logger = LoggerService('RecipeProvider');

  List<Recipe> get recipes => _recipes;
  List<Recipe> get publicRecipes => _publicRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentMachineType => _currentMachineType;
  String? get currentUserId => _currentUserId;

  void setCurrentMachine(String machineType) {
    _logger.d('Setting current machine type: $machineType');
    if (_currentMachineType == machineType) return; // Don't update if the machine type hasn't changed
    _currentMachineType = machineType;
    if (_currentUserId != null) {
      loadRecipes(_currentUserId!);
    }
    notifyListeners();
  }

  void setCurrentUser(String userId) {
    _logger.d('Setting current user: $userId');
    if (_currentUserId == userId) return; // Don't update if the user hasn't changed
    _currentUserId = userId;
    if (_currentUserId != null) {
      loadRecipes(_currentUserId!);
    }
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.d('Getting recipe by id: $recipeId');
      final recipe = await _repository.getRecipeById(recipeId);

      _isLoading = false;
      notifyListeners();
      return recipe;
    } catch (e) {
      _logger.e('Error getting recipe: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    try {
      if (_currentMachineType == null) {
        const error = 'No machine type selected';
        _logger.e(error);
        throw Exception(error);
      }
      if (_currentUserId == null) {
        const error = 'No user logged in';
        _logger.e(error);
        throw Exception(error);
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final newRecipe = recipe.copyWith(
        machineType: _currentMachineType!,
        createdBy: _currentUserId!,
        version: 1,
        createdAt: now,
        updatedAt: now,
      );

      _logger.d('Creating new recipe: ${newRecipe.name}');
      await _repository.createRecipe(newRecipe);

      // Refresh the recipe list
      await loadRecipes(_currentUserId!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error creating recipe: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      if (_currentMachineType == null) {
        const error = 'No machine type selected';
        _logger.e(error);
        throw Exception(error);
      }
      if (_currentUserId == null) {
        const error = 'No user logged in';
        _logger.e(error);
        throw Exception(error);
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedRecipe = recipe.copyWith(
        updatedAt: DateTime.now(),
      );

      _logger.d('Updating recipe: ${updatedRecipe.name} (version ${updatedRecipe.version})');
      await _repository.updateRecipe(updatedRecipe);

      // Refresh the recipe list
      await loadRecipes(_currentUserId!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error updating recipe: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      if (_currentUserId == null) {
        const error = 'No user logged in';
        _logger.e(error);
        throw Exception(error);
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.d('Deleting recipe: $recipeId');
      await _repository.deleteRecipe(recipeId);

      // Refresh the recipe list
      await loadRecipes(_currentUserId!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error deleting recipe: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadRecipes(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.d('Loading recipes for user: $userId');
      final newRecipes = await _repository.getRecipes(userId);
      final newPublicRecipes = await _repository.getPublicRecipes();

      // Only update and notify if there are actual changes
      if (!_areRecipeListsEqual(_recipes, newRecipes) ||
          !_areRecipeListsEqual(_publicRecipes, newPublicRecipes)) {
        _recipes = newRecipes;
        _publicRecipes = newPublicRecipes;
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
      }
    } catch (e) {
      _logger.e('Error loading recipes: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Helper method to compare recipe lists
  bool _areRecipeListsEqual(List<Recipe> list1, List<Recipe> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].version != list2[i].version ||
          list1[i].updatedAt != list2[i].updatedAt) {
        return false;
      }
    }
    return true;
  }

  Future<void> cloneRecipe(String recipeId, String newName) async {
    try {
      if (_currentMachineType == null) {
        const error = 'No machine type selected';
        _logger.e(error);
        throw Exception(error);
      }
      if (_currentUserId == null) {
        const error = 'No user logged in';
        _logger.e(error);
        throw Exception(error);
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.d('Cloning recipe: $recipeId with new name: $newName');
      final recipe = await getRecipeById(recipeId);
      if (recipe != null) {
        final now = DateTime.now();
        final newRecipe = recipe.copyWith(
          id: null, // Let the database generate a new ID
          name: newName,
          version: 1,
          isPublic: false,
          machineType: _currentMachineType!,
          createdBy: _currentUserId!,
          createdAt: now,
          updatedAt: now,
        );

        await createRecipe(newRecipe);
      } else {
        const error = 'Recipe not found';
        _logger.e(error);
        throw Exception(error);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error cloning recipe: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

