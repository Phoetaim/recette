import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String databaseDirectory = 'migrations';

final List<String> databaseFilesV1 = [
  '$databaseDirectory/1/ingredient_types.sql',
  '$databaseDirectory/1/ingredient_units.sql',
  '$databaseDirectory/1/ingredients.sql',
  '$databaseDirectory/1/ingredient_with_quantity.sql',
  '$databaseDirectory/1/shopping_ingredient.sql',
  '$databaseDirectory/1/recipe.sql',
  '$databaseDirectory/1/recipe_ingredient_with_quantity.sql',
];

abstract final class TableNames {
  static const ingredientTypes = 'ingredientTypes';
  static const ingredientUnits = 'ingredientUnits';
  static const ingredients = 'ingredients';
  static const ingredientWithQuantity = 'ingredientWithQuantity';
  static const shoppingIngredient = 'shoppingIngredient';
  static const recipes = 'recipes';
  static const recipesIngredientsWithQuantity =
      'recipesIngredientsWithQuantity';
}

class DatabaseService {
  DatabaseService({required this.databaseFactory});

  final DatabaseFactory databaseFactory;

  Database? _database;

  Future<Database> getDatabase() async {
    if (_database == null) {
      await open();
    }
    return _database!;
  }

  Future<void> open() async {
    try {
      // await databaseFactory.deleteDatabase(join( await databaseFactory.getDatabasesPath(), 'app_database.db'));
      _database = await databaseFactory.openDatabase(
        join(await databaseFactory.getDatabasesPath(), 'app_database.db'),
        options: OpenDatabaseOptions(
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          version: 1,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  void _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    if (version == 1) {
      for (String file in databaseFilesV1) {
        await executeFromFile(db, file);
      }
    }
  }

  Future<void> executeFromFile(Database db, String file) async {
    String sqlScript = await rootBundle.loadString(file);
    final batch = db.batch();
    final statements = sqlScript.split(';').where((s) => s.trim().isNotEmpty);
    for (String query in statements) {
      batch.execute(query);
    }
    batch.commit();
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
