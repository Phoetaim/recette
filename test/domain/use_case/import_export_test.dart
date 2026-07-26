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
    test('copie un export complet et cohérent dans le presse-papier', () async {
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
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
          any(that: equals(<int>[10])),
        ),
      ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
      when(
        () => mockIngredientRepository.getIngredientById(100),
      ).thenAnswer((_) async => const Result.ok(ingredient));
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({3: ingredientType});
      when(() => mockIngredientUnitsRepository.ingredientUnitsById).thenReturn({5: ingredientUnit});

      await useCase.exportRecipes([recipe]);

      expect(clipboardArguments, isNotNull);
      final export = decodeClipboardExport();

      expect(export.rawRecipes, [recipe]);
      expect(export.rawIngredientsWithQuantity, [rawIngredientWithQuantity]);
      expect(export.rawIngredients, [const RawIngredient(id: 100, name: 'Carotte', type: 3)]);
      expect(export.ingredientTypes, [ingredientType]);
      expect(export.ingredientUnits, [ingredientUnit]);
      expect(export.isShoppingList, isFalse);
    });

    test('exporte 2 recettes avec le même ingredient', () async {
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

      await useCase.exportRecipes([recipeA, recipeB]);

      expect(clipboardArguments, isNotNull);
      final export = decodeClipboardExport();

      expect(export.rawRecipes, [recipeA, recipeB]);
      expect(export.rawIngredientsWithQuantity, [rawIngredientWithQuantity]);
      expect(export.rawIngredients, [const RawIngredient(id: 100, name: 'Carotte', type: 3)]);
      expect(export.ingredientTypes, [ingredientType]);
      expect(export.ingredientUnits, [ingredientUnit]);
      expect(export.isShoppingList, isFalse);
    });

    test('lève une ImportExportError si un ingrédient référencé n\'existe plus', () async {
      const recipe = RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]);
      const rawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 10,
        ingredientId: 100,
        unit: 5,
      );

      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
          any(that: equals(<int>[10])),
        ),
      ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
      when(
        () => mockIngredientRepository.getIngredientById(100),
      ).thenAnswer((_) async => Result.error(Exception('not found')));

      expect(() => useCase.exportRecipes([recipe]), throwsA(isA<ImportExportError>()));
    });

    test('exporte une liste de recettes vide sans planter', () async {
      when(
        () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
          any(that: equals(<int>[])),
        ),
      ).thenAnswer((_) async => const Result.ok(<RawIngredientWithQuantity>[]));
      // Accédé inconditionnellement par _getIngredientTypes même sans ingrédient.
      when(() => mockIngredientRepository.ingredientTypes).thenReturn({});

      await useCase.exportRecipes(const []);

      final export = decodeClipboardExport();
      expect(export.rawRecipes, isEmpty);
      expect(export.rawIngredients, isEmpty);
    });
  });

  group('importRecipes', () {
    test('lève une ImportExportError si la version du format est invalide', () async {
      const importData = ImportData(version: 1);
      final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

      expect(() => useCase.importRecipes(encoded), throwsA(isA<ImportExportError>()));
    });

    test(
      'crée un nouvel ingrédient, mappe unité/quantité et importe la recette avec les bons ids',
      () async {
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
        final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

        const importedType = IngredientTypes(id: 3, name: 'Légume', color: 123);
        const newIngredient = Ingredient(name: 'Carotte', type: importedType);
        const createdIngredient = Ingredient(id: 999, name: 'Carotte', type: importedType);

        // Pas trouvé par nom -> le use case doit le créer.
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

        await useCase.importRecipes(encoded);

        verify(
          () => mockRecipeRepository.addRecipe(
            const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [777]),
          ),
        ).called(1);
      },
    );

    test('réutilise un ingrédient existant trouvé par son nom (pas de création)', () async {
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
      final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

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

      await useCase.importRecipes(encoded);

      verifyNever(() => mockIngredientRepository.addIngredient(any()));
      verify(
        () => mockRecipeRepository.addRecipe(
          const RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [10]),
        ),
      ).called(1);
    });

    test('une unité inconnue lève ImportExportError', () async {
      const importData = ImportData(
        version: 0,
        ingredientUnits: [IngredientUnit(id: 5, name: 'dL')],
      );
      final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({});

      expect(() => useCase.importRecipes(encoded), throwsA(isA<ImportExportError>()));
    });
  });

  group('exportShoppingList', () {
    // La construction des rawIngredients/types/unités passe par le même
    // _getCommonImportData que exportRecipes, déjà testé en détail plus haut.
    // On ne re-teste ici que ce qui est spécifique à exportShoppingList :
    // le flag isShoppingList et l'absence de rawRecipes.
    test('marque isShoppingList à true et n\'inclut aucune recette', () async {
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
    test('lève une ImportExportError si la version du format est invalide', () async {
      const importData = ImportData(version: 1);
      final encoded = stringToBase64.encode(jsonEncode(importData.toJson()));

      expect(() => useCase.importShoppingList(encoded), throwsA(isA<ImportExportError>()));
    });

    test(
      'ajoute les ingrédients importés à la liste de courses quand isShoppingList=true',
      () async {
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
      },
    );

    test('n\'ajoute rien à la liste de courses quand isShoppingList=false, même avec des '
        'ingrédients dans l\'import', () async {
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

    test('lève une ImportExportError si au moins un ingrédient échoue à être ajouté', () async {
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
