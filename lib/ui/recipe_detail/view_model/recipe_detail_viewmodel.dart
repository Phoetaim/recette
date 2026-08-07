import 'package:flutter/material.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:recette/domain/use_cases/recipe_utils.dart';
import 'package:recette/utils/commands.dart';
import 'package:recette/utils/result.dart';

typedef Ingredients = List<IngredientWithQuantity>;

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel({
    required RecipeRepository recipeRepository,
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
    required RecipeUtilsUseCase recipeUtilsUseCase,
    required ImportExportUseCase importExportUseCase,
  }) : _recipeRepository = recipeRepository,
       _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase,
       _recipeUtilsUseCase = recipeUtilsUseCase,
       _importExportUseCase = importExportUseCase {
    loadRecipeById = Command1(_loadRecipeById);
    saveRecipe = Command1(_saveRecipe);
    deleteRecipe = Command0(_deleteRecipe);
    addToShoppingList = Command1(_addToShoppingList);
  }

  final RecipeRepository _recipeRepository;
  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;
  final ImportExportUseCase _importExportUseCase;
  final RecipeUtilsUseCase _recipeUtilsUseCase;

  late final Command1<void, String> loadRecipeById;
  late final Command1<void, Recipe> saveRecipe;
  late final Command0<void> deleteRecipe;
  late final Command1<void, Recipe> addToShoppingList;

  final ValueNotifier<Recipe> recipe = ValueNotifier<Recipe>(Recipe());

  // Ingredient tab attributes
  final ValueNotifier<int> currentNumberOfPeople = ValueNotifier<int>(0);

  ////////////////////////////
  ///////// Commands /////////
  ////////////////////////////
  Future<Result<void>> _loadRecipeById(String? recipeIdStr) async {
    if (recipeIdStr == null) {
      return Result.error(RecipeError('No recipe id provided'));
    }
    int? recipeId = int.tryParse(recipeIdStr);
    if (recipeId == null) {
      return Result.error(RecipeError('Recipe id could not be parsed'));
    }

    if (recipeId == -1) {
      currentNumberOfPeople.value = recipe.value.nbOfPeople;
      return Result.ok(null);
    }
    final result = await _recipeRepository.getRecipe(recipeId);
    switch (result) {
      case Ok<RawRecipe>():
        recipe.value = await _recipeUtilsUseCase.loadRecipe(result.value);
        currentNumberOfPeople.value = recipe.value.nbOfPeople;
        notifyListeners();
        return Result.ok(null);
      case Error<RawRecipe>():
        return Result.error(RecipeError('No recipe with id: $recipeId'));
    }
  }

  Future<Result<void>> _saveRecipe(Recipe formRecipe) async {
    final ingredientResult = await _saveIngredients(formRecipe.ingredients);
    switch (ingredientResult) {
      case Ok<List<IngredientWithQuantity>>():
        formRecipe = formRecipe.copyWith(ingredients: ingredientResult.value);
      case Error<void>():
        return ingredientResult;
    }
    if (formRecipe.id == null) {
      return await _addRecipe(formRecipe);
    } else {
      return await _updateRecipe(formRecipe);
    }
  }

  Future<Result<void>> _deleteRecipe() async {
    if (recipe.value.id != null) {
      return await _recipeRepository.deleteRecipe(recipe.value.id!);
    }
    return Result.ok(null);
  }

  Future<Result<void>> _addToShoppingList(Recipe formRecipe) async {
    await _saveRecipe(formRecipe);
    bool error = await _recipeUtilsUseCase.addRecipeToShoppingList(
      recipe.value,
      currentNumberOfPeople.value,
    );

    if (error) {
      return Result.error(RecipeError('Could not add at least one ingredient'));
    }
    return Result.ok(null);
  }

  //////////////////////////
  ///////// Public /////////
  //////////////////////////
  Future<void> exportRecipe() async {
    await _importExportUseCase.exportRecipes({recipe.value.id!});
    notifyListeners();
  }

  ///////////////////////////
  ///////// Private /////////
  ///////////////////////////
  Future<Result<Ingredients>> _saveIngredients(Ingredients ingredients) async {
    Ingredients updatedIngredients = List.from(ingredients);
    for (var ingredient in ingredients) {
      if (ingredient.id! >= 0) {
        continue;
      }
      var result = await _ingredientWithQuantityUseCase.addIngredientWithQuantity(ingredient);
      switch (result) {
        case Ok<IngredientWithQuantity>():
          updatedIngredients.remove(ingredient);
          updatedIngredients.add(result.value);
        case Error<IngredientWithQuantity>():
          return Result.error(RecipeError('Could add new Ingredients'));
      }
    }
    return Result.ok(updatedIngredients);
  }

  Future<Result<void>> _addRecipe(Recipe newRecipe) async {
    RawRecipe rawRecipe = convertToRawRecipe(newRecipe);
    final result = await _recipeRepository.addRecipe(rawRecipe);
    switch (result) {
      case Ok<RawRecipe>():
        recipe.value = newRecipe.copyWith(id: result.value.id);
        return Result.ok(null);
      case Error<RawRecipe>():
        return Result.error(RecipeError('Could not create recipe'));
    }
  }

  Future<Result<void>> _updateRecipe(Recipe updatedRecipe) async {
    RawRecipe rawRecipe = convertToRawRecipe(updatedRecipe);
    Result<void> result = await _recipeRepository.updateRecipe(rawRecipe);
    switch (result) {
      case Ok<void>():
        recipe.value = updatedRecipe;
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
