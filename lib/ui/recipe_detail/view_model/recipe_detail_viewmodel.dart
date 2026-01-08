import 'package:flutter/material.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../data/services/models/raw_recipe.dart';
import '../../../domain/models/recipe/recipe.dart';
import '../../../domain/models/ingredient/ingredient_with_quantity.dart';import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel({
    required RecipeRepository recipeRepository,
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
  }) : _recipeRepository = recipeRepository,
        _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase {
    loadRecipeById = Command1(_loadRecipeById);
    saveRecipe = Command0(_saveRecipe);
    deleteRecipe = Command1(_deleteRecipe);
  }

  final RecipeRepository _recipeRepository;
  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;

  late final Command1<void, String> loadRecipeById;
  late final Command0<void> saveRecipe;
  late final Command1<void, int> deleteRecipe;

  late Recipe _recipe;
  late RawRecipe _rawRecipe;
  late RawRecipe? _originalRecipe;

  Recipe get getRecipe => _recipe;

  Future<Result<void>> _loadRecipeById(String? recipeIdStr) async {
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
      _rawRecipe = RawRecipe();
      _originalRecipe = null;
      return Result.ok(null);
    }
    _originalRecipe = _recipeRepository.getRecipeList.where((recipe) => recipe.id! == recipeId).first;
    if (_originalRecipe == null) {
      return Result.error(RecipeError('No recipe with id: $recipeId'));
    }
    _rawRecipe = _originalRecipe!;
    List<IngredientWithQuantity> ingredientsWithQuantity = [];
    for (var recipeIngredientId in _rawRecipe.ingredientWithQuantityIds) {
       final result = await _ingredientWithQuantityUseCase.getIngredientWithQuantity(recipeIngredientId);
       switch (result) {
         case Ok<IngredientWithQuantity>():
           ingredientsWithQuantity.add(result.value);
        case Error<IngredientWithQuantity>():
          // If ingredient does not exists, pass
      }
    }
    var jsonRawRecipe = _rawRecipe.toJson();
    jsonRawRecipe.remove('ingredientWithQuantityIds');
    jsonRawRecipe['ingredients'] =  ingredientsWithQuantity;
    _recipe = Recipe.fromJson(jsonRawRecipe);
    return Result.ok(null);

  }

  Future<Result<void>> _saveRecipe() async {
    if (_originalRecipe == null) {
      Result<int> result = await _recipeRepository.addRecipe(_rawRecipe);
      switch (result) {
        case Ok<int>():
          _originalRecipe = _rawRecipe.copyWith(id: result.value);
          _rawRecipe = _originalRecipe!;
          notifyListeners();
          return Result.ok(null);
        case Error<int>():
          return Result.error(RecipeError('Could not update recipe'));
      }
    } else {
      Result<void> result = await _recipeRepository.updateRecipe(_originalRecipe!, _rawRecipe);
      switch (result) {
        case Ok<void>():
          _originalRecipe = _rawRecipe;
          notifyListeners();
          return Result.ok(null);
        case Error<void>():
          return Result.error(RecipeError('Could not update recipe'));
      }
    }
  }

  Future<Result<void>> _deleteRecipe(int id) async {
    _recipeRepository.removeRecipe(id);
    notifyListeners();
    return Result.ok(null);
  }

  void updateRecipeName(String newName) async {
    _recipe = _recipe.copyWith(name: newName);
    _rawRecipe = _rawRecipe.copyWith(name: newName);
    notifyListeners();
  }

  void updateRecipePreparationTime(String newPrepTime) async {
    _recipe = _recipe.copyWith(preparationTime: newPrepTime);
    _rawRecipe = _rawRecipe.copyWith(preparationTime: newPrepTime);
    notifyListeners();
  }

  void updateRecipeCookingTime(String newCookingTime) async {
    _recipe = _recipe.copyWith(cookingTime: newCookingTime);
    _rawRecipe = _rawRecipe.copyWith(cookingTime: newCookingTime);
    notifyListeners();
  }

  void updateRecipeNbOfPeople(String newNbOfPeopleAsString) async {
    int? newNbOfPeople = int.tryParse(newNbOfPeopleAsString);
    if (newNbOfPeople == null) {
      throw TypeError();
    }
    _recipe = _recipe.copyWith(nbOfPeople: newNbOfPeople);
    _rawRecipe = _rawRecipe.copyWith(nbOfPeople: newNbOfPeople);

    notifyListeners();
  }

  void updateIngredientOrder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final IngredientWithQuantity item = _recipe.ingredients.removeAt(oldIndex);
    _recipe.ingredients.insert(newIndex, item);
    final int ingredientWithQuantityIds = _rawRecipe.ingredientWithQuantityIds.removeAt(oldIndex);
    _rawRecipe.ingredientWithQuantityIds.insert(newIndex, ingredientWithQuantityIds);
    notifyListeners();
  }

  bool isRecipeUpdated() {
    return _rawRecipe != _originalRecipe;
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
