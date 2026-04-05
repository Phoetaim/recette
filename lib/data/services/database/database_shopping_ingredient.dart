import 'package:sqflite/sqflite.dart';

import '../models/raw_shopping_ingredient.dart';
import 'database.dart';

class DatabaseShoppingIngredientService {
  DatabaseShoppingIngredientService({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<RawShoppingIngredient> insertShoppingIngredient(
    RawShoppingIngredient rawShoppingIngredient,
  ) async {
    Database database = await _databaseService.getDatabase();
    Map<String, Object?> data = Map<String, Object?>.from(rawShoppingIngredient.toJson());
    data.remove('id');
    final id = await database.insert(TableNames.shoppingIngredient, data);
    return rawShoppingIngredient.copyWith(id: id);
  }

  Future<void> updateShoppingIngredient(RawShoppingIngredient rawShoppingIngredient) async {
    Database database = await _databaseService.getDatabase();
    Map<String, Object> data = Map<String, Object>.from(rawShoppingIngredient.toJson());
    data.remove('id');
    await database.update(
      TableNames.shoppingIngredient,
      data,
      where: 'id = ?',
      whereArgs: [rawShoppingIngredient.id],
    );
  }

  Future<List<RawShoppingIngredient>> getAllShoppingIngredients() async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.query(TableNames.shoppingIngredient);
    return entries.map((element) => RawShoppingIngredient.fromJson(element)).toList();
  }

  Future<void> updateShoppingIngredientStatus(int id) async {
    Database database = await _databaseService.getDatabase();
    final rowsUpdated = await database.update(
      TableNames.shoppingIngredient,
      {'bought': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rowsUpdated == 0) {
      throw Exception('No shopping ingredient found with id $id');
    }
  }

  Future<void> deleteShoppingIngredient(int id) async {
    Database database = await _databaseService.getDatabase();
    await database.rawDelete(
      'DELETE from ${TableNames.ingredientWithQuantity} as I WHERE I.id = (SELECT ingredientWithQuantityId from ${TableNames.shoppingIngredient} where id = ?) ',
      [id],
    );
  }

  Future<void> broughtAllShoppingIngredients() async {
    Database database = await _databaseService.getDatabase();
    await database.update(
      TableNames.shoppingIngredient,
      {'bought': 1},
      where: 'bought = ?',
      whereArgs: [0],
    );
  }

  Future<void> emptyBoughtShoppingList() async {
    Database database = await _databaseService.getDatabase();
    await database.delete(TableNames.shoppingIngredient, where: 'bought = ?', whereArgs: [1]);
  }

  Future<void> close() async {
    await _databaseService.close();
  }
}
