import 'dart:async';

import 'package:recette/data/services/database/database_ingredient_types.dart';
import 'package:recette/utils/result.dart';

import '../../../domain/models/ingredient/ingredient_types.dart';

class IngredientTypesRepository {
  IngredientTypesRepository({required DatabaseIngredientTypeService database})
    : _database = database;

  final DatabaseIngredientTypeService _database;

  final Map<int, IngredientTypes> _ingredientTypes = <int, IngredientTypes>{};

  Map<int, IngredientTypes> get ingredientTypes => _ingredientTypes;

  bool initialized = false;

  Future<Result<void>> loadIngredientTypes() async {
    try {
      var result = await _database.getAllIngredientTypes();
      for (var ingredientType in result) {
      _ingredientTypes[ingredientType.id!] = ingredientType;
      }
      return Result.ok(null);
    } on Exception {

      return Result.error(IngredientTypeRepositoryError('Could not add ingredient type'));
    }
  }
}

class IngredientTypeRepositoryError implements Exception {
  String cause;
  IngredientTypeRepositoryError(this.cause);
}
