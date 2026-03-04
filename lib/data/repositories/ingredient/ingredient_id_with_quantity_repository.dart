import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/utils/result.dart';

import '../../services/database.dart';


class IngredientIdWithQuantityRepository {
  IngredientIdWithQuantityRepository({required DatabaseService database}) : _database = database;

  final DatabaseService _database;


  Future<Result<RawIngredientWithQuantity>> addRawIngredientWithQuantity(RawIngredientWithQuantity ingredientIdWithQuantity) async {
    await _database.ensureDatabase();
    var result = await _database.insertIngredientIdWithQuantity(ingredientIdWithQuantity);
    switch (result) {
      case Ok<RawIngredientWithQuantity>():
        return result;
      case Error<RawIngredientWithQuantity>():
        return Result.error(IngredientIdWithQuantityRepositoryError('Could not add ingredientWithQuantity'));
    }
  }

  Future<Result<void>> updateRawIngredientWithQuantity(RawIngredientWithQuantity ingredientIdWithQuantity) async {
    await _database.ensureDatabase();
    var result = await _database.updateIngredientIdWithQuantity(ingredientIdWithQuantity);
    switch (result) {
      case Ok<void>():
        return Result.ok(null);
      case Error<void>():
        return Result.error(IngredientIdWithQuantityRepositoryError('Could not update ingredient with quantity'));
    }
  }

  Future<Result<List<RawIngredientWithQuantity>>> getAllRawIngredientWithQuantity() async{
    await _database.ensureDatabase();
    var result = await _database.getAllIngredientsIdWithQuantity();
    switch (result) {
      case Ok<List<RawIngredientWithQuantity>>():
        return result;
      case Error<List<RawIngredientWithQuantity>>():
        return Result.error(IngredientIdWithQuantityRepositoryError('Could find the ingredient'));
    }

  }

  Future<Result<List<RawIngredientWithQuantity>>> getRawIngredientWithQuantityByIds(List<int> ids) async {
    await _database.ensureDatabase();
    var result = await _database.getIngredientIdsWithQuantityByIds(ids);
    switch (result) {
      case Ok<List<RawIngredientWithQuantity>>():
        return Result.ok(result.value);
      case Error<List<RawIngredientWithQuantity>>():
        return Result.error(IngredientIdWithQuantityRepositoryError('Could not find the ingredientIdWithQuantity'));
    }
  }

  Future<Result<void>> rawRemoveIngredientWithQuantity(RawIngredientWithQuantity ingredientIdWithQuantity) async {
    await _database.ensureDatabase();
    var result = await _database.deleteIngredientIdWithQuantity(ingredientIdWithQuantity.id!);
    switch (result) {
      case Ok<void>():
        return Result.ok(null);
      case Error<void>():
        return Result.error(IngredientIdWithQuantityRepositoryError('Could not remove ingredientIdWithQuantity'));
    }
  }
  
}

class IngredientIdWithQuantityRepositoryError implements Exception {
  String cause;
  IngredientIdWithQuantityRepositoryError(this.cause);
}
