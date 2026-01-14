import 'package:flutter/material.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeListViewModel extends ChangeNotifier {
  RecipeListViewModel({required RecipeRepository recipeRepository}) : _recipeRepository = recipeRepository {
    loadRecipes = Command0(_loadRecipeList)..execute();
    deleteRecipe = Command1(_deleteRecipe);
  }

  final RecipeRepository _recipeRepository;

  List<RawRecipe> get recipes => _recipeRepository.recipes;

  late final Command0 loadRecipes;
  late final Command1<void, int> deleteRecipe;

  Future<Result<void>> _loadRecipeList() async {
    await _recipeRepository.initDb();
    notifyListeners();
    return Result.ok(null);
  }

  void addRecipe(RawRecipe rawRecipe) {
    _recipeRepository.addRecipe(rawRecipe);
    notifyListeners();
  }

  Future<Result<void>> _deleteRecipe(int id) async {
    _recipeRepository.removeRecipe(id);
    notifyListeners();
    return Result.ok(null);
  }

  void resetRecipes() {
    _recipeRepository.resetRecipes();
    notifyListeners();
  }

  RawRecipe getRecipeByIndex(int index) {
    try {
      return recipes[index];
    } on IndexError {
      print('No index $index returning first recipe');
      return recipes[0];
    }
  }
}
