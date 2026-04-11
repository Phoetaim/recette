import 'dart:async';

import 'package:recette/utils/result.dart';

import '../../../domain/models/ingredient/ingredient.dart';
import '../../../domain/models/ingredient/ingredient_types.dart';
import '../../services/database/database_ingredient.dart';
import 'ingredient_types_repository.dart';

class IngredientRepository {
  IngredientRepository({required DatabaseIngredientService database, required IngredientTypesRepository ingredientTypesRepository}) : _database = database, _ingredientTypesRepository = ingredientTypesRepository;

  final DatabaseIngredientService _database;
  final IngredientTypesRepository _ingredientTypesRepository;

  final List<Ingredient> _cachedIngredients = [];
  StreamController<Ingredient> newIngredient = StreamController.broadcast();
  StreamController<Ingredient> updateIngredientStream = StreamController.broadcast();

  Map<int, IngredientTypes> get ingredientTypes => _ingredientTypesRepository.ingredientTypes;
  bool initialized = false;

  Future<Result<Ingredient>> addIngredient(Ingredient ingredient) async {
    try {
      var result = await _database.insertIngredient(ingredient);
      _cachedIngredients.add(result);
      newIngredient.add(result);
      return Result.ok(result);
    } on Exception {
      return Result.error(IngredientRepositoryError('Could not add ingredient'));
    }
  }

  Future<Result<void>> updateIngredient(Ingredient ingredient) async {
    try {
      await _database.updateIngredient(ingredient);
      final index = _cachedIngredients.indexWhere((element) => element.id == ingredient.id);
      _cachedIngredients[index] = (ingredient);
      updateIngredientStream.add(ingredient);
      return Result.ok(null);
    } on Exception {
      return Result.error(IngredientRepositoryError('Could not update ingredient'));
    }
  }

  Future<Result<List<Ingredient>>> getIngredients() async {
    if (!initialized) {
      try {
        await _ingredientTypesRepository.loadIngredientTypes();
        var rawIngredients = await _database.getAllIngredients();
        _cachedIngredients.clear();
        for (var rawIngredient in rawIngredients) {
          Map<String, dynamic> ingredientJson = rawIngredient.toJson();
          ingredientJson['type'] = _ingredientTypesRepository.ingredientTypes[rawIngredient.type]!.toJson();
          Ingredient ingredient = Ingredient.fromJson(ingredientJson);
          _cachedIngredients.add(ingredient);
        }
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
