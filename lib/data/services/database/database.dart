import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String databaseDirectory = 'migrations';

final Map<int, List<String>> databaseFiles = <int, List<String>>{
  1: [
    'ingredient_types.sql',
    'ingredient_units.sql',
    'ingredients.sql',
    'ingredient_with_quantity.sql',
    'shopping_ingredient.sql',
    'recipe.sql',
    'recipe_ingredient_with_quantity.sql',
  ],
  2: [
    'add_hygiene_type.sql',
  ]
};

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
      _database = await databaseFactory.openDatabase(
        join(await databaseFactory.getDatabasesPath(), 'app_database.db'),
        options: OpenDatabaseOptions(
          onConfigure: _onConfigure,
          onUpgrade: _onUpgrade,
          version: 2,
        ),
      );
  }

  void _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var version = 1; version <= newVersion; version++) {
      if (oldVersion >= version) {
        continue; // Skip version if already applied
      }
      for (String file in databaseFiles[version]!) {
        await executeFromFile(db, '$databaseDirectory/$version/$file');
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
