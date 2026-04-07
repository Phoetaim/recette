import 'dart:async';

import 'package:logging/logging.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:recette/utils/result.dart';

import '../../../domain/models/shopping_list/shopping_ingredient.dart';
import '../../services/database/database_shopping_ingredient.dart';
import '../../services/models/raw_shopping_ingredient.dart';

typedef RawShoppingList = List<RawShoppingIngredient>;

class ShoppingListRepository {
  ShoppingListRepository({
    required DatabaseShoppingIngredientService shoppingDatabase,
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
  }) : _shoppingDatabase = shoppingDatabase,
       _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase;

  var logger = Logger('ShoppingListRepository');
  final DatabaseShoppingIngredientService _shoppingDatabase;
  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;

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

  Future<Result<void>> addShoppingIngredient(IngredientWithQuantity ingredientWithQuantity) async {
    if (_ingredientExists(ingredientWithQuantity)) {
      final result = await _shoppingDatabase.checkIngredientAlreadyInShoppingList(
        ingredientWithQuantity.ingredient.id!,
        ingredientWithQuantity.unit.name,
      );

      if (result != null) {
        return await _updateDuplicateShoppingIngredient(result, ingredientWithQuantity);
      }
    }

    var result = await _ingredientWithQuantityUseCase.addIngredientWithQuantity(
      ingredientWithQuantity,
    );
    switch (result) {
      case Ok<IngredientWithQuantity>():
        return await _addShoppingIngredientToDatabase(result.value);
      case Error<IngredientWithQuantity>():
        return Result.error(ShoppingIngredientRepositoryError('Could not add shopping ingredient'));
    }
  }

  bool _ingredientExists(IngredientWithQuantity ingredientWithQuantity) {
    return ingredientWithQuantity.ingredient.id != null;
  }

  Future<Result<void>> _updateDuplicateShoppingIngredient(
    DuplicateShoppingIngredientResult result,
    IngredientWithQuantity newIngredient,
  ) async {
    // Update ingredient with quantity
    final rawIngredientWithQuantity = result.rawIngredientWithQuantity;
    int newQuantity = rawIngredientWithQuantity.quantity + newIngredient.quantity;
    var rawUpdatedIngredientWithQuantity = rawIngredientWithQuantity.copyWith(
      quantity: newQuantity,
    );
    var updatedIngredientWithQuantity = newIngredient.copyWith(
      id: rawIngredientWithQuantity.id,
      quantity: newQuantity,
    );
    _ingredientWithQuantityUseCase.updateIngredientWithQuantity(rawUpdatedIngredientWithQuantity);

    // Send updated shopping ingredient to shopping list
    final updatedShoppingIngredient = ShoppingIngredient(
      id: result.shoppingIngredientId,
      ingredientWithQuantity: updatedIngredientWithQuantity,
    );
    updatedShoppingList.add(updatedShoppingIngredient);

    return Result.ok(null);
  }

  Future<Result<void>> _addShoppingIngredientToDatabase(
    IngredientWithQuantity ingredientWithQuantity,
  ) async {
    RawShoppingIngredient rawShoppingIngredient = RawShoppingIngredient(
      ingredientWithQuantityId: ingredientWithQuantity.id!,
    );
    try {
      final response = await _shoppingDatabase.insertShoppingIngredient(rawShoppingIngredient);

      // Send shopping ingredient to shopping list
      ShoppingIngredient shoppingIngredient = ShoppingIngredient(
        id: response.id,
        bought: response.bought == 1,
        ingredientWithQuantity: ingredientWithQuantity,
      );
      updatedShoppingList.add(shoppingIngredient);
      return Result.ok(null);
    } on Exception catch (e) {
      logger.warning(e);
      return Result.error(ShoppingIngredientRepositoryError('Could not add shopping ingredient'));
    }
  }

  Future<Result<void>> toggleShoppingIngredientStatus(ShoppingIngredient shoppingIngredient) async {
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
