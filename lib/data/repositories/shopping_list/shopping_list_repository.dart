import 'package:recette/utils/result.dart';

import '../../../domain/models/shopping_list/shopping_ingredient.dart';

typedef ShoppingList = List<ShoppingIngredient>;

class ShoppingListRepository {
  final ShoppingList _shoppingList = <ShoppingIngredient>[];
  int _sequentialId = 0;
  bool initialized = false;

  ShoppingList get getShoppingList => _shoppingList;

  Future<Result<void>> addShoppingIngredient(ShoppingIngredient shoppingIngredient) async {
    ShoppingIngredient ingredientWithId = shoppingIngredient.copyWith(id: _sequentialId++);
    _shoppingList.add(ingredientWithId);
    return Result.ok(null);
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
