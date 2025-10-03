
import 'package:recette/utils/result.dart';

class Recipe {
  int? id;
  String name = 'Tarte à la tomate';
  String preparationTime = '1h';
  String cookingTime = '1h';
  int nbOfPeople = 4;

  Recipe(this.id);
}

final int startLength = 3;

class RecipeRepository {
  List<Recipe> _recipeList = [];
  int _sequentialId = startLength + 1;

  void initDb(){
    _recipeList = List.generate(startLength, (int index) => Recipe(index));
  }

  List<Recipe> get  getRecipeList => _recipeList;

  Future<Result<void>> addRecipe(Recipe recipe) async{
    recipe.id =_sequentialId++;
    _recipeList.add(recipe);
    return Result.ok(null);
  }

  Future<Result<void>> removeRecipe(Recipe recipe) async {
    _recipeList.removeWhere((item) => item.id == recipe.id);
    return Result.ok(null);
  }

  void resetRecipes(){
    _recipeList.clear();
  }
}