import 'dart:async';

import 'package:logging/logging.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/utils/result.dart';

import '../../../domain/models/shopping_list/shopping_ingredient.dart';
import '../../services/database/database_shopping_ingredient.dart';
import '../../services/models/raw_shopping_ingredient.dart';

typedef RawShoppingList = List<RawShoppingIngredient>;

class ShoppingListRepository {
  ShoppingListRepository({required DatabaseShoppingIngredientService database})
    : _database = database;

  var logger = Logger('ShoppingListRepository');
  final DatabaseShoppingIngredientService _database;

  StreamController<ShoppingIngredient> updatedShoppingList = StreamController.broadcast();

  Future<Result<RawShoppingList>> getShoppingList() async {
    try {
      final shoppingList = await _database.getAllShoppingIngredients();
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
      final response = await _database.insertShoppingIngredient(rawShoppingIngredient);
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

  Future<bool> checkAlreadyInShoppingList(IngredientWithQuantity ingredientWithQuantity) async {

    return true;
  }

  Future<Result<void>> updateShoppingIngredientStatus(ShoppingIngredient shoppingIngredient) async {
    try {
      await _database.updateShoppingIngredientStatus(shoppingIngredient.id!);
      return Result.ok(null);
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(e);
    }
  }

  Future<Result<void>> deleteShoppingIngredient(int id) async {
    try {
      await _database.deleteShoppingIngredient(id);
      return Result.ok(null);
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(e);
    }
  }

  Future<Result<void>> emptyShoppingList() async {
    try {
      await _database.broughtAllShoppingIngredients();
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(ShoppingIngredientRepositoryError('Could not buy all of shopping list'));
    }
    return Result.ok(null);
  }

  Future<Result<void>> emptyBoughtShoppingList() async {
    try {
      await _database.emptyBoughtShoppingList();
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
