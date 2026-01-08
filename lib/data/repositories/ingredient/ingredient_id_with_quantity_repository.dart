import 'package:recette/data/services/models/ingredient_id_with_quantity.dart';
import 'package:recette/utils/result.dart';

import '../../services/database.dart';


class IngredientIdWithQuantityRepository {
  IngredientIdWithQuantityRepository({required DatabaseService database}) : _database = database;

  final DatabaseService _database;


  Future<Result<IngredientIdWithQuantity>> addIngredientIdWithQuantity(IngredientIdWithQuantity ingredientIdWithQuantity) async {
    await _ensureDatabase();
    var result = await _database.insertIngredientIdWithQuantity(ingredientIdWithQuantity);
    switch (result) {
      case Ok<IngredientIdWithQuantity>():
        return result;
      case Error<IngredientIdWithQuantity>():
        return Result.error(IngredientRepositoryError('Could not add ingredientWithQuantity'));
    }
  }

  Future<Result<void>> updateIngredientIdWithQuantity(IngredientIdWithQuantity ingredientIdWithQuantity) async {
    await _ensureDatabase();
    var result = await _database.updateIngredientIdWithQuantity(ingredientIdWithQuantity);
    switch (result) {
      case Ok<void>():
        return Result.ok(null);
      case Error<void>():
        return Result.error(IngredientRepositoryError('Could not update ingredient with quantity'));
    }
  }


  Future<Result<List<IngredientIdWithQuantity>>> getAllIngredientIdWithQuantity() async{
    await _ensureDatabase();
    var result = await _database.getAllIngredientsIdWithQuantity();
    switch (result) {
      case Ok<List<IngredientIdWithQuantity>>():
        return result;
      case Error<List<IngredientIdWithQuantity>>():
        return Result.error(IngredientRepositoryError('Could find the ingredient'));
    }

  }

  Future<Result<IngredientIdWithQuantity>> getIngredientIdWithQuantityById(int id) async {
    await _ensureDatabase();
    var result = await _database.getIngredientIdsWithQuantityByIds([id]);
    switch (result) {
      case Ok<List<IngredientIdWithQuantity>>():
        return Result.ok(result.value.first);
      case Error<List<IngredientIdWithQuantity>>():
        return Result.error(IngredientRepositoryError('Could find the ingredientIdWithQuantity'));
    }
  }

  Future<Result<void>> removeIngredientIdWithQuantity(IngredientIdWithQuantity ingredientIdWithQuantity) async {
    await _ensureDatabase();
    var result = await _database.deleteIngredientIdWithQuantity(ingredientIdWithQuantity.id!);
    switch (result) {
      case Ok<void>():
        return Result.ok(null);
      case Error<void>():
        return Result.error(IngredientRepositoryError('Could not remove ingredientIdWithQuantity'));
    }
  }


  Future<void> _ensureDatabase() async {
    if (!_database.isOpen()) {
      await _database.open();
    }
  }
}

class IngredientRepositoryError implements Exception {
  String cause;
  IngredientRepositoryError(this.cause);
}
