import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/ingredient/ingredient.dart';
import '../../utils/result.dart';
import 'models/ingredient_id_with_quantity.dart';

abstract final class TableNames {
  static const ingredients = 'ingredients';
  static const ingredientWithQuantity = 'ingredientWithQuantity';
}

class DatabaseService {

  DatabaseService({required this.databaseFactory});

  final DatabaseFactory databaseFactory;

  Database? _database;

  bool isOpen() => _database != null;


  Future<void> open() async {
    _database = await databaseFactory.openDatabase(
      join(await databaseFactory.getDatabasesPath(), 'app_database.db'),
      options: OpenDatabaseOptions(
        onCreate: (db, version) {
          db.execute(
            '''CREATE TABLE IF NOT EXIST ${TableNames.ingredients}(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT);'''
                '''CREATE TABLE  IF NOT EXIST ${TableNames.ingredientWithQuantity}(id INTEGER PRIMARY KEY AUTOINCREMENT, ingredientId int NOT NULL, unit TEXT, quantity int) FOREIGN KEY (ingredientId) REFERENCES ${TableNames.ingredients} (id)'''
          );
        },
        version: 1,
      ),
    );
  }


  Future<Result<Ingredient>> insertIngredient(Ingredient ingredient) async {
    try {
      final id = await _database!.insert(TableNames.ingredients, {
        'name': ingredient.name,
        'type': ingredient.type.name,
      });
      return Result.ok(ingredient.copyWith(id: id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }


  Future<Result<void>> updateIngredient(Ingredient ingredient) async {
    try {
      await _database!.update(TableNames.ingredients, {
        'name': ingredient.name,
        'type': ingredient.type.name,
      },
      where: 'id = ?',
      whereArgs: [ingredient.id],
      );
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<Ingredient>>> getAllIngredients() async {
    try {
      final entries = await _database!.query(
        TableNames.ingredients,
      );
      final list = entries
          .map(
            (element) => Ingredient.fromJson(element),
      )
          .toList();
      return Result.ok(list);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<Ingredient>>> getIngredientsByIds(List<int> ids) async {
    try {
     String placeholders = List.filled(ids.length, '?').join(',');
      final entries = await _database!.query(
        TableNames.ingredients,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final list = entries
          .map(
            (element) => Ingredient.fromJson(element),
      )
          .toList();
      return Result.ok(list);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> deleteIngredient(int id) async {
    try {
      final rowsDeleted = await _database!.delete(
        TableNames.ingredients,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rowsDeleted == 0) {
        return Result.error(Exception('No ingredient found with id $id'));
      }
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<IngredientIdWithQuantity>> insertIngredientIdWithQuantity(IngredientIdWithQuantity ingredientIdWithQuantity) async {
    try {
      final id = await _database!.insert(TableNames.ingredientWithQuantity, {
        'ingredientId': ingredientIdWithQuantity.ingredientId,
        'quantity': ingredientIdWithQuantity.quantity,
        'unit': ingredientIdWithQuantity.unit.name,
      });
      return Result.ok(ingredientIdWithQuantity.copyWith(id: id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }


  Future<Result<void>> updateIngredientIdWithQuantity(IngredientIdWithQuantity ingredientIdWithQuantity) async {
    try {
      await _database!.update(TableNames.ingredientWithQuantity, {
        'ingredientId': ingredientIdWithQuantity.ingredientId,
        'quantity': ingredientIdWithQuantity.quantity,
        'unit': ingredientIdWithQuantity.unit.name,
      },
        where: 'id = ?',
        whereArgs: [ingredientIdWithQuantity.id],
      );
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<IngredientIdWithQuantity>>> getAllIngredientsIdWithQuantity() async {
    try {
      final entries = await _database!.query(
        TableNames.ingredientWithQuantity,
      );
      final list = entries
          .map(
            (element) => IngredientIdWithQuantity.fromJson(element),
      )
          .toList();
      return Result.ok(list);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<IngredientIdWithQuantity>>> getIngredientIdsWithQuantityByIds(List<int> ids) async {
    try {
      String placeholders = List.filled(ids.length, '?').join(',');
      final entries = await _database!.query(
        TableNames.ingredientWithQuantity,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final list = entries
          .map(
            (element) => IngredientIdWithQuantity.fromJson(element),
      )
          .toList();
      return Result.ok(list);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> deleteIngredientIdWithQuantity(int id) async {
    try {
      final rowsDeleted = await _database!.delete(
        TableNames.ingredientWithQuantity,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rowsDeleted == 0) {
        return Result.error(Exception('No ingredientWithQuantity found with id $id'));
      }
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}