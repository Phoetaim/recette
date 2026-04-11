import 'package:sqflite/sqflite.dart';

import '../models/raw_ingredient_with_quantity.dart';
import 'database.dart';

class DatabaseIngredientWithQuantityService {
  DatabaseIngredientWithQuantityService({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<RawIngredientWithQuantity> insertIngredientIdWithQuantity(
    RawIngredientWithQuantity rawIngredientIdWithQuantity,
  ) async {
    Database database = await _databaseService.getDatabase();
    final id = await database.insert(TableNames.ingredientWithQuantity, {
      'ingredientId': rawIngredientIdWithQuantity.ingredientId,
      'quantity': rawIngredientIdWithQuantity.quantity,
      'unit': rawIngredientIdWithQuantity.unit,
    });
    return rawIngredientIdWithQuantity.copyWith(id: id);
  }

  Future<void> updateIngredientWithQuantity(
    RawIngredientWithQuantity rawIngredientIdWithQuantity,
  ) async {
    Database database = await _databaseService.getDatabase();
    await database.update(
      TableNames.ingredientWithQuantity,
      {
        'ingredientId': rawIngredientIdWithQuantity.ingredientId,
        'quantity': rawIngredientIdWithQuantity.quantity,
        'unit': rawIngredientIdWithQuantity.unit,
      },
      where: 'id = ?',
      whereArgs: [rawIngredientIdWithQuantity.id],
    );
  }

  Future<List<RawIngredientWithQuantity>>
  getAllIngredientsIdWithQuantity() async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.query(TableNames.ingredientWithQuantity);
    return entries
        .map((element) => RawIngredientWithQuantity.fromJson(element))
        .toList();
  }

  Future<List<RawIngredientWithQuantity>> getIngredientIdsWithQuantityByIds(
    List<int> ids,
  ) async {
    Database database = await _databaseService.getDatabase();
    String placeholders = List.filled(ids.length, '?').join(',');
    final entries = await database.query(
      TableNames.ingredientWithQuantity,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return entries
        .map((element) => RawIngredientWithQuantity.fromJson(element))
        .toList();
  }

  Future<void> deleteIngredientIdWithQuantity(int id) async {
    Database database = await _databaseService.getDatabase();
    final rowsDeleted = await database.delete(
      TableNames.ingredientWithQuantity,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rowsDeleted == 0) {
      throw Exception('No ingredientWithQuantity found with id $id');
    }
  }

  Future<void> close() async {
    await _databaseService.close();
  }
}
