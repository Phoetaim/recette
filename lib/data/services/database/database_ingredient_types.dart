import 'package:sqflite/sqflite.dart';

import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'database.dart';

class DatabaseIngredientTypeService {
  DatabaseIngredientTypeService({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<IngredientTypes> insertIngredientType(IngredientTypes ingredientType) async {
    Database database = await _databaseService.getDatabase();
    final id = await database.insert(TableNames.ingredientTypes, ingredientType.toJson());
    return ingredientType.copyWith(id: id);
  }

  Future<void> updateIngredientType(IngredientTypes ingredientType) async {
    Database database = await _databaseService.getDatabase();
    await database.update(
      TableNames.ingredients,
      ingredientType.toJson(),
      where: 'id = ?',
      whereArgs: [ingredientType.id],
    );
  }

  Future<List<IngredientTypes>> getAllIngredientTypes() async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.query(TableNames.ingredientTypes);
    return entries.map((element) => IngredientTypes.fromJson(element)).toList();
  }

  Future<void> deleteIngredientType(int id) async {
    Database database = await _databaseService.getDatabase();
    final rowsDeleted = await database.delete(
      TableNames.ingredientTypes,
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
