import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/ingredient/ingredient.dart';
import '../../utils/result.dart';

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
          return db.execute(
            'CREATE TABLE ${TableNames.ingredients}(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT)',
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
        'type': ingredient.type,
      });
      return Result.ok(ingredient.copyWith(id: id));
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
      final entries = await _database!.query(
        TableNames.ingredients,
        where: 'id IN ?',
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

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}