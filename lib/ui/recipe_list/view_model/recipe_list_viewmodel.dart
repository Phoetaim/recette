import 'package:flutter/material.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../domain/recipe/recipe.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeListViewModel extends ChangeNotifier {
  RecipeListViewModel({required RecipeRepository recipeRepository})
    : _recipeRepository = recipeRepository {
    loadRecipeList = Command0(_loadRecipeList)..execute();
    deleteRecipe = Command1(_deleteRecipe);
  }

  final RecipeRepository _recipeRepository;

  List<Recipe> get getRecipeList => _recipeRepository.getRecipeList;

  late final Command0 loadRecipeList;
  late final Command1<void, Recipe> deleteRecipe;

  int recipeCount() => getRecipeList.length;

  Future<Result<void>> _loadRecipeList() async {
    _recipeRepository.initDb();
    notifyListeners();
    return Result.ok(null);
  }

  void addRecipe(Recipe recipe) {
    _recipeRepository.addRecipe(recipe);
    notifyListeners();
  }

  Future<Result<void>> _deleteRecipe(Recipe recipe) async {
    _recipeRepository.removeRecipe(recipe);
    notifyListeners();
    return Result.ok(null);
  }

  void resetRecipes() {
    _recipeRepository.resetRecipes();
    notifyListeners();
  }

  Recipe getRecipeByIndex(int index) {
    try {
      return getRecipeList[index];
    } on IndexError {
      print('No index ${index}m returning first recipe');
      return getRecipeList[0];
    }
  }
}
