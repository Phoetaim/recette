import 'package:flutter/material.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeListViewModel extends ChangeNotifier {
  RecipeListViewModel({required RecipeRepository recipeRepository}) : _recipeRepository = recipeRepository {
    loadRecipeList = Command0(_loadRecipeList)..execute();
    deleteRecipe = Command1(_deleteRecipe);
  }

  final RecipeRepository _recipeRepository;

  List<RawRecipe> get getRecipeList => _recipeRepository.getRecipeList;

  late final Command0 loadRecipeList;
  late final Command1<void, int> deleteRecipe;

  int recipeCount() => getRecipeList.length;

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
      return getRecipeList[index];
    } on IndexError {
      print('No index ${index}m returning first recipe');
      return getRecipeList[0];
    }
  }
}
