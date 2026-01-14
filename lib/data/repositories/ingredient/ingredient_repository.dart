import 'package:recette/utils/result.dart';

import '../../../domain/models/ingredient/ingredient.dart';
import '../../services/database.dart';

class IngredientRepository {
  IngredientRepository({required DatabaseService database})
    : _database = database;

  final DatabaseService _database;

  final List<Ingredient> _cachedIngredients = [];

  bool initialized = false;

  Future<Result<Ingredient>> addIngredient(Ingredient ingredient) async {
    await _ensureDatabase();
    var result = await _database.insertIngredient(ingredient);
    switch (result) {
      case Ok<Ingredient>():
        _cachedIngredients.add(result.value);
        return Result.ok(result.value);
      case Error<Ingredient>():
        return Result.error(
          IngredientRepositoryError('Could not add ingredient'),
        );
    }
  }

  Future<Result<void>> updateIngredient(Ingredient ingredient) async {
    await _ensureDatabase();
    var result = await _database.updateIngredient(ingredient);
    switch (result) {
      case Ok<void>():
        _cachedIngredients.removeWhere(
          (element) => element.id == ingredient.id,
        );
        _cachedIngredients.add(ingredient);
        return Result.ok(null);
      case Error<void>():
        return Result.error(
          IngredientRepositoryError('Could not update ingredient'),
        );
    }
  }

  Future<Result<List<Ingredient>>> getIngredients() async {
    await _ensureDatabase();
    if (!initialized) {
      var result = await _database.getAllIngredients();
      switch (result) {
        case Ok<List<Ingredient>>():
          _cachedIngredients.clear();
          _cachedIngredients.addAll(result.value); // Add to cache
          initialized = true;
        case Error<List<Ingredient>>():
          return Result.error(
            IngredientRepositoryError('Could fetch ingredients'),
          );
      }
    }
    return Result.ok(_cachedIngredients);
  }

  Future<Result<Ingredient>> getIngredientById(int id) async {
    await _ensureDatabase();
    await getIngredients();
    try {
      Ingredient ingredient = _cachedIngredients.firstWhere(
            (ingredient) => ingredient.id == id,
      );
      return Result.ok(ingredient);
    } on StateError {
      return Result.error(IngredientRepositoryError('Could not find ingredient $id'));
    }
  }

  Future<Result<Ingredient>> getIngredientByName(String name) async {
    await _ensureDatabase();
    await getIngredients();
    try {
      Ingredient ingredient = _cachedIngredients.firstWhere(
            (ingredient) => ingredient.name == name,
      );
      return Result.ok(ingredient);
    } on StateError {
      return Result.error(IngredientRepositoryError('Could not find ingredient $name'));
    }
  }

  Future<Result<void>> removeIngredient(Ingredient ingredient) async {
    await _ensureDatabase();
    var result = await _database.deleteIngredient(ingredient.id!);
    switch (result) {
      case Ok<void>():
        _cachedIngredients.removeWhere((item) => item.id == ingredient.id);
        return Result.ok(null);
      case Error<void>():
        return Result.error(
          IngredientRepositoryError('Could not remove ingredient'),
        );
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
