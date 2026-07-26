// test/domain/use_cases/ingredient_with_quantity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';
import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:recette/utils/result.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockIngredientWithQuantityRepository extends Mock
    implements IngredientWithQuantityRepository {}

class MockIngredientUnitsRepository extends Mock implements IngredientUnitsRepository {}

void main() {
  late MockIngredientRepository mockIngredientRepository;
  late MockIngredientWithQuantityRepository mockIngredientWithQuantityRepository;
  late MockIngredientUnitsRepository mockIngredientUnitsRepository;
  late IngredientWithQuantityUseCase useCase;

  setUpAll(() {
    // Fallbacks requis par mocktail pour tout argument passé via any()/captureAny().
    registerFallbackValue(<int>[]);
    registerFallbackValue(const RawIngredientWithQuantity(ingredientId: 0));
    registerFallbackValue(const Ingredient(name: 'fallback'));
  });

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
    mockIngredientWithQuantityRepository = MockIngredientWithQuantityRepository();
    mockIngredientUnitsRepository = MockIngredientUnitsRepository();

    useCase = IngredientWithQuantityUseCase(
      ingredientRepository: mockIngredientRepository,
      ingredientWithQuantityRepository: mockIngredientWithQuantityRepository,
      ingredientUnitsRepository: mockIngredientUnitsRepository,
    );
  });

  group('getIngredientWithQuantityByIds', () {
    setUp(() {
      // Toujours appelé en premier par la méthode, quel que soit le scénario.
      when(
            () => mockIngredientUnitsRepository.loadIngredientUnits(),
      ).thenAnswer((_) async => const Result.ok(null));
    });

    test(
      'construit une Map complète et valable par ingrédient, avec unité et ingrédient résolus',
          () async {
        const rawIngredientWithQuantity = RawIngredientWithQuantity(
          id: 10,
          ingredientId: 100,
          unit: 5,
          quantity: 2,
        );
        const ingredientType = IngredientTypes(id: 3, name: 'Légume', color: 123);
        const ingredient = Ingredient(id: 100, name: 'Carotte', type: ingredientType);
        const unit = IngredientUnit(id: 5, name: 'kg');
        const ingredientWithQuantity = IngredientWithQuantity(ingredient: ingredient, unit: unit, quantity: 2);

        when(
              () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
            any(that: equals(<int>[10])),
          ),
        ).thenAnswer((_) async => const Result.ok([rawIngredientWithQuantity]));
        when(
              () => mockIngredientRepository.getIngredientById(100),
        ).thenAnswer((_) async => const Result.ok(ingredient));
        when(() => mockIngredientUnitsRepository.ingredientUnitsById).thenReturn({5: unit});

        final result = await useCase.getIngredientWithQuantityByIds([10]);

        expect(result, isA<Ok<List<Map<String, dynamic>>>>());
        final maps = (result as Ok<List<Map<String, dynamic>>>).value;
        expect(maps, [
          {
            'id': 10,
            'ingredientId': 100,
            'unit': {'id': 5, 'name': 'kg'},
            'quantity': 2,
            'ingredient': {
              'id': 100,
              'name': 'Carotte',
              'type': {'id': 3, 'name': 'Légume', 'color': 123},
            },
          },
        ]);

        expect(ingredientWithQuantitiesFromJson(maps), [ingredientWithQuantity]);
      },
    );

    test(
      'retourne une erreur si la récupération de la liste échoue, sans '
          'interroger les ingrédients',
          () async {
        when(
              () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
            any(that: equals(<int>[10])),
          ),
        ).thenAnswer((_) async => Result.error(Exception('db error')));

        final result = await useCase.getIngredientWithQuantityByIds([10]);

        expect(result, isA<Error<List<Map<String, dynamic>>>>());
        verifyNever(() => mockIngredientRepository.getIngredientById(any()));
      },
    );

    test(
      's\'arrête au premier ingrédient introuvable sans traiter les suivants',
          () async {
        const rawA = RawIngredientWithQuantity(id: 10, ingredientId: 100, unit: 5, quantity: 1);
        const rawB = RawIngredientWithQuantity(id: 11, ingredientId: 200, unit: 5, quantity: 1);

        when(
              () => mockIngredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
            any(that: equals(<int>[10, 11])),
          ),
        ).thenAnswer((_) async => const Result.ok([rawA, rawB]));
        when(
              () => mockIngredientRepository.getIngredientById(100),
        ).thenAnswer((_) async => Result.error(Exception('introuvable')));

        final result = await useCase.getIngredientWithQuantityByIds([10, 11]);

        expect(result, isA<Error<List<Map<String, dynamic>>>>());
        // Le 2e ingrédient n'est jamais interrogé : la boucle s'arrête à la 1ère erreur.
        verifyNever(() => mockIngredientRepository.getIngredientById(200));
      },
    );
  });

  group('addIngredientWithQuantity', () {
    test(
      'ajoute directement la quantité quand l\'ingrédient existe déjà (pas de création)',
          () async {
        const existingIngredient = Ingredient(id: 42, name: 'Carotte');
        const unit = IngredientUnit(id: 5, name: 'kg');
        const input = IngredientWithQuantity(
          ingredient: existingIngredient,
          unit: unit,
          quantity: 3,
        );
        const savedRaw = RawIngredientWithQuantity(id: 77, ingredientId: 42, unit: 5, quantity: 3);

        when(
              () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(
            const RawIngredientWithQuantity(ingredientId: 42, unit: 5, quantity: 3),
          ),
        ).thenAnswer((_) async => const Result.ok(savedRaw));

        final result = await useCase.addIngredientWithQuantity(input);

        verifyNever(() => mockIngredientRepository.addIngredient(any()));
        expect(result, isA<Ok<IngredientWithQuantity>>());
        final value = (result as Ok<IngredientWithQuantity>).value;
        expect(value.id, 77);
        expect(value.ingredient, existingIngredient);
      },
    );

    test(
      'crée l\'ingrédient au préalable quand il n\'a pas encore d\'id, puis ajoute la quantité',
          () async {
        const newIngredient = Ingredient(name: 'Nouveau');
        const createdIngredient = Ingredient(id: 99, name: 'Nouveau');
        const unit = IngredientUnit(id: 5, name: 'kg');
        const input = IngredientWithQuantity(ingredient: newIngredient, unit: unit, quantity: 1);
        const savedRaw = RawIngredientWithQuantity(id: 55, ingredientId: 99, unit: 5, quantity: 1);

        when(
              () => mockIngredientRepository.addIngredient(newIngredient),
        ).thenAnswer((_) async => const Result.ok(createdIngredient));
        when(
              () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(
            const RawIngredientWithQuantity(ingredientId: 99, unit: 5, quantity: 1),
          ),
        ).thenAnswer((_) async => const Result.ok(savedRaw));

        final result = await useCase.addIngredientWithQuantity(input);

        expect(result, isA<Ok<IngredientWithQuantity>>());
        final value = (result as Ok<IngredientWithQuantity>).value;
        expect(value.id, 55);
        expect(value.ingredient, createdIngredient);
      },
    );

    test('propage l\'erreur si la création de l\'ingrédient échoue', () async {
      const newIngredient = Ingredient(name: 'Nouveau');
      const unit = IngredientUnit(id: 5, name: 'kg');
      const input = IngredientWithQuantity(ingredient: newIngredient, unit: unit, quantity: 1);

      when(
            () => mockIngredientRepository.addIngredient(newIngredient),
      ).thenAnswer((_) async => Result.error(IngredientRepositoryError('boom')));

      final result = await useCase.addIngredientWithQuantity(input);

      expect(result, isA<Error<IngredientWithQuantity>>());
      verifyNever(
            () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(any()),
      );
    });

    test('propage l\'erreur si l\'ajout de la quantité échoue', () async {
      const existingIngredient = Ingredient(id: 42, name: 'Carotte');
      const unit = IngredientUnit(id: 5, name: 'kg');
      const input = IngredientWithQuantity(
        ingredient: existingIngredient,
        unit: unit,
        quantity: 3,
      );

      when(
            () => mockIngredientWithQuantityRepository.addRawIngredientWithQuantity(
          const RawIngredientWithQuantity(ingredientId: 42, unit: 5, quantity: 3),
        ),
      ).thenAnswer((_) async => Result.error(Exception('db error')));

      final result = await useCase.addIngredientWithQuantity(input);

      expect(result, isA<Error<IngredientWithQuantity>>());
    });
  });

  group('updateIngredientWithQuantity', () {
    test('délègue directement au repository et retourne son résultat', () async {
      const rawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 1,
        ingredientId: 2,
        unit: 3,
        quantity: 4,
      );
      when(
            () => mockIngredientWithQuantityRepository.updateRawIngredientWithQuantity(
          rawIngredientWithQuantity,
        ),
      ).thenAnswer((_) async => const Result.ok(null));

      final result = await useCase.updateIngredientWithQuantity(rawIngredientWithQuantity);

      expect(result, isA<Ok<void>>());
      verify(
            () => mockIngredientWithQuantityRepository.updateRawIngredientWithQuantity(
          rawIngredientWithQuantity,
        ),
      ).called(1);
    });

    test('propage l\'erreur renvoyée par le repository', () async {
      const rawIngredientWithQuantity = RawIngredientWithQuantity(
        id: 1,
        ingredientId: 2,
        unit: 3,
        quantity: 4,
      );
      when(
            () => mockIngredientWithQuantityRepository.updateRawIngredientWithQuantity(
          rawIngredientWithQuantity,
        ),
      ).thenAnswer((_) async => Result.error(Exception('fail')));

      final result = await useCase.updateIngredientWithQuantity(rawIngredientWithQuantity);

      expect(result, isA<Error<void>>());
    });
  });
}