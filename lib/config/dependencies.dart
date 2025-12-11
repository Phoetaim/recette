import 'dart:io';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/repositories/ingredient/ingredient_repository.dart';
import '../data/repositories/recipe/recipe_repository.dart';
import '../data/services/local_service.dart';
import '../data/services/database.dart';

List<SingleChildWidget> get providersLocal {
  late DatabaseService databaseService;
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Initialize FFI SQLite
    sqfliteFfiInit();
    databaseService = DatabaseService(databaseFactory: databaseFactoryFfi);
  } else {
    // Use default native SQLite
    databaseService = DatabaseService(databaseFactory: databaseFactory);
  }
  return [
    Provider.value(value: LocalDataService()),
    Provider.value(value: databaseService),
    Provider.value(value: DatabaseService(databaseFactory: databaseFactory)),
    Provider(create: (context) => RecipeRepository(localDataService: context.read())),
    Provider(create: (context) => IngredientRepository(database: context.read())),
    Provider(create: (context) => ShoppingListRepository()),
  ];
}
