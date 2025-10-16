import 'package:recette/utils/result.dart';

import '../../../domain/recipe/recipe.dart';
import '../../services/local_service.dart';

final int startLength = 3;

class RecipeRepository {
  RecipeRepository({required LocalDataService localDataService}) : _localDataService = localDataService;

  List<Recipe> _recipeList = [];
  int _sequentialId = startLength + 1;
  bool initialized = false;
  final LocalDataService _localDataService;

  List<Recipe> get getRecipeList => _recipeList;

  Future<void> initDb() async {
    if (!initialized) {
      _recipeList = await _localDataService.getRecipes();
      initialized = true;
    }
  }

  Future<Result<int>> addRecipe(Recipe recipe) async {
    final recipeWithId = recipe.copyWith(id: _sequentialId++);
    _recipeList.add(recipeWithId);
    return Result.ok(recipeWithId.id!);
  }


  Future<Result<void>> updateRecipe(Recipe oldRecipe, Recipe newRecipe) async {
    int index = _recipeList.indexOf(oldRecipe);
    _recipeList.replaceRange(index, index + 1, [newRecipe]);
    return Result.ok(null);
  }

  Future<Result<void>> removeRecipe(Recipe recipe) async {
    _recipeList.removeWhere((item) => item.id == recipe.id);
    return Result.ok(null);
  }

  void resetRecipes() {
    initialized = false;
    _recipeList.clear();
  }
}
