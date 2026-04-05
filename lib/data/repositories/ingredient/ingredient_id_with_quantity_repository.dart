import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/utils/result.dart';

import '../../services/database/database_ingredient_with_quantity.dart';

class IngredientIdWithQuantityRepository {
  IngredientIdWithQuantityRepository({required DatabaseIngredientWithQuantityService database})
    : _database = database;

  final DatabaseIngredientWithQuantityService _database;

  Future<Result<RawIngredientWithQuantity>> addRawIngredientWithQuantity(
    RawIngredientWithQuantity ingredientIdWithQuantity,
  ) async {
    try {
      var result = await _database.insertIngredientIdWithQuantity(ingredientIdWithQuantity);
      return Result.ok(result);
    } on Exception {
      return Result.error(
        IngredientIdWithQuantityRepositoryError('Could not add ingredientWithQuantity'),
      );
    }
  }

  Future<Result<void>> updateRawIngredientWithQuantity(
    RawIngredientWithQuantity ingredientIdWithQuantity,
  ) async {
    try {
      await _database.updateIngredientIdWithQuantity(ingredientIdWithQuantity);
      return Result.ok(null);
    } on Exception {
      return Result.error(
        IngredientIdWithQuantityRepositoryError('Could not update ingredient with quantity'),
      );
    }
  }

  Future<Result<List<RawIngredientWithQuantity>>> getAllRawIngredientWithQuantity() async {
    try {
      var result = await _database.getAllIngredientsIdWithQuantity();
      return Result.ok(result);
    } on Exception {
      return Result.error(IngredientIdWithQuantityRepositoryError('Could find the ingredient'));
    }
  }

  Future<Result<List<RawIngredientWithQuantity>>> getRawIngredientWithQuantityByIds(
    List<int> ids,
  ) async {
    try {
      var result = await _database.getIngredientIdsWithQuantityByIds(ids);
      return Result.ok(result);
    } on Exception {
      return Result.error(
        IngredientIdWithQuantityRepositoryError('Could not find the ingredientIdWithQuantity'),
      );
    }
  }

  Future<Result<void>> rawRemoveIngredientWithQuantity(
      RawIngredientWithQuantity ingredientIdWithQuantity,
  ) async {
    try {
      await _database.deleteIngredientIdWithQuantity(ingredientIdWithQuantity.id!);
      return Result.ok(null);
    } on Exception {
      return Result.error(
        IngredientIdWithQuantityRepositoryError('Could not remove ingredientIdWithQuantity'),
      );
    }
  }
}

class IngredientIdWithQuantityRepositoryError implements Exception {
  String cause;
  IngredientIdWithQuantityRepositoryError(this.cause);
}
