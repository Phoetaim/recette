// test/domain/use_cases/import_export_test.dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';
import 'package:recette/data/services/models/import_data.dart';
import 'package:recette/data/services/models/raw_ingredient.dart';
import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/shopping_list/shopping_ingredient.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/utils/result.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockIngredientWithQuantityRepository extends Mock
    implements IngredientWithQuantityRepository {}

class MockIngredientUnitsRepository extends Mock implements IngredientUnitsRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockShoppingListRepository extends Mock implements ShoppingListRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockIngredientRepository mockIngredientRepository;
  late MockIngredientWithQuantityRepository mockIngredientWithQuantityRepository;
  late MockIngredientUnitsRepository mockIngredientUnitsRepository;
  late MockRecipeRepository mockRecipeRepository;
  late MockShoppingListRepository mockShoppingListRepository;
  late ImportExportUseCase useCase;

  Map<Object?, Object?>? clipboardArguments;

  setUpAll(() {
    // Fallbacks requis par mocktail pour tout argument passé via any()/captureAny().
    registerFallbackValue(<int>[]);
    registerFallbackValue(const RawRecipe());
    registerFallbackValue(const Ingredient(name: 'fallback'));
    registerFallbackValue(const IngredientWithQuantity(ingredient: Ingredient(name: 'fallback')));
  });

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
    mockIngredientWithQuantityRepository = MockIngredientWithQuantityRepository();
    mockIngredientUnitsRepository = MockIngredientUnitsRepository();
    mockRecipeRepository = MockRecipeRepository();
    mockShoppingListRepository = MockShoppingListRepository();

    useCase = ImportExportUseCase(
      ingredientRepository: mockIngredientRepository,
      ingredientWithQuantityRepository: mockIngredientWithQuantityRepository,
      ingredientUnitsRepository: mockIngredientUnitsRepository,
      recipeRepository: mockRecipeRepository,
      shoppingListRepository: mockShoppingListRepository,
    );

    clipboardArguments = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardArguments = call.arguments as Map<Object?, Object?>;
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  ImportData decodeClipboardExport() {
    final encoded = clipboardArguments!['text'] as String;
    final jsonString = stringToBase64.decode(encoded);
    return ImportData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  group('exportRecipes', () {
    test('Export of full export and pasted in copy-paste', () async {
      const recipe = RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]);
      const rawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 10,
        ingredientId: 100,
        unit: 5,
        quantity: 2,
      );
      const ingredientType = IngredientTypes(id: 3, name: 'Légume', color: 123);
      const ingredient = Ingredient(id: 100, name: 'Carotte', type: ingredientType);
      const ingredientUnit = IngredientUnit(id: 5, name: 'dL');

      when(
        () => mockRecipeRepository.getRecipe(any(that: equals(recipe.id))),
      ).thenAnswer((_) async => const Result.ok(recipe));
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
          any(that: equals(<int>[10])),
        ),
      ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
      when(
        () => mockIngredientRepository.getIngredientById(100),
      ).thenAnswer((_) async => const Result.ok(ingredient));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({3: ingredientType});
      when(() => mockIngredientUnitsRepository.ingredientUnitsById).thenReturn({5: ingredientUnit});

      await useCase.exportRecipes({recipe.id!});

      expect(clipboardArguments, isNotNull);
      final export = decodeClipboardExport();

      expect(export.rawRecipes, [recipe]);
      expect(export.rawIngredientsWithQuantity, [rawIngredientWithQuantity]);
      expect(export.rawIngredients, [const RawIngredient(id: 100, name: 'Carotte', type: 3)]);
      expect(export.ingredientTypes, [ingredientType]);
      expect(export.ingredientUnits, [ingredientUnit]);
      expect(export.isShoppingList, isFalse);
    });

    test('Export 2 recipes with the same ingredient', () async {
      const recipeA = RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]);
      const recipeB = RawRecipe(id: 2, name: 'Grosse soupe', ingredientWithQuantityIds: [10]);
      const rawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 10,
        ingredientId: 100,
        unit: 5,
        quantity: 2,
      );
      const ingredientType = IngredientTypes(id: 3, name: 'Légume', color: 123);
      const ingredient = Ingredient(id: 100, name: 'Carotte', type: ingredientType);
      const ingredientUnit = IngredientUnit(id: 5, name: 'dL');

      final answers = [Result.ok(recipeA), Result.ok(recipeB)];
      when(
        () => mockRecipeRepository.getRecipe(any()),
      ).thenAnswer((_) async => answers.removeAt(0));
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
          any(that: equals(<int>[10])),
        ),
      ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
      when(
        () => mockIngredientRepository.getIngredientById(100),
      ).thenAnswer((_) async => const Result.ok(ingredient));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({3: ingredientType});
      when(() => mockIngredientUnitsRepository.ingredientUnitsById).thenReturn({5: ingredientUnit});

      await useCase.exportRecipes({recipeA.id!, recipeB.id!});

      expect(clipboardArguments, isNotNull);
      final export = decodeClipboardExport();

      expect(export.rawRecipes, [recipeA, recipeB]);
      expect(export.rawIngredientsWithQuantity, [rawIngredientWithQuantity]);
      expect(export.rawIngredients, [const RawIngredient(id: 100, name: 'Carotte', type: 3)]);
      expect(export.ingredientTypes, [ingredientType]);
      expect(export.ingredientUnits, [ingredientUnit]);
      expect(export.isShoppingList, isFalse);
    });

    test('Throws an ImportExportError if one recipe fails to be retrieved', () async {
      const recipe = RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]);
      when(
        () => mockRecipeRepository.getRecipe(any(that: equals(recipe.id))),
      ).thenAnswer((_) async => Result.error(Exception('not found')));

      expect(() => useCase.exportRecipes({recipe.id!}), throwsA(isA<ImportExportError>()));
    });

    test('Throws an ImportExportError if an ingredient does not exists', () async {
      const recipe = RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]);
      const rawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 10,
        ingredientId: 100,
        unit: 5,
      );
      when(
        () => mockRecipeRepository.getRecipe(any(that: equals(recipe.id))),
      ).thenAnswer((_) async => const Result.ok(recipe));
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
          any(that: equals(<int>[10])),
        ),
      ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
      when(
        () => mockIngredientRepository.getIngredientById(100),
      ).thenAnswer((_) async => Result.error(Exception('not found')));

      expect(() => useCase.exportRecipes({recipe.id!}), throwsA(isA<ImportExportError>()));
    });

    test('Export empty recipe list does not crash the app', () async {
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
          any(that: equals(<int>[])),
        ),
      ).thenAnswer((_) async => const Result.ok(<RawIngredientWithQuantity>[]));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({});

      await useCase.exportRecipes(const {});

      final export = decodeClipboardExport();
      expect(export.rawRecipes, isEmpty);
      expect(export.rawIngredients, isEmpty);
    });
  });

  group('importRecipes', () {
    test('Throws an ImportExportError if invalid version', () async {
      const importData = ImportData(version: 1);

      expect(() => useCase.importRecipes(importData, const {}), throwsA(isA<ImportExportError>()));
    });

    test('Correctly import recipe, ingredients, units and types', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [
          RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2),
        ],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );

      const importedType = IngredientTypes(id: 3, name: 'Légume', color: 123);
      const newIngredient = Ingredient(name: 'Carotte', type: importedType);
      const createdIngredient = Ingredient(id: 999, name: 'Carotte', type: importedType);

      // Ingredient not found -> must be created
      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => Result.error(Exception('not found')));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({});
      when(
        () => mockIngredientRepository.addIngredient(newIngredient),
      ).thenAnswer((_) async => const Result.ok(createdIngredient));

      const existingUnit = IngredientUnit(id: 55, name: 'dL');
      when(
        () => mockIngredientUnitsRepository.ingredientUnitsByName,
      ).thenReturn({'dl': existingUnit});

      const mappedRawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 10,
        ingredientId: 999,
        unit: 55,
        quantity: 2,
      );
      const savedRawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 777,
        ingredientId: 999,
        unit: 55,
        quantity: 2,
      );
      when(
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(
          mappedRawIngredientWithQuantity,
        ),
      ).thenAnswer((_) async => const Result.ok(savedRawIngredientWithQuantity));

      when(
        () => mockRecipeRepository.addRecipe(any()),
      ).thenAnswer((_) async => const Result.ok(RawRecipe(id: 1)));

      await useCase.importRecipes(importData, {1});

      verify(
        () => mockRecipeRepository.addRecipe(
          const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [777]),
        ),
      ).called(1);
    });

    test('Reuse already existing ingredient in export (does not reate a new one)', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [
          RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2),
        ],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );

      const existingIngredient = Ingredient(
        id: 42,
        name: 'Carotte',
        type: IngredientTypes(id: 3, name: 'Légume', color: 123),
      );
      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => const Result.ok(existingIngredient));

      const existingUnit = IngredientUnit(id: 55, name: 'dL');
      when(
        () => mockIngredientUnitsRepository.ingredientUnitsByName,
      ).thenReturn({'dl': existingUnit});

      const mappedRawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 10,
        ingredientId: 42,
        unit: 55,
        quantity: 2,
      );
      when(
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(
          mappedRawIngredientWithQuantity,
        ),
      ).thenAnswer((_) async => const Result.ok(mappedRawIngredientWithQuantity));

      when(
        () => mockRecipeRepository.addRecipe(any()),
      ).thenAnswer((_) async => const Result.ok(RawRecipe(id: 1)));

      await useCase.importRecipes(importData, {1});

      verifyNever(() => mockIngredientRepository.addIngredient(any()));
      verify(
        () => mockRecipeRepository.addRecipe(
          const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ),
      ).called(1);
    });

    test('Throws an ImportExportError on unknown unit', () async {
      const importData = ImportData(
        version: 0,
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
      );

      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({});

      expect(() => useCase.importRecipes(importData, const {}), throwsA(isA<ImportExportError>()));
    });
  });

  group('exportShoppingList', () {
    // La construction des rawIngredients/types/unités passe par le même
    // _getCommonImportData que exportRecipes, déjà testé en détail plus haut.
    // On ne re-teste ici que ce qui est spécifique à exportShoppingList :
    // le flag isShoppingList et l'absence de rawRecipes.
    test('Correctly export shopping list (isShoppingList == true)', () async {
      const shoppingIngredient = ShoppingIngredient(
        id: 1,
        ingredientWithQuantity: IngredientWithQuantity(
          id: 10,
          ingredient: Ingredient(name: 'Carotte'),
          quantity: 2,
        ),
      );

      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
          any(that: equals(<int>[10])),
        ),
      ).thenAnswer((_) async => const Result.ok(<RawIngredientWithQuantity>[]));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({});

      await useCase.exportShoppingList([shoppingIngredient]);

      final export = decodeClipboardExport();
      expect(export.isShoppingList, isTrue);
      expect(export.rawRecipes, isEmpty);
    });
  });

  group('importShoppingList', () {
    test('Throws an ImportExportError if the version is invalid', () async {
      const importData = ImportData(version: 1);
      final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

      expect(() => useCase.importShoppingList(encoded), throwsA(isA<ImportExportError>()));
    });

    test('Correctly import shopping list if isShoppingList == true', () async {
      const importData = ImportData(
        version: 0,
        isShoppingList: true,
        rawIngredientsWithQuantity: [
          RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2),
        ],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );
      final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

      // On réutilise le cas "ingrédient déjà existant" (moins de setup que
      // le cas création, déjà couvert par les tests de importRecipes).
      const existingIngredient = Ingredient(
        id: 42,
        name: 'Carotte',
        type: IngredientTypes(id: 3, name: 'Légume', color: 123),
      );
      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => const Result.ok(existingIngredient));

      const existingUnit = IngredientUnit(id: 55, name: 'dL');
      when(
        () => mockIngredientUnitsRepository.ingredientUnitsByName,
      ).thenReturn({'dl': existingUnit});

      when(
        () => mockShoppingListRepository.addShoppingIngredient(any()),
      ).thenAnswer((_) async => const Result.ok(null));

      await useCase.importShoppingList(encoded);

      verify(
        () => mockShoppingListRepository.addShoppingIngredient(
          const IngredientWithQuantity(
            ingredient: existingIngredient,
            unit: existingUnit,
            quantity: 2,
          ),
        ),
      ).called(1);
    });

    test('Do not add anything to shopping list is isShoppingList == false', () async {
      const importData = ImportData(
        version: 0,
        isShoppingList: false,
        rawIngredientsWithQuantity: [
          RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2),
        ],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );
      final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

      const existingIngredient = Ingredient(
        id: 42,
        name: 'Carotte',
        type: IngredientTypes(id: 3, name: 'Légume', color: 123),
      );
      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => const Result.ok(existingIngredient));
      when(
        () => mockIngredientUnitsRepository.ingredientUnitsByName,
      ).thenReturn({'dl': const IngredientUnit(id: 55, name: 'dL')});

      await useCase.importShoppingList(encoded);

      verifyNever(() => mockShoppingListRepository.addShoppingIngredient(any()));
    });

    test('Throws an ImportExportError if adding an ingredient fails', () async {
      const importData = ImportData(
        version: 0,
        isShoppingList: true,
        rawIngredientsWithQuantity: [
          RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2),
        ],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );
      final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

      const existingIngredient = Ingredient(
        id: 42,
        name: 'Carotte',
        type: IngredientTypes(id: 3, name: 'Légume', color: 123),
      );
      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => const Result.ok(existingIngredient));
      when(
        () => mockIngredientUnitsRepository.ingredientUnitsByName,
      ).thenReturn({'dl': const IngredientUnit(id: 55, name: 'dL')});
      when(
        () => mockShoppingListRepository.addShoppingIngredient(any()),
      ).thenAnswer((_) async => Result.error(Exception('db error')));

      expect(() => useCase.importShoppingList(encoded), throwsA(isA<ImportExportError>()));
    });
  });
}
