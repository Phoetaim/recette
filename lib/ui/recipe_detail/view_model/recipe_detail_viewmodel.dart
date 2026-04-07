import 'package:flutter/material.dart';
import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../data/services/models/raw_recipe.dart';
import '../../../domain/models/recipe/recipe.dart';
import '../../../domain/models/ingredient/ingredient_with_quantity.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel({
    required RecipeRepository recipeRepository,
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
    required ShoppingListRepository shoppingListRepository,
  }) : _recipeRepository = recipeRepository,
       _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase,
       _shoppingListRepository = shoppingListRepository {
    loadRecipeById = Command1(_loadRecipeById);
    saveRecipe = Command0(_saveRecipe);
    deleteRecipe = Command1(_deleteRecipe);
    addRecipeToShoppingList = Command0(_addRecipeToShoppingList);
  }

  final RecipeRepository _recipeRepository;
  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;
  final ShoppingListRepository _shoppingListRepository;

  late final Command1<void, String> loadRecipeById;
  late final Command0<void> saveRecipe;
  late final Command1<void, int> deleteRecipe;
  late final Command0<void> addRecipeToShoppingList;

  late RawRecipe _rawRecipe;
  late RawRecipe? _originalRecipe;
  final ValueNotifier<Recipe> recipe = ValueNotifier<Recipe>(Recipe());

  // Ingredient tab attributes
  final ValueNotifier<int> currentNumberOfPeople = ValueNotifier<int>(0);
  int tmpIngredientId = -1;

  Future<Result<void>> _loadRecipeById(String? recipeIdStr) async {
    if (recipeIdStr == null) {
      return Result.error(RecipeError('No recipe id provided'));
    }
    int? recipeId = int.tryParse(recipeIdStr);
    if (recipeId == null) {
      return Result.error(RecipeError('Recipe id could not be parsed'));
    }

    if (recipeId == -1) {
      _rawRecipe = RawRecipe();
      _originalRecipe = null;
      return Result.ok(null);
    }
    final result = await _recipeRepository.getRecipe(recipeId);
    switch (result) {
      case Ok<RawRecipe>():
        _originalRecipe = result.value;
      case Error<RawRecipe>():
        return Result.error(RecipeError('No recipe with id: $recipeId'));
    }

    _rawRecipe = _originalRecipe!;
    var jsonRawRecipe = _rawRecipe.toJson();
    jsonRawRecipe.remove('ingredientWithQuantityIds');
    jsonRawRecipe['ingredients'] = await loadIngredientsWithQuantity();
    jsonRawRecipe['steps'] = _rawRecipe.steps.split('\n');
    recipe.value = Recipe.fromJson(jsonRawRecipe);
    currentNumberOfPeople.value = recipe.value.nbOfPeople;
    notifyListeners();
    return Result.ok(null);
  }

  Future<List<Map<Object, Object>>> loadIngredientsWithQuantity() async {
    final result = await _ingredientWithQuantityUseCase.getIngredientWithQuantityByIds(
      _rawRecipe.ingredientWithQuantityIds,
    );
    switch (result) {
      case Ok<List<Map<Object, Object>>>():
        return result.value;
      case Error<List<Map<Object, Object>>>():
        return <Map<Object, Object>>[];
    }
  }

  Future<Result<void>> _saveRecipe() async {
    if (_rawRecipe.ingredientWithQuantityIds.length != recipe.value.ingredients.length) {
      for (var ingredientWithQuantity in recipe.value.ingredients) {
        if (ingredientWithQuantity.id! >= 0) {
          continue;
        }
        var result = await _ingredientWithQuantityUseCase.addIngredientWithQuantity(
          ingredientWithQuantity,
        );
        switch (result) {
          case Ok<IngredientWithQuantity>():
            List<int> ingredientWithQuantityIds = List.from(_rawRecipe.ingredientWithQuantityIds);
            ingredientWithQuantityIds.add(result.value.id!);
            _rawRecipe = _rawRecipe.copyWith(ingredientWithQuantityIds: ingredientWithQuantityIds);

            List<IngredientWithQuantity> ingredientsWithQuantity = List.from(
              recipe.value.ingredients,
            );
            int index = ingredientsWithQuantity.indexOf(ingredientWithQuantity);
            ingredientsWithQuantity.removeAt(index);
            ingredientsWithQuantity.insert(index, result.value);
            recipe.value = recipe.value.copyWith(ingredients: ingredientsWithQuantity);
          case Error<IngredientWithQuantity>():
            return Result.error(RecipeError('Could add new Ingredients'));
        }
      }
    }
    if (_originalRecipe == null) {
      final result = await _recipeRepository.addRecipe(_rawRecipe);
      switch (result) {
        case Ok<RawRecipe>():
          _originalRecipe = result.value;
          _rawRecipe = _originalRecipe!;
          return Result.ok(null);
        case Error<RawRecipe>():
          return Result.error(RecipeError('Could not update recipe'));
      }
    } else {
      Result<void> result = await _recipeRepository.updateRecipe(_originalRecipe!, _rawRecipe);
      switch (result) {
        case Ok<void>():
          _originalRecipe = _rawRecipe;
          return Result.ok(null);
        case Error<void>():
          return Result.error(RecipeError('Could not update recipe'));
      }
    }
  }

  Future<Result<void>> _deleteRecipe(int id) async {
    _recipeRepository.deleteRecipe(id);
    return Result.ok(null);
  }

  bool isRecipeUpdated() {
    return _rawRecipe != _originalRecipe ||
        _rawRecipe.ingredientWithQuantityIds.length != recipe.value.ingredients.length;
  }

  // Update info tab
  void updateRecipeName(String newName) async {
    _rawRecipe = _rawRecipe.copyWith(name: newName);
    recipe.value = recipe.value.copyWith(name: newName);
  }

  void updateRecipePreparationTime(String newPrepTime) async {
    _rawRecipe = _rawRecipe.copyWith(preparationTime: newPrepTime);
    recipe.value = recipe.value.copyWith(preparationTime: newPrepTime);
  }

  void updateRecipeCookingTime(String newCookingTime) async {
    _rawRecipe = _rawRecipe.copyWith(cookingTime: newCookingTime);
    recipe.value = recipe.value.copyWith(cookingTime: newCookingTime);
  }

  void updateRecipeNbOfPeople(String newNbOfPeopleAsString) async {
    int? newNbOfPeople = int.tryParse(newNbOfPeopleAsString);
    if (newNbOfPeople == null) {
      throw TypeError();
    }
    _rawRecipe = _rawRecipe.copyWith(nbOfPeople: newNbOfPeople);
    currentNumberOfPeople.value = newNbOfPeople;
    recipe.value = recipe.value.copyWith(nbOfPeople: newNbOfPeople);
  }

  void addIngredientWithQuantity(IngredientWithQuantity ingredientWithQuantity) async {
    List<IngredientWithQuantity> ingredientsWithQuantity = List.from(recipe.value.ingredients);
    ingredientsWithQuantity.add(ingredientWithQuantity.copyWith(id: tmpIngredientId--));
    recipe.value = recipe.value.copyWith(ingredients: ingredientsWithQuantity);
  }

  void removeIngredientWithQuantity(IngredientWithQuantity ingredientWithQuantity) {
    List<IngredientWithQuantity> ingredientsWithQuantity = List.from(recipe.value.ingredients);
    ingredientsWithQuantity.remove(ingredientWithQuantity);
    recipe.value = recipe.value.copyWith(ingredients: ingredientsWithQuantity);

    List<int> ingredientWithQuantityIds = List.from(_rawRecipe.ingredientWithQuantityIds);
    ingredientWithQuantityIds.remove(ingredientWithQuantity.id);
    _rawRecipe = _rawRecipe.copyWith(ingredientWithQuantityIds: ingredientWithQuantityIds);
  }

  Future<Result<void>> _addRecipeToShoppingList() async {
    saveRecipe.execute();
    bool error = false;
    for (var ingredient in recipe.value.ingredients) {
      double newQuantity =
          ingredient.quantity / recipe.value.nbOfPeople * currentNumberOfPeople.value;
      IngredientWithQuantity ingredientToAdd = ingredient.copyWith(quantity: newQuantity.round());
      var result = _shoppingListRepository.addShoppingIngredient(ingredientToAdd);
      if (result is Error<void>){
            error = true;
      }
    }

    if (error) {
      return Result.error(RecipeError('Could not add at least one ingredient'));
    }
    return Result.ok(null);
  }
}

class RecipeError implements Exception {
  String cause;
  RecipeError(this.cause);
}
