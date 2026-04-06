import 'dart:async';

import 'package:logging/logging.dart';
import 'package:recette/data/services/database/database_ingredient_with_quantity.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/utils/result.dart';

import '../../../domain/models/shopping_list/shopping_ingredient.dart';
import '../../services/database/database_shopping_ingredient.dart';
import '../../services/models/raw_ingredient_with_quantity.dart';
import '../../services/models/raw_shopping_ingredient.dart';

typedef RawShoppingList = List<RawShoppingIngredient>;

class ShoppingListRepository {
  ShoppingListRepository({
    required DatabaseShoppingIngredientService shoppingDatabase,
    required DatabaseIngredientWithQuantityService ingredientWithQuantityDatabase,
  })
    :   _shoppingDatabase = shoppingDatabase,
        _ingredientWithQuantityDatabase = ingredientWithQuantityDatabase;

  var logger = Logger('ShoppingListRepository');
  final DatabaseShoppingIngredientService _shoppingDatabase;
  final DatabaseIngredientWithQuantityService _ingredientWithQuantityDatabase;

  StreamController<ShoppingIngredient> updatedShoppingList = StreamController.broadcast();

  Future<Result<RawShoppingList>> getShoppingList() async {
    try {
      final shoppingList = await _shoppingDatabase.getAllShoppingIngredients();
      return Result.ok(shoppingList);
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(ShoppingIngredientRepositoryError('Could not retrieve shopping list'));
    }
  }

  Future<Result<RawShoppingIngredient>> addShoppingIngredient(
    IngredientWithQuantity ingredientWithQuantity,
  ) async {
    RawShoppingIngredient rawShoppingIngredient = RawShoppingIngredient(
      ingredientWithQuantityId: ingredientWithQuantity.id!,
    );
    try {
      final response = await _shoppingDatabase.insertShoppingIngredient(rawShoppingIngredient);
      ShoppingIngredient shoppingIngredient = ShoppingIngredient(
        id: response.id,
        bought: response.bought == 1,
        ingredientWithQuantity: ingredientWithQuantity,
      );
      updatedShoppingList.add(shoppingIngredient);
      return Result.ok(response);
    } on Exception catch (e) {
      logger.warning(e);
      print(e);
      return Result.error(ShoppingIngredientRepositoryError('Could not add shopping ingredient'));
    }
  }

  Future<RawIngredientWithQuantity?> handleIngredientAlreadyInShoppingList(IngredientWithQuantity ingredientWithQuantity) async {
    if (ingredientWithQuantity.ingredient.id != null) {
      final DuplicateShoppingIngredientResult? result = await _shoppingDatabase.checkIngredientAlreadyInShoppingList(ingredientWithQuantity.ingredient.id!);
      if (result == null) {
        return null;
      }
      else {
        if (result.rawIngredientWithQuantity.unit == ingredientWithQuantity.unit) {
          await updateDuplicateShoppingIngredient(result, ingredientWithQuantity);
        }
        return result.rawIngredientWithQuantity;
      }
    }
    return null;
  }

  Future<void> updateDuplicateShoppingIngredient(DuplicateShoppingIngredientResult result, IngredientWithQuantity newIngredient) async {
    final rawIngredientWithQuantity = result.rawIngredientWithQuantity;
    int newQuantity = rawIngredientWithQuantity.quantity + newIngredient.quantity;
    var updatedRawIngredientWithQuantity = rawIngredientWithQuantity.copyWith(quantity: newQuantity);
    var updatedIngredientWithQuantity = newIngredient.copyWith(id: rawIngredientWithQuantity.id, quantity: newQuantity);
    _ingredientWithQuantityDatabase.updateIngredientIdWithQuantity(updatedRawIngredientWithQuantity);
    final updatedShoppingIngredient = ShoppingIngredient(
      id: result.shoppingIngredientId,
      bought: false,
      ingredientWithQuantity: updatedIngredientWithQuantity,
    );

    updatedShoppingList.add(updatedShoppingIngredient);
  }
  Future<Result<void>> updateShoppingIngredientStatus(ShoppingIngredient shoppingIngredient) async {
    try {
      await _shoppingDatabase.updateShoppingIngredientStatus(shoppingIngredient.id!);
      return Result.ok(null);
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(e);
    }
  }

  Future<Result<void>> deleteShoppingIngredient(int id) async {
    try {
      await _shoppingDatabase.deleteShoppingIngredient(id);
      return Result.ok(null);
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(e);
    }
  }

  Future<Result<void>> emptyShoppingList() async {
    try {
      await _shoppingDatabase.broughtAllShoppingIngredients();
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(ShoppingIngredientRepositoryError('Could not buy all of shopping list'));
    }
    return Result.ok(null);
  }

  Future<Result<void>> emptyBoughtShoppingList() async {
    try {
      await _shoppingDatabase.emptyBoughtShoppingList();
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(ShoppingIngredientRepositoryError('Could not empty Shopping list'));
    }
    return Result.ok(null);
  }
}

class ShoppingIngredientRepositoryError implements Exception {
  String cause;
  ShoppingIngredientRepositoryError(this.cause);
}
