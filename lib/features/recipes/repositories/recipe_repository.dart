import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Recipe>> getRecipes(String userId) async {
    final response =
        await _supabase.from('recipes').select().eq('created_by', userId);

    return (response as List).map((data) => Recipe.fromJson(data)).toList();
  }

  Future<List<Recipe>> getPublicRecipes() async {
    final response =
        await _supabase.from('recipes').select().eq('is_public', true);

    return (response as List).map((data) => Recipe.fromJson(data)).toList();
  }

  Future<Recipe?> getRecipeById(String userId, String recipeId) async {
    final response =
        await _supabase.from('recipes').select().eq('id', recipeId).single();

    if (response == null) return null;
    return Recipe.fromJson(response);
  }

  Future<void> createRecipe(
      String userId, String machineId, Recipe recipe) async {
    await _supabase.from('recipes').insert(recipe.toJson());
  }

  Future<void> updateRecipe(String userId, Recipe recipe) async {
    await _supabase.from('recipes').update(recipe.toJson()).eq('id', recipe.id);
  }

  Future<void> deleteRecipe(String userId, String recipeId) async {
    await _supabase.from('recipes').delete().eq('id', recipeId);
  }
}
