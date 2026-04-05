import 'package:recette/utils/result.dart';

import '../../../domain/models/ingredient/ingredient.dart';
import '../../services/database/database_ingredient.dart';

class IngredientRepository {
  IngredientRepository({required DatabaseIngredientService database}) : _database = database;

  final DatabaseIngredientService _database;

  final List<Ingredient> _cachedIngredients = [];

  bool initialized = false;

  Future<Result<Ingredient>> addIngredient(Ingredient ingredient) async {
    try {
      var result = await _database.insertIngredient(ingredient);
      _cachedIngredients.add(result);
      return Result.ok(result);
    } on Exception {
      return Result.error(IngredientRepositoryError('Could not add ingredient'));
    }
  }

  Future<Result<void>> updateIngredient(Ingredient ingredient) async {
    try {
      await _database.updateIngredient(ingredient);
      _cachedIngredients.removeWhere((element) => element.id == ingredient.id);
      _cachedIngredients.add(ingredient);
      return Result.ok(null);
    } on Exception {
      return Result.error(IngredientRepositoryError('Could not update ingredient'));
    }
  }

  Future<Result<List<Ingredient>>> getIngredients() async {
    if (!initialized) {
      try {
        var result = await _database.getAllIngredients();

        _cachedIngredients.clear();
        _cachedIngredients.addAll(result); // Add to cache
        initialized = true;
      } on Exception {
        return Result.error(IngredientRepositoryError('Could fetch ingredients'));
      }
    }
    return Result.ok(_cachedIngredients);
  }

  Future<Result<Ingredient>> getIngredientById(int id) async {
    await getIngredients();
    try {
      Ingredient ingredient = _cachedIngredients.firstWhere((ingredient) => ingredient.id == id);
      return Result.ok(ingredient);
    } on StateError {
      return Result.error(IngredientRepositoryError('Could not find ingredient $id'));
    }
  }

  Future<Result<Ingredient>> getIngredientByName(String name) async {
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
    try {
      await _database.deleteIngredient(ingredient.id!);
      _cachedIngredients.removeWhere((item) => item.id == ingredient.id);
      return Result.ok(null);
    } on Exception {
      return Result.error(IngredientRepositoryError('Could not remove ingredient'));
    }
  }
}

class IngredientRepositoryError implements Exception {
  String cause;
  IngredientRepositoryError(this.cause);
}
