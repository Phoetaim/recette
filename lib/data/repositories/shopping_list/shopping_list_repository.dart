import 'dart:async';

import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/utils/result.dart';

import '../../../domain/models/shopping_list/shopping_ingredient.dart';

typedef ShoppingList = List<ShoppingIngredient>;

class ShoppingListRepository {
  final ShoppingList _shoppingList = <ShoppingIngredient>[];
  int _sequentialId = 0;

  ShoppingList get shoppingList => _shoppingList;
  StreamController<void> updatedShoppingList = StreamController.broadcast();

  Future<Result<ShoppingIngredient>> addShoppingIngredient(IngredientWithQuantity ingredientWithQuantity) async {
    ShoppingIngredient initShoppingIngredient = ShoppingIngredient(ingredientWithQuantity: ingredientWithQuantity);
    ShoppingIngredient shoppingIngredient = initShoppingIngredient.copyWith(id: _sequentialId++);
    _shoppingList.add(shoppingIngredient);
    updatedShoppingList.add(null);
    return Result.ok(shoppingIngredient);
  }

  Future<Result<void>> removeShoppingIngredient(ShoppingIngredient shoppingIngredient) async {
    _shoppingList.removeWhere((item) => item.id == shoppingIngredient.id);
    return Result.ok(null);
  }

  Future<Result<void>> removeBoughtIngredients() async {
    _shoppingList.removeWhere((item) => item.bought);
    return Result.ok(null);
  }

  void emptyShoppingList() {
    _shoppingList.clear();
  }

}

class ShoppingIngredientRepositoryError implements Exception {
  String cause;
  ShoppingIngredientRepositoryError(this.cause);
}
