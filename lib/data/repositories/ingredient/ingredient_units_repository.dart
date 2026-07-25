import 'dart:async';

import 'package:recette/data/services/database/database_ingredient_units.dart';
import 'package:recette/utils/result.dart';

import '../../../domain/models/ingredient/ingredient_units.dart';

class IngredientUnitsRepository {
  IngredientUnitsRepository({required DatabaseIngredientUnitsService database})
    : _database = database;

  final DatabaseIngredientUnitsService _database;

  final Map<int, IngredientUnit> _ingredientUnitsById = <int, IngredientUnit>{};
  final Map<String, IngredientUnit> _ingredientUnitsByName = <String, IngredientUnit>{};

  Map<int, IngredientUnit> get ingredientUnitsById => _ingredientUnitsById;
  Map<String, IngredientUnit> get ingredientUnitsByName => _ingredientUnitsByName;

  bool initialized = false;

  Future<Result<void>> loadIngredientUnits() async {
    if (initialized) {
      return Result.ok(null);
    }
    try {
      var result = await _database.getAllIngredientUnits();
      for (var ingredientUnit in result) {
      _ingredientUnitsById[ingredientUnit.id!] = ingredientUnit;
      _ingredientUnitsByName[ingredientUnit.name.toLowerCase()] = ingredientUnit;
      }
      initialized = true;
      return Result.ok(null);
    } on Exception {

      return Result.error(IngredientUnitRepositoryError('Could not add ingredient unit'));
    }
  }
}

class IngredientUnitRepositoryError implements Exception {
  String cause;
  IngredientUnitRepositoryError(this.cause);
}
