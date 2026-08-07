import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/utils/result.dart';

import 'ingredient_with_quantity.dart';

class RecipeUtilsUseCase {
  RecipeUtilsUseCase({
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
    required ShoppingListRepository shoppingListRepository,
  }) : _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase,
       _shoppingListRepository = shoppingListRepository;

  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;
  final ShoppingListRepository _shoppingListRepository;

  // PUBLIC
  Future<Recipe> loadRecipe(RawRecipe rawRecipe) async {
    var jsonRawRecipe = rawRecipe.toJson();
    jsonRawRecipe.remove('ingredientWithQuantityIds');
    jsonRawRecipe['ingredients'] = await _loadIngredientsWithQuantity(rawRecipe);
    jsonRawRecipe['steps'] = rawRecipe.steps;
    return Recipe.fromJson(jsonRawRecipe);
  }

  Future<bool> addRecipeToShoppingList(Recipe recipe, int numberOfPeople) async {
    bool error = false;
    for (var ingredient in recipe.ingredients) {
      double newQuantity = ingredient.quantity / recipe.nbOfPeople * numberOfPeople;
      IngredientWithQuantity ingredientToAdd = ingredient.copyWith(quantity: newQuantity.round());
      var result = await _shoppingListRepository.addShoppingIngredient(ingredientToAdd);
      if (result is Error<void>) {
        error = true;
      }
    }
    return error;
  }

  // PRIVATE
  Future<List<Map<String, dynamic>>> _loadIngredientsWithQuantity(RawRecipe rawRecipe) async {
    final result = await _ingredientWithQuantityUseCase.getIngredientWithQuantityByIds(
      rawRecipe.ingredientWithQuantityIds,
    );
    switch (result) {
      case Ok<List<Map<String, dynamic>>>():
        return result.value;
      case Error<List<Map<String, dynamic>>>():
        return <Map<String, dynamic>>[];
    }
  }
}
