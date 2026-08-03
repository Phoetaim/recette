import 'dart:io';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:recette/data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import 'package:recette/data/repositories/recipe/recipe_planning_repository.dart';
import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';
import 'package:recette/data/services/database/database_ingredient_units.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/repositories/ingredient/ingredient_repository.dart';
import '../data/repositories/ingredient/ingredient_types_repository.dart';
import '../data/repositories/ingredient/ingredient_units_repository.dart';
import '../data/repositories/recipe/recipe_repository.dart';
import '../data/services/database/database_ingredient.dart';
import '../data/services/database/database_ingredient_types.dart';
import '../data/services/database/database_ingredient_with_quantity.dart';
import '../data/services/database/database_recipe.dart';
import '../data/services/database/database_recipe_planning.dart';
import '../data/services/database/database_shopping_ingredient.dart';
import '../data/services/local_service.dart';
import '../data/services/database/database.dart';
import '../domain/use_cases/import_export.dart';

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
    Provider(create: (context) => DatabaseIngredientService(databaseService: context.read())),
    Provider(
      create: (context) => DatabaseIngredientWithQuantityService(databaseService: context.read()),
    ),
    Provider(
      create: (context) => DatabaseShoppingIngredientService(databaseService: context.read()),
    ),
    Provider(create: (context) => DatabaseRecipeService(databaseService: context.read())),
    Provider(create: (context) => DatabaseRecipePlanningService(databaseService: context.read())),
    Provider(create: (context) => DatabaseIngredientTypeService(databaseService: context.read())),
    Provider(create: (context) => DatabaseIngredientUnitsService(databaseService: context.read())),
    Provider(create: (context) => RecipeRepository(database: context.read())),
    Provider(create: (context) => RecipePlanningRepository(database: context.read())),
    Provider(create: (context) => IngredientTypesRepository(database: context.read())),
    Provider(
      create: (context) =>
          IngredientRepository(database: context.read(), ingredientTypesRepository: context.read()),
    ),
    Provider(create: (context) => IngredientUnitsRepository(database: context.read())),
    Provider(create: (context) => IngredientWithQuantityRepository(database: context.read())),
    Provider(
      create: (context) => IngredientWithQuantityUseCase(
        ingredientRepository: context.read(),
        ingredientWithQuantityRepository: context.read(),
        ingredientUnitsRepository: context.read(),
      ),
    ),
    Provider(
      create: (context) => ShoppingListRepository(
        shoppingDatabase: context.read(),
        ingredientWithQuantityUseCase: context.read(),
      ),
    ),
    Provider(
      create: (context) => ImportExportUseCase(
        ingredientRepository: context.read(),
        ingredientWithQuantityRepository: context.read(),
        ingredientUnitsRepository: context.read(),
        recipeRepository: context.read(),
        shoppingListRepository: context.read(),
      ),
    ),
  ];
}
