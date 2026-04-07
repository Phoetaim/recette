import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
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

  Future<RawShoppingIngredient> getShoppingIngredientById(int id) async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.query(TableNames.shoppingIngredient,
    where: 'id = ?',
    whereArgs: [id]);
    return RawShoppingIngredient.fromJson(entries.first);
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

  Future<DuplicateShoppingIngredientResult?> checkIngredientAlreadyInShoppingList(int ingredientId, String unit) async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.rawQuery('''
    SELECT S.id as shoppingIngredientId, I.id, I.ingredientId, I.unit, I.quantity
    FROM shoppingIngredient AS S 
      LEFT JOIN ingredientWithQuantity AS I
    WHERE S.bought = 0
      AND S.ingredientWithQuantityId = I.id
      AND I.ingredientId = ?
      AND I.unit = ?
    ''', [ingredientId, unit]);
    if (entries.isEmpty){
      return null;
    } else {
      final entry = entries.first;
      return DuplicateShoppingIngredientResult(rawIngredientWithQuantity: RawIngredientWithQuantity.fromJson(entry), shoppingIngredientId: entry['shoppingIngredientId'] as int);
    }
  }

  Future<void> close() async {
    await _databaseService.close();
  }
}

class DuplicateShoppingIngredientResult {
  final RawIngredientWithQuantity rawIngredientWithQuantity;
  final int shoppingIngredientId;
  DuplicateShoppingIngredientResult({required this.rawIngredientWithQuantity, required this.shoppingIngredientId, });
}