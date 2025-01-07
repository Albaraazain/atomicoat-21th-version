import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';
import '../../../core/services/logger_service.dart';

class RecipeRepository {
  final SupabaseClient _supabase;
  final LoggerService _logger;

  RecipeRepository(this._supabase) : _logger = LoggerService('RecipeRepository');

  Future<List<Recipe>> getRecipes(String userId) async {
    try {
      _logger.d('Getting recipes for user: $userId');
      final response = await _supabase
          .from('recipes')
          .select('*, recipe_steps(*)')
          .eq('created_by', userId)
          .order('created_at', ascending: false);

      _logger.d('Retrieved ${response.length} recipes');
      return (response as List).map((data) => Recipe.fromJson(data)).toList();
    } catch (e) {
      _logger.e('Error getting recipes: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<Recipe>> getPublicRecipes() async {
    try {
      _logger.d('Getting public recipes');
      final response = await _supabase
          .from('recipes')
          .select('*, recipe_steps(*)')
          .eq('is_public', true)
          .order('created_at', ascending: false);

      _logger.d('Retrieved ${response.length} public recipes');
      return (response as List).map((data) => Recipe.fromJson(data)).toList();
    } catch (e) {
      _logger.e('Error getting public recipes: ${e.toString()}');
      rethrow;
    }
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      _logger.d('Getting recipe by id: $recipeId');
      final response = await _supabase
          .from('recipes')
          .select('*, recipe_steps(*)')
          .eq('id', recipeId)
          .single();

      _logger.d('Recipe found: ${response['name']}');
      return Recipe.fromJson(response);
    } catch (e) {
      _logger.e('Error getting recipe by id: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    try {
      _logger.d('Creating recipe: ${recipe.name}');

      // Remove IDs from recipe and steps to let database generate them
      final recipeData = recipe.toJson()..remove('id');

      // Insert the recipe first
      final recipeResponse = await _supabase
          .from('recipes')
          .insert(recipeData)
          .select()
          .single();

      _logger.d('Recipe created with id: ${recipeResponse['id']}');

      // Insert recipe steps
      if (recipe.steps.isNotEmpty) {
        final stepsData = recipe.steps.asMap().entries.map((entry) {
          final stepData = entry.value.toJson()
            ..remove('id')  // Remove step ID to let database generate it
            ..['recipe_id'] = recipeResponse['id']  // Add recipe ID reference
            ..['sequence_number'] = entry.key + 1;  // Add sequence number (1-based)
          return stepData;
        }).toList();

        await _supabase.from('recipe_steps').insert(stepsData);
        _logger.d('Created ${stepsData.length} recipe steps');
      }

      _logger.i('Recipe creation completed successfully');
    } catch (e) {
      _logger.e('Error creating recipe: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      if (recipe.id == null) {
        throw Exception('Cannot update recipe without an ID');
      }

      _logger.d('Updating recipe: ${recipe.name}');

      // Update the recipe
      await _supabase
          .from('recipes')
          .update({
            ...recipe.toJson(),
            'version': recipe.version + 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', recipe.id!);

      _logger.d('Recipe updated: ${recipe.id}');

      // Delete existing steps
      await _supabase
          .from('recipe_steps')
          .delete()
          .eq('recipe_id', recipe.id!);

      _logger.d('Deleted existing recipe steps');

      // Insert new steps
      if (recipe.steps.isNotEmpty) {
        final stepsData = recipe.steps.map((step) {
          final stepData = step.toJson()
            ..remove('id')  // Remove step ID to let database generate new ones
            ..['recipe_id'] = recipe.id!;  // Add recipe ID reference
          return stepData;
        }).toList();

        await _supabase.from('recipe_steps').insert(stepsData);
        _logger.d('Created ${stepsData.length} new recipe steps');
      }

      _logger.i('Recipe update completed successfully');
    } catch (e) {
      _logger.e('Error updating recipe: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      _logger.d('Deleting recipe: $recipeId');

      // Delete recipe steps first (due to foreign key constraint)
      await _supabase
          .from('recipe_steps')
          .delete()
          .eq('recipe_id', recipeId);

      _logger.d('Deleted recipe steps');

      // Delete the recipe
      await _supabase
          .from('recipes')
          .delete()
          .eq('id', recipeId);

      _logger.d('Deleted recipe');
      _logger.i('Recipe deletion completed successfully');
    } catch (e) {
      _logger.e('Error deleting recipe: ${e.toString()}');
      rethrow;
    }
  }
}
