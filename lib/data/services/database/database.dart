import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract final class TableNames {
  static const ingredients = 'ingredients';
  static const ingredientWithQuantity = 'ingredientWithQuantity';
  static const shoppingIngredient = 'shoppingIngredient';
  static const recipes = 'recipes';
  static const recipesIngredientsWithQuantity = 'recipesIngredientsWithQuantity';
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

  void _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> open() async {
    try {
      // await databaseFactory.deleteDatabase(join( await databaseFactory.getDatabasesPath(), 'app_database.db'));
      _database = await databaseFactory.openDatabase(
        join(await databaseFactory.getDatabasesPath(), 'app_database.db'),
        options: OpenDatabaseOptions(
          onConfigure: _onConfigure,
          onCreate: (db, version) {
            db.execute('''
                CREATE TABLE ${TableNames.ingredients}(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT NOT NULL,
                  type TEXT
                 );
                 ''');
            db.execute('''
                CREATE TABLE ${TableNames.ingredientWithQuantity}(
                   id INTEGER PRIMARY KEY AUTOINCREMENT,
                   ingredientId int NOT NULL,
                   unit TEXT,
                   quantity int,
                   FOREIGN KEY (ingredientId) REFERENCES ${TableNames.ingredients} (id) ON DELETE CASCADE)
                ''');
            db.execute('''
                CREATE TABLE ${TableNames.shoppingIngredient}(
                   id INTEGER PRIMARY KEY AUTOINCREMENT,
                   ingredientWithQuantityId int NOT NULL,
                   shoppingListId  int,
                   bought BOOL,
                   FOREIGN KEY (ingredientWithQuantityId) REFERENCES ${TableNames.ingredientWithQuantity} (id) ON DELETE CASCADE)
                ''');
            db.execute('''
                CREATE TABLE ${TableNames.recipes}(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT,
                  preparationTime TEXT,
                  cookingTime TEXT,
                  nbOfPeople INTEGER,
                  steps TEXT
                 )
            ''');
            db.execute('''
                CREATE TABLE ${TableNames.recipesIngredientsWithQuantity}(
                  recipeId INTEGER,
                  ingredientWithQuantityId INTEGER,
                  PRIMARY KEY (recipeId, ingredientWithQuantityId),
                  FOREIGN KEY (recipeId) REFERENCES ${TableNames.recipes}(id) ON DELETE CASCADE,
                  FOREIGN KEY (ingredientWithQuantityId) REFERENCES ${TableNames.ingredientWithQuantity}(id) ON DELETE CASCADE
                )
            ''');
          },
          version: 1,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
