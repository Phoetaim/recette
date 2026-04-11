import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:sqflite/sqflite.dart';

import 'database.dart';

class DatabaseIngredientUnitsService {
  DatabaseIngredientUnitsService({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<IngredientUnit> insertIngredientUnit(
    IngredientUnit ingredientUnit,
  ) async {
    Database database = await _databaseService.getDatabase();
    final id = await database.insert(
      TableNames.ingredientUnits,
      ingredientUnit.toJson(),
    );
    return ingredientUnit.copyWith(id: id);
  }

  Future<void> updateIngredientType(IngredientUnit ingredientUnit) async {
    Database database = await _databaseService.getDatabase();
    await database.update(
      TableNames.ingredients,
      ingredientUnit.toJson(),
      where: 'id = ?',
      whereArgs: [ingredientUnit.id],
    );
  }

  Future<List<IngredientUnit>> getAllIngredientUnits() async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.query(TableNames.ingredientUnits);
    return entries.map((element) => IngredientUnit.fromJson(element)).toList();
  }

  Future<void> deleteIngredientType(int id) async {
    Database database = await _databaseService.getDatabase();
    final rowsDeleted = await database.delete(
      TableNames.ingredientUnits,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rowsDeleted == 0) {
      throw Exception('No ingredient type found with id $id');
    }
  }

  Future<void> close() async {
    await _databaseService.close();
  }
}
