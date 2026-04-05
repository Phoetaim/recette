import 'package:sqflite/sqflite.dart';

import '../models/raw_recipe.dart';
import 'database.dart';

class DatabaseRecipeService {
  DatabaseRecipeService({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<RawRecipe> insertRecipe(RawRecipe rawRecipe) async {
    Database database = await _databaseService.getDatabase();
    Map<String, Object?> data = Map<String, Object?>.from(rawRecipe.toJson());
    data.remove('id');
    data.remove('ingredientWithQuantityIds');
    final List<int> ingredientWithQuantityIds = rawRecipe.ingredientWithQuantityIds;
    final id = await database.insert(TableNames.recipes, data);
    final batch = database.batch();
    // Add ingredients ids to link table
    for (var ingredientWithQuantityId in ingredientWithQuantityIds) {
      batch.insert(TableNames.recipesIngredientsWithQuantity, {
        'recipeId': id,
        'ingredientWithQuantityId': ingredientWithQuantityId,
      });
    }
    batch.apply();
    return rawRecipe.copyWith(id: id);
  }

  Future<void> updateRecipe(RawRecipe rawRecipe) async {
    Database database = await _databaseService.getDatabase();
    Map<String, Object> data = Map<String, Object>.from(rawRecipe.toJson());
    data.remove('id');
    data.remove('ingredientWithQuantityIds');
    await database.update(
      TableNames.recipes,
      data,
      where: 'id = ?',
      whereArgs: [rawRecipe.id!],
    );
    final entries = await database.query(TableNames.recipesIngredientsWithQuantity,
      where: 'recipeId = ?',
      whereArgs: [rawRecipe.id!],
    );
    final List<int> oldIngredientWithQuantityIds = entries
        .map((element) => element['ingredientWithQuantityId'] as int)
        .toList();

    for (var oldIngredientWithQuantityId in oldIngredientWithQuantityIds) {
      if (!rawRecipe.ingredientWithQuantityIds.contains(oldIngredientWithQuantityId)) {
        await database.delete(
          TableNames.ingredientWithQuantity,
          where: 'id = ?',
          whereArgs: [oldIngredientWithQuantityId],
        );
      }
    }

    for (var newIngredientWithQuantityId in rawRecipe.ingredientWithQuantityIds) {
      if (!oldIngredientWithQuantityIds.contains(newIngredientWithQuantityId)) {
        await database.insert(TableNames.recipesIngredientsWithQuantity, {
          'recipeId': rawRecipe.id!,
          'ingredientWithQuantityId': newIngredientWithQuantityId,
        });
      }
    }
  }

  Future<List<RawRecipe>> getRecipeList() async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.query(TableNames.recipes);
    return entries.map((element) => RawRecipe.fromJson(element)).toList();
  }

  Future<RawRecipe> getRecipeById(int id) async {
    Database database = await _databaseService.getDatabase();
    final recipeJsonRO = await database.query(TableNames.recipes,
      where: 'id = ?',
      whereArgs: [id],
    );
    final Map<String, Object?> recipeJson = Map<String, dynamic>.from(recipeJsonRO.first);
    List<Map> entries = await database.query(TableNames.recipesIngredientsWithQuantity,
      where: 'recipeId = ?',
      whereArgs: [id],
    );
    final List<Object?> ingredientWithQuantityIds = entries.map((element) => element['ingredientWithQuantityId']).toList();
    recipeJson['ingredientWithQuantityIds'] = ingredientWithQuantityIds;
    return RawRecipe.fromJson(recipeJson);
  }

  Future<void> deleteRecipe(int id) async {
    Database database = await _databaseService.getDatabase();
    await database.delete(TableNames.recipes,
      where: 'id = ?',
      whereArgs: [id],
    );
    final entries = await database.query(TableNames.recipesIngredientsWithQuantity,
      where: 'recipeId = ?',
      whereArgs: [id],
    );
    final List<Object?> ingredientWithQuantityIds = entries.map((element) => element['ingredientWithQuantityId']).toList();
    await database.delete(TableNames.ingredientWithQuantity,
      where: 'id in (${List.filled(ingredientWithQuantityIds.length, '?').join(',')})',
      whereArgs: ingredientWithQuantityIds,
    );
  }

  Future<void> close() async {
    await _databaseService.close();
  }
}
