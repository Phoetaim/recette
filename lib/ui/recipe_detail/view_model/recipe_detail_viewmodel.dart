import 'package:flutter/material.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel({required RecipeRepository recipeRepository, required IngredientRepository ingredientRepository})
    : _recipeRepository = recipeRepository, _ingredientRepository = ingredientRepository {
    deleteRecipe = Command1(_deleteRecipe);
    loadRecipeById = Command1(_loadRecipeById);
  }

  final RecipeRepository _recipeRepository;
  final IngredientRepository _ingredientRepository;


  late final Command1<void, String> loadRecipeById;
  late final Command1<void, Recipe> deleteRecipe;

  late final Recipe _recipe;
  late final List<Ingredient> _ingredientList;

  Recipe get getRecipe => _recipe;
  List<Ingredient> get getIngredients =>_ingredientList;

  Future<Result<void>> _deleteRecipe(Recipe recipe) async {
      _recipeRepository.removeRecipe(recipe);
      notifyListeners();
      return Result.ok(null);
    }

  Future<Result<void>> _loadRecipeById(String? recipeIdStr) async {
    _ingredientRepository.initDb();
    _recipeRepository.initDb();

    if (recipeIdStr == null){
      return Result.error(RecipeError('No recipe id provided'));
    }
    int? recipeId = int.tryParse(recipeIdStr);
    try {
      _recipe = _recipeRepository.getRecipeList.where((recipe) => recipe.id == recipeId).first;
      List<Ingredient> ingredients = [];
      for (IngredientRecipe ingredientRecipe in _recipe.ingredients){
          final result = await _ingredientRepository.getIngredientbyId(ingredientRecipe.ingredientId);
          switch (result) {
            case Ok<Ingredient>():
              ingredients.add(result.value);
            case Error<Ingredient>():
              return Result.error(RecipeError('Unknown argument: ${ingredientRecipe.ingredientId}'));
          }
      }
      _ingredientList = ingredients;
      return Result.ok(null);
    } on StateError {
      return Result.error(RecipeError('No recipe with id: $recipeId'));
    } 
  }

  String getIngredientName(int id){
    try {
       return _ingredientList.where((ingredient) => ingredient.id == id).first.name;
    } on StateError {
      return 'Euuuuuh ton ingrédient n\'existe pas...';
    }

  }
}

class RecipeError implements Exception{
  String cause;
  RecipeError(this.cause);
}