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
import 'package:recette/data/services/file_picker_service.dart';
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

class MockIngredientWithQuantityRepository extends Mock implements IngredientWithQuantityRepository {}

class MockIngredientUnitsRepository extends Mock implements IngredientUnitsRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockShoppingListRepository extends Mock implements ShoppingListRepository {}

class MockFilePickerService extends Mock implements FilePickerService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockIngredientRepository mockIngredientRepository;
  late MockIngredientWithQuantityRepository mockIngredientWithQuantityRepository;
  late MockIngredientUnitsRepository mockIngredientUnitsRepository;
  late MockRecipeRepository mockRecipeRepository;
  late MockShoppingListRepository mockShoppingListRepository;
  late MockFilePickerService mockFilePickerService;
  late ImportExportUseCase useCase;

  Map<Object?, Object?>? clipboardArguments;

  setUpAll(() {
    registerFallbackValue(<int>[]);
    registerFallbackValue(const RawRecipe());
    registerFallbackValue(const RawIngredientWithQuantity(ingredientId: 1));
    registerFallbackValue(const Ingredient(name: 'fallback'));
    registerFallbackValue(const IngredientWithQuantity(ingredient: Ingredient(name: 'fallback')));
  });

  setUp(() {
    mockFilePickerService = MockFilePickerService();

    when(
      () => mockFilePickerService.saveFile(
        dialogTitle: any(named: 'dialogTitle'),
        fileName: any(named: 'fileName'),
        content: any(named: 'content'),
      ),
    ).thenThrow(Exception('File picker unavailable in tests'));

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
      filePickerService: mockFilePickerService,
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
    final jsonString = clipboardArguments!['text'] as String;
    return ImportData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  group('exportRecipes', () {
    test('Export of full export and pasted in copy-paste', () async {
      const recipe = RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]);
      const rawIngredientWithQuantity = RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2);
      const ingredientType = IngredientTypes(id: 3, name: 'Légume', color: 123);
      const ingredient = Ingredient(id: 100, name: 'Carotte', type: ingredientType);
      const ingredientUnit = IngredientUnit(id: 5, name: 'dL');

      when(
        () => mockRecipeRepository.getRecipe(any(that: equals(recipe.id))),
      ).thenAnswer((_) async => const Result.ok(recipe));
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(any(that: equals(<int>[10]))),
      ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
      when(() => mockIngredientRepository.getIngredientById(100)).thenAnswer((_) async => const Result.ok(ingredient));
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
      const rawIngredientWithQuantity = RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2);
      const ingredientType = IngredientTypes(id: 3, name: 'Légume', color: 123);
      const ingredient = Ingredient(id: 100, name: 'Carotte', type: ingredientType);
      const ingredientUnit = IngredientUnit(id: 5, name: 'dL');

      final answers = [Result.ok(recipeA), Result.ok(recipeB)];
      when(() => mockRecipeRepository.getRecipe(any())).thenAnswer((_) async => answers.removeAt(0));
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(any(that: equals(<int>[10]))),
      ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
      when(() => mockIngredientRepository.getIngredientById(100)).thenAnswer((_) async => const Result.ok(ingredient));
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
      const rawIngredientWithQuantity = RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5);
      when(
        () => mockRecipeRepository.getRecipe(any(that: equals(recipe.id))),
      ).thenAnswer((_) async => const Result.ok(recipe));
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(any(that: equals(<int>[10]))),
      ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
      when(
        () => mockIngredientRepository.getIngredientById(100),
      ).thenAnswer((_) async => Result.error(Exception('not found')));

      expect(() => useCase.exportRecipes({recipe.id!}), throwsA(isA<ImportExportError>()));
    });

    test('Export empty recipe list does not crash the app', () async {
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(any(that: equals(<int>[]))),
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
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
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
      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({'dl': existingUnit});

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
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(mappedRawIngredientWithQuantity),
      ).thenAnswer((_) async => const Result.ok(savedRawIngredientWithQuantity));

      when(() => mockRecipeRepository.addRecipe(any())).thenAnswer((_) async => const Result.ok(RawRecipe(id: 1)));

      await useCase.importRecipes(importData, {1});

      verify(
        () => mockRecipeRepository.addRecipe(const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [777])),
      ).called(1);
    });

    test('import only selected recipe and ingredients', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
          RawRecipe(id: 2, name: 'Soupe2', ingredientWithQuantityIds: [11]),
        ],
        rawIngredientsWithQuantity: [
          RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2),
          RawIngredientWithQuantity(id: 11, ingredientId: 101, unit: 5, quantity: 2),
        ],
        rawIngredients: [
          RawIngredient(id: 100, name: 'Carotte', type: 3),
          RawIngredient(id: 101, name: 'Carotte2', type: 3),
        ],

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
      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({'dl': existingUnit});

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
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(mappedRawIngredientWithQuantity),
      ).thenAnswer((_) async => const Result.ok(savedRawIngredientWithQuantity));

      when(
        () => mockRecipeRepository.addRecipe(const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [777])),
      ).thenAnswer((_) async => const Result.ok(RawRecipe(id: 1)));

      await useCase.importRecipes(importData, {1});

      // Only the selected recipe is imported...
      verify(
        () => mockRecipeRepository.addRecipe(const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [777])),
      ).called(1);
      // ...and addRecipe is never called a second time for the excluded recipe.
      verifyNever(() => mockRecipeRepository.addRecipe(any()));

      // The excluded recipe's ingredient is filtered out before import: it's
      // never looked up, created, nor added as an ingredientWithQuantity.
      verifyNever(() => mockIngredientRepository.getIngredientByName('Carotte2'));
      verifyNever(() => mockIngredientRepository.addIngredient(const Ingredient(name: 'Carotte2', type: importedType)));
      verifyNever(
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(
          const RawIngredientWithQuantity(id: 11, ingredientId: 999, unit: 55, quantity: 2),
        ),
      );
    });

    test('Reuse already existing ingredient in export (does not reate a new one)', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
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
      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({'dl': existingUnit});

      const mappedRawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 10,
        ingredientId: 42,
        unit: 55,
        quantity: 2,
      );
      when(
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(mappedRawIngredientWithQuantity),
      ).thenAnswer((_) async => const Result.ok(mappedRawIngredientWithQuantity));

      when(() => mockRecipeRepository.addRecipe(any())).thenAnswer((_) async => const Result.ok(RawRecipe(id: 1)));

      await useCase.importRecipes(importData, {1});

      verifyNever(() => mockIngredientRepository.addIngredient(any()));
      verify(
        () => mockRecipeRepository.addRecipe(const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10])),
      ).called(1);
    });

    test('Throws an ImportExportError on unknown unit', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
      );

      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({});

      expect(() => useCase.importRecipes(importData, const {1}), throwsA(isA<ImportExportError>()));
    });

    test('Throws an ImportExportError if creating a new ingredient fails', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );

      const importedType = IngredientTypes(id: 3, name: 'Légume', color: 123);
      const newIngredient = Ingredient(name: 'Carotte', type: importedType);

      // Ingredient not found -> must be created, but creation fails.
      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => Result.error(Exception('not found')));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({});
      when(
        () => mockIngredientRepository.addIngredient(newIngredient),
      ).thenAnswer((_) async => Result.error(Exception('db error')));

      expect(() => useCase.importRecipes(importData, {1}), throwsA(isA<ImportExportError>()));
    });

    test('Throws an ImportExportError if adding an ingredientWithQuantity fails', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
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
      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({'dl': existingUnit});

      when(
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(any()),
      ).thenAnswer((_) async => Result.error(Exception('db error')));

      expect(() => useCase.importRecipes(importData, {1}), throwsA(isA<ImportExportError>()));
    });

    test('Reuses an existing local ingredient type with the same name when creating an ingredient', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );

      // A type with the same name already exists locally, under a
      // different id/color. It should be reused instead of the imported one.
      const localExistingType = IngredientTypes(id: 7, name: 'Légume', color: 999);
      const newIngredientWithLocalType = Ingredient(name: 'Carotte', type: localExistingType);
      const createdIngredient = Ingredient(id: 999, name: 'Carotte', type: localExistingType);

      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => Result.error(Exception('not found')));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({7: localExistingType});
      when(
        () => mockIngredientRepository.addIngredient(newIngredientWithLocalType),
      ).thenAnswer((_) async => const Result.ok(createdIngredient));

      const existingUnit = IngredientUnit(id: 55, name: 'dL');
      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({'dl': existingUnit});

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
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(mappedRawIngredientWithQuantity),
      ).thenAnswer((_) async => const Result.ok(savedRawIngredientWithQuantity));

      when(() => mockRecipeRepository.addRecipe(any())).thenAnswer((_) async => const Result.ok(RawRecipe(id: 1)));

      await useCase.importRecipes(importData, {1});

      // The ingredient is created with the reused local type (id 7), not
      // the imported one (id 3).
      verify(() => mockIngredientRepository.addIngredient(newIngredientWithLocalType)).called(1);
    });

    test('Importing an empty ImportData does nothing', () async {
      const importData = ImportData(version: 0);

      await useCase.importRecipes(importData, const {1});

      verifyNever(() => mockIngredientRepository.getIngredientByName(any()));
      verifyNever(() => mockIngredientRepository.addIngredient(any()));
      verifyNever(() => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(any()));
      verifyNever(() => mockRecipeRepository.addRecipe(any()));
    });

    test('Importing with a recipeIds set matching no recipe does nothing', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );

      await useCase.importRecipes(importData, const {999});

      verifyNever(() => mockIngredientRepository.getIngredientByName(any()));
      verifyNever(() => mockIngredientRepository.addIngredient(any()));
      verifyNever(() => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(any()));
      verifyNever(() => mockRecipeRepository.addRecipe(any()));
    });

    test('Imports a recipe with multiple ingredientsWithQuantity correctly', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10, 11]),
        ],
        rawIngredientsWithQuantity: [
          RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2),
          RawIngredientWithQuantity(id: 11, ingredientId: 101, unit: 5, quantity: 3),
        ],
        rawIngredients: [
          RawIngredient(id: 100, name: 'Carotte', type: 3),
          RawIngredient(id: 101, name: 'Poireau', type: 3),
        ],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );

      const carotte = Ingredient(
        id: 42,
        name: 'Carotte',
        type: IngredientTypes(id: 3, name: 'Légume', color: 123),
      );
      const poireau = Ingredient(
        id: 43,
        name: 'Poireau',
        type: IngredientTypes(id: 3, name: 'Légume', color: 123),
      );
      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => const Result.ok(carotte));
      when(
        () => mockIngredientRepository.getIngredientByName('Poireau'),
      ).thenAnswer((_) async => const Result.ok(poireau));

      const existingUnit = IngredientUnit(id: 55, name: 'dL');
      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({'dl': existingUnit});

      const mappedCarotteQuantity = RawIngredientWithQuantity(id: 10, ingredientId: 42, unit: 55, quantity: 2);
      const savedCarotteQuantity = RawIngredientWithQuantity(id: 201, ingredientId: 42, unit: 55, quantity: 2);
      const mappedPoireauQuantity = RawIngredientWithQuantity(id: 11, ingredientId: 43, unit: 55, quantity: 3);
      const savedPoireauQuantity = RawIngredientWithQuantity(id: 202, ingredientId: 43, unit: 55, quantity: 3);

      when(
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(mappedCarotteQuantity),
      ).thenAnswer((_) async => const Result.ok(savedCarotteQuantity));
      when(
        () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(mappedPoireauQuantity),
      ).thenAnswer((_) async => const Result.ok(savedPoireauQuantity));

      when(() => mockRecipeRepository.addRecipe(any())).thenAnswer((_) async => const Result.ok(RawRecipe(id: 1)));

      await useCase.importRecipes(importData, {1});

      verify(
        () => mockRecipeRepository.addRecipe(
          const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [201, 202]),
        ),
      ).called(1);
    });
  });

  group('loadImportData', () {
    test('Returns an ImportExportError if the user cancels the picker', () async {
      when(
        () => mockFilePickerService.pickFile(dialogTitle: 'Fichier d\'import', allowedExtensions: ['json']),
      ).thenAnswer((_) async => null);

      final result = await useCase.loadImportData();

      expect(result, isA<Error<ImportData>>());
    });

    test('Returns an ImportExportError if the version is invalid', () async {
      const importData = ImportData(version: 1);
      final encoded = jsonEncode(importData.toJson());
      when(
        () => mockFilePickerService.pickFile(dialogTitle: 'Fichier d\'import', allowedExtensions: ['json']),
      ).thenAnswer((_) async => encoded);

      final result = await useCase.loadImportData();

      expect(result, isA<Error<ImportData>>());
    });

    test('Correctly decodes a valid encoded ImportData', () async {
      const importData = ImportData(
        version: 0,
        rawRecipes: [
          RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ],
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );
      final encoded = jsonEncode(importData.toJson());
      when(
        () => mockFilePickerService.pickFile(dialogTitle: 'Fichier d\'import', allowedExtensions: ['json']),
      ).thenAnswer((_) async => encoded);

      final result = await useCase.loadImportData();

      expect(result, isA<Ok<ImportData>>());
      expect((result as Ok<ImportData>).value, importData);
    });

    test('Correctly decodes an encoded shopping list ImportData', () async {
      const importData = ImportData(
        version: 0,
        isShoppingList: true,
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );
      final encoded = jsonEncode(importData.toJson());
      when(
        () => mockFilePickerService.pickFile(dialogTitle: 'Fichier d\'import', allowedExtensions: ['json']),
      ).thenAnswer((_) async => encoded);

      final result = await useCase.loadImportData();

      final value = (result as Ok<ImportData>).value;
      expect(value.isShoppingList, isTrue);
      expect(value.rawRecipes, isEmpty);
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
        ingredientWithQuantity: IngredientWithQuantity(id: 10, ingredient: Ingredient(name: 'Carotte'), quantity: 2),
      );

      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(any(that: equals(<int>[10]))),
      ).thenAnswer((_) async => const Result.ok(<RawIngredientWithQuantity>[]));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({});

      await useCase.exportShoppingList([shoppingIngredient]);

      final export = decodeClipboardExport();
      expect(export.isShoppingList, isTrue);
      expect(export.rawRecipes, isEmpty);
    });
  });

  group('importShoppingList', () {
    test('Returns an error if the version is invalid', () async {
      const importData = ImportData(version: 1);
      final encoded = jsonEncode(importData.toJson());
      when(
        () => mockFilePickerService.pickFile(dialogTitle: 'Fichier d\'import', allowedExtensions: ['json']),
      ).thenAnswer((_) async => encoded);

      final result = await useCase.importShoppingList();

      expect(result, isA<Error<void>>());
    });

    test('Correctly import shopping list if isShoppingList == true', () async {
      const importData = ImportData(
        version: 0,
        isShoppingList: true,
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );
      final encoded = jsonEncode(importData.toJson());
      when(
        () => mockFilePickerService.pickFile(dialogTitle: 'Fichier d\'import', allowedExtensions: ['json']),
      ).thenAnswer((_) async => encoded);

      const existingIngredient = Ingredient(
        id: 42,
        name: 'Carotte',
        type: IngredientTypes(id: 3, name: 'Légume', color: 123),
      );
      when(
        () => mockIngredientRepository.getIngredientByName('Carotte'),
      ).thenAnswer((_) async => const Result.ok(existingIngredient));

      const existingUnit = IngredientUnit(id: 55, name: 'dL');
      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({'dl': existingUnit});

      when(
        () => mockShoppingListRepository.addShoppingIngredient(any()),
      ).thenAnswer((_) async => const Result.ok(null));

      final result = await useCase.importShoppingList();

      expect(result, isA<Ok<void>>());
      verify(
        () => mockShoppingListRepository.addShoppingIngredient(
          const IngredientWithQuantity(ingredient: existingIngredient, unit: existingUnit, quantity: 2),
        ),
      ).called(1);
    });

    test('Do not add anything to shopping list is isShoppingList == false', () async {
      const importData = ImportData(
        version: 0,
        isShoppingList: false,
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );
      final encoded = jsonEncode(importData.toJson());
      when(
        () => mockFilePickerService.pickFile(dialogTitle: 'Fichier d\'import', allowedExtensions: ['json']),
      ).thenAnswer((_) async => encoded);

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

      await useCase.importShoppingList();

      verifyNever(() => mockShoppingListRepository.addShoppingIngredient(any()));
    });

    test('Returns an error if adding an ingredient fails', () async {
      const importData = ImportData(
        version: 0,
        isShoppingList: true,
        rawIngredientsWithQuantity: [RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 2)],
        rawIngredients: [RawIngredient(id: 100, name: 'Carotte', type: 3)],
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
        ingredientTypes: [IngredientTypes(id: 3, name: 'Légume', color: 123)],
      );
      final encoded = jsonEncode(importData.toJson());
      when(
        () => mockFilePickerService.pickFile(dialogTitle: 'Fichier d\'import', allowedExtensions: ['json']),
      ).thenAnswer((_) async => encoded);

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

      final result = await useCase.importShoppingList();

      expect(result, isA<Error<void>>());
    });
  });
}
