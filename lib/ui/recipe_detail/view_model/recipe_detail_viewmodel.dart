import 'package:flutter/material.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../domain/recipe/recipe.dart';
import '../../../domain/ingredient/ingredient_with_quantity.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel({
    required RecipeRepository recipeRepository,
    required IngredientRepository ingredientRepository,
  }) : _recipeRepository = recipeRepository,
       _ingredientRepository = ingredientRepository {
    deleteRecipe = Command1(_deleteRecipe);
    loadRecipeById = Command1(_loadRecipeById);
  }

  final RecipeRepository _recipeRepository;
  final IngredientRepository _ingredientRepository;

  late final Command1<void, String> loadRecipeById;
  late final Command1<void, Recipe> deleteRecipe;

  late Recipe _recipe;
  late final List<Ingredient> _ingredientList;

  Recipe get getRecipe => _recipe;
  List<Ingredient> get getIngredients => _ingredientList;

  Future<Result<void>> _deleteRecipe(Recipe recipe) async {
    _recipeRepository.removeRecipe(recipe);
    notifyListeners();
    return Result.ok(null);
  }

  Future<Result<void>> _loadRecipeById(String? recipeIdStr) async {
    _ingredientRepository.initDb();
    await _recipeRepository.initDb();

    if (recipeIdStr == null) {
      return Result.error(RecipeError('No recipe id provided'));
    }
    int? recipeId = int.tryParse(recipeIdStr);
    if (recipeId == null) {
      return Result.error(RecipeError('Recipe id could not be parsed'));
    }

    if (recipeId == -1) {
      _recipe = Recipe();
      return Result.ok(null);
    }
    try {
      _recipe = _recipeRepository.getRecipeList.where((recipe) => recipe.id! == recipeId).first;
      List<Ingredient> ingredients = [];
      for (IngredientWithQuantity recipeIngredient in _recipe.ingredients) {
        final result = await _ingredientRepository.getIngredientbyId(recipeIngredient.ingredientId);
        switch (result) {
          case Ok<Ingredient>():
            ingredients.add(result.value);
          case Error<Ingredient>():
            return Result.error(RecipeError('Unknown argument: ${recipeIngredient.ingredientId}'));
        }
      }
      _ingredientList = ingredients;
      return Result.ok(null);
    } on StateError {
      return Result.error(RecipeError('No recipe with id: $recipeId'));
    }
  }

  String getIngredientName(int id) {
    try {
      return _ingredientList.where((ingredient) => ingredient.id == id).first.name;
    } on StateError {
      return 'Euuuuuh ton ingrédient n\'existe pas...';
    }
  }

  Future<Result<void>> updateRecipeName(String newName) async {
    Recipe newRecipe = _recipe.copyWith(name: newName);
    var result = await _recipeRepository.updateRecipe(_recipe, newRecipe);
    return handleResponseUpdate(result);
  }

  Future<Result<void>> updateRecipePreparationTime(String newPrepTime) async {
    Recipe newRecipe = _recipe.copyWith(preparationTime: newPrepTime);
    var result = await _recipeRepository.updateRecipe(_recipe, newRecipe);
    return handleResponseUpdate(result);
  }

  Future<Result<void>> updateRecipeCookingTime(String newCookingTime) async {
    Recipe newRecipe = _recipe.copyWith(cookingTime: newCookingTime);
    var result = await _recipeRepository.updateRecipe(_recipe, newRecipe);
    return handleResponseUpdate(result);
  }

  Future<Result<void>> updateRecipeNbOfPeople(String newNbOfPeopleAsString) async {
    int? newNbOfPeople = int.tryParse(newNbOfPeopleAsString);
    if (newNbOfPeople == null) {
      return Result.error(RecipeError('Could not parse input $newNbOfPeopleAsString'));
    }
    Recipe newRecipe = _recipe.copyWith(nbOfPeople: newNbOfPeople);
    var result = await _recipeRepository.updateRecipe(_recipe, newRecipe);
    return handleResponseUpdate(result);
  }

  Result<void> handleResponseUpdate(Result<void> result) {
    switch (result) {
      case Ok<void>():
        notifyListeners();
        return Result.ok(null);
      case Error<void>():
        return Result.error(RecipeError('Could not update recipe'));
    }
  }
}

class RecipeError implements Exception {
  String cause;
  RecipeError(this.cause);
}
