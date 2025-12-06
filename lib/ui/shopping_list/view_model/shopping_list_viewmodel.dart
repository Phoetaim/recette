import 'package:flutter/material.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/domain/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/shopping_list/shopping_ingredient.dart';
import '../../../data/repositories/shopping_list/shopping_list_repository.dart';
import '../../../domain/ingredient/ingredient.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class ShoppingListViewModel extends ChangeNotifier {
  ShoppingListViewModel({required IngredientRepository ingredientRepository, required ShoppingListRepository shoppingListRepository})
    : _ingredientRepository = ingredientRepository, _shoppingListRepository = shoppingListRepository {
    loadShoppingList = Command0(_loadShoppingList)..execute();
    addToShoppingList = Command1(_addToShoppingList);
    removeFromShoppingList = Command1(_removeFromShoppingList);
  }

  final IngredientRepository _ingredientRepository;
  final ShoppingListRepository _shoppingListRepository;

  late final Command0<void> loadShoppingList;
  late final Command1<void, IngredientWithQuantity> addToShoppingList;
  late final Command1<void, ShoppingIngredient> removeFromShoppingList;

  ShoppingList get getShoppingList => _shoppingListRepository.getShoppingList;

  Future<Result<void>> _loadShoppingList() async {
    await _shoppingListRepository.initDb();
    return Result.ok(null);
  }

  Future <Result<Ingredient>> getIngredientbyId (int id)  async {
      final result = await _ingredientRepository.getIngredientbyId(id);
      switch (result) {
        case Ok<Ingredient>():
          return Result.ok(result.value);
        case Error<Ingredient>():
          return Result.error(ShoppingListError('Unknown argument: $id'));
      }
      }


  Future<Result<void>> _addToShoppingList(IngredientWithQuantity ingredientWithQuantity) async {
    return Result.ok(null);
  }

  Future<Result<void>> _removeFromShoppingList(ShoppingIngredient shoppingIngredient) async {
    notifyListeners();
    return Result.ok(null);
  }
}

class ShoppingListError implements Exception {
  String cause;
  ShoppingListError(this.cause);
}

