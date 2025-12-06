import 'package:flutter/material.dart';
import '../../../data/repositories/ingredient/ingredient_repository.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../domain/ingredient/ingredient.dart';
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
    loadRecipeById = Command1(_loadRecipeById);
    saveRecipe = Command0(_saveRecipe);
    deleteRecipe = Command1(_deleteRecipe);
  }

  final RecipeRepository _recipeRepository;
  final IngredientRepository _ingredientRepository;

  late final Command1<void, String> loadRecipeById;
  late final Command0<void> saveRecipe;
  late final Command1<void, Recipe> deleteRecipe;

  late Recipe? _originalRecipe;
  late Recipe _recipe;
  late final List<Ingredient> _ingredientList;

  Recipe get getRecipe => _recipe;
  List<Ingredient> get getIngredients => _ingredientList;

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
      _originalRecipe = null;
      return Result.ok(null);
    }
    try {
      _originalRecipe = _recipeRepository.getRecipeList.where((recipe) => recipe.id! == recipeId).first;
      _recipe = _originalRecipe!;

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

  Future<Result<void>> _saveRecipe() async {
    if (_originalRecipe == null) {
      print('AddRecipe');
      print(_recipe.id);
      Result<int> result = await _recipeRepository.addRecipe(_recipe);
      switch (result) {
        case Ok<int>():
          _originalRecipe = _recipe.copyWith(id: result.value);
          _recipe = _originalRecipe!;
          notifyListeners();
          return Result.ok(null);
        case Error<int>():
          return Result.error(RecipeError('Could not update recipe'));
      }
    } else {
      Result<void> result = await _recipeRepository.updateRecipe(_originalRecipe!, _recipe);
      switch (result) {
        case Ok<void>():
          _originalRecipe = _recipe;
          notifyListeners();
          return Result.ok(null);
        case Error<void>():
          return Result.error(RecipeError('Could not update recipe'));
      }
    }
  }

  Future<Result<void>> _deleteRecipe(Recipe recipe) async {
    _recipeRepository.removeRecipe(recipe);
    notifyListeners();
    return Result.ok(null);
  }

  String getIngredientName(int id) {
    try {
      return _ingredientList.where((ingredient) => ingredient.id == id).first.name;
    } on StateError {
      return 'Euuuuuh ton ingrédient n\'existe pas...';
    }
  }

  void updateRecipeName(String newName) async {
    _recipe = _recipe.copyWith(name: newName);
    notifyListeners();
  }

  void updateRecipePreparationTime(String newPrepTime) async {
    _recipe = _recipe.copyWith(preparationTime: newPrepTime);
    notifyListeners();
  }

  void updateRecipeCookingTime(String newCookingTime) async {
    _recipe = _recipe.copyWith(cookingTime: newCookingTime);
    notifyListeners();
  }

  void updateRecipeNbOfPeople(String newNbOfPeopleAsString) async {
    int? newNbOfPeople = int.tryParse(newNbOfPeopleAsString);
    if (newNbOfPeople == null) {
      throw TypeError();
    }
    _recipe = _recipe.copyWith(nbOfPeople: newNbOfPeople);
    notifyListeners();
  }

  void updateIngredientOrder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final IngredientWithQuantity item = _recipe.ingredients.removeAt(oldIndex);
    _recipe.ingredients.insert(newIndex, item);
    notifyListeners();
  }

  bool isRecipeUpdated() {
    return _recipe != _originalRecipe;
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
