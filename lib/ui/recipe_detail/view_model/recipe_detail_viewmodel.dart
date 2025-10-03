import 'package:flutter/material.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel({required RecipeRepository recipeRepository})
    : _recipeRepository = recipeRepository {
    deleteRecipe = Command1(_deleteRecipe);
    getRecipeById = Command1(_getRecipeById);
  }

  final RecipeRepository _recipeRepository;


  late final Command1<void, String> getRecipeById;
  late final Command1<void, Recipe> deleteRecipe;

  Recipe? _recipe;

  Recipe get getRecipe => _recipe!;

  Future<Result<void>> _deleteRecipe(Recipe recipe) async {
      _recipeRepository.removeRecipe(recipe);
      notifyListeners();
      return Result.ok(null);
    }

  Future<Result<void>> _getRecipeById(String? recipeIdStr) async {
    if (recipeIdStr == null){
      return Result.error(NoRecipeError('No recipe id provided'));
    }
    int? recipeId = int.tryParse(recipeIdStr);
    try {
      _recipe = _recipeRepository.getRecipeList.where((recipe) => recipe.id == recipeId).first;
      return Result.ok(null);
    } on StateError {
      return Result.error(NoRecipeError('No recipe with id: $recipeId'));
    } 
  }
}

class NoRecipeError implements Exception{
  String cause;
  NoRecipeError(this.cause);
}