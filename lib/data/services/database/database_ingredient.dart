import 'package:sqflite/sqflite.dart';

import '../../../domain/models/ingredient/ingredient.dart';
import '../models/raw_ingredient.dart';
import 'database.dart';


class DatabaseIngredientService {
  DatabaseIngredientService({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<Ingredient> insertIngredient(Ingredient ingredient) async {
    Database database = await _databaseService.getDatabase();
    final id = await database.insert(TableNames.ingredients, {
      'name': ingredient.name,
      'type': ingredient.type.id,
    });
    return ingredient.copyWith(id: id);
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    Database database = await _databaseService.getDatabase();
    await database.update(
      TableNames.ingredients,
      {'name': ingredient.name, 'type': ingredient.type.id},
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<List<RawIngredient>> getAllIngredients() async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.query(TableNames.ingredients);
    return entries.map((element) => RawIngredient.fromJson(element)).toList();
  }

  Future<void> deleteIngredient(int id) async {
    Database database = await _databaseService.getDatabase();
    final rowsDeleted = await database.delete(
      TableNames.ingredients,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rowsDeleted == 0) {
      throw Exception('No ingredient found with id $id');
    }
  }

  Future<void> close() async {
    await _databaseService.close();
  }
}
