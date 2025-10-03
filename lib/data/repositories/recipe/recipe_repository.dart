import 'package:recette/utils/result.dart';

final int startLength = 3;

class RecipeRepository {
  List<Recipe> _recipeList = [];
  int _sequentialId = startLength + 1;
  bool initialized = false;

  List<Recipe> get getRecipeList => _recipeList;

  void initDb() {
    if (!initialized) {
      _recipeList = List.generate(startLength, (int index) => Recipe(index));
      initialized = true;
    }
  }

  Future<Result<void>> addRecipe(Recipe recipe) async {
    recipe.id = _sequentialId++;
    _recipeList.add(recipe);
    return Result.ok(null);
  }

  Future<Result<void>> removeRecipe(Recipe recipe) async {
    _recipeList.removeWhere((item) => item.id == recipe.id);
    return Result.ok(null);
  }

  void resetRecipes() {
    _recipeList.clear();
  }
}

class Recipe {
  int id;
  String name = 'Tarte à la tomate';
  String preparationTime = '1h';
  String cookingTime = '1h';
  int nbOfPeople = 4;
  List<IngredientRecipe> ingredients = [
    IngredientRecipe(ingredientId: 0, unit: IngredientUnit.unit, quantity: 1),
    IngredientRecipe(ingredientId: 1, unit: IngredientUnit.unit, quantity: 4),
    IngredientRecipe(ingredientId: 2, unit: IngredientUnit.unit, quantity: 1),
    IngredientRecipe(ingredientId: 3, unit: IngredientUnit.unit, quantity: 2),
  ];
  List<String> steps = ['Fais la tarte', 'Cuis la'];

  Recipe(this.id);
}

class IngredientRecipe {
  IngredientRecipe({
    required this.ingredientId,
    required this.unit,
    required this.quantity,
  });

  final int ingredientId;
  final IngredientUnit unit;
  final int quantity;
}

enum IngredientUnit { unit, kg, gramme, liter, cL }
