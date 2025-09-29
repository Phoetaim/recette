import 'package:flutter/material.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeListViewModel extends ChangeNotifier {
  RecipeListViewModel({required RecipeRepository recipeRepository})
    : _recipeRepository = recipeRepository {
    loadRecipeList =  Command0(_loadRecipeList)..execute();
  }

  final RecipeRepository _recipeRepository;
  int id = 0;

  List<Recipe> _recipeList = <Recipe>[];

  List<Recipe> get getRecipeList => _recipeList;

  late final Command0 loadRecipeList;
  
  int recipeCount() => _recipeList.length;

  Future<Result<void>> _loadRecipeList() async {
    print('load');
    _recipeRepository.initDb();
    _recipeList = _recipeRepository.getRecipeList;
    notifyListeners();
    return Result.ok(null);
  }

  void addRecipe(Recipe recipe) {
    print('confirm add!');
    _recipeList.add(recipe);
    _recipeRepository.addRecipe(recipe);
    id++;
    notifyListeners();
  }

  void deleteRecipe(Recipe recipe) {
    if (_recipeList.contains(recipe)) {
      _recipeRepository.removeRecipe(recipe);
      _recipeList.remove(recipe);
      notifyListeners();
    }
  }

  void resetRecipes() {
    _recipeList.clear();
    _recipeRepository.resetRecipes();
    id = 0;
    notifyListeners();
  }

  Recipe getRecipeByIndex(int index){
    print('Getting item ${index}');
    try {
      return _recipeList[index];
    } on IndexError {
      print('No index ${index}m returning first recipe');
      return _recipeList[0];
    } 
  }
}
