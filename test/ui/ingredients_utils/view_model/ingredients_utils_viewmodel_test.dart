// test/ui/ingredients_utils/view_model/ingredients_utils_viewmodel_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/ui/ingredients_utils/view_model/ingredients_utils_viewmodel.dart';
import 'package:recette/utils/result.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockIngredientUnitsRepository extends Mock implements IngredientUnitsRepository {}

const ingredientType = IngredientTypes(id: 3, name: 'Légume', color: 123);
const carotte = Ingredient(id: 1, name: 'carotte', type: ingredientType);
const panais = Ingredient(id: 2, name: 'panais', type: ingredientType);
const kgUnit = IngredientUnit(id: 10, name: 'kg');
const gUnit = IngredientUnit(id: 11, name: 'g');

/// Laisse le temps aux Futures/microtasks en attente (ex: le chargement
/// déclenché dans le constructeur du viewmodel) de se résoudre.
Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  late MockIngredientRepository mockIngredientRepository;
  late MockIngredientUnitsRepository mockIngredientUnitsRepository;
  late StreamController<Ingredient> newIngredientController;
  late StreamController<Ingredient> updateIngredientController;
  late StreamController<Ingredient> deleteIngredientController;

  setUpAll(() {
    registerFallbackValue(const Ingredient(name: 'fallback'));
  });

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
    mockIngredientUnitsRepository = MockIngredientUnitsRepository();
    newIngredientController = StreamController<Ingredient>.broadcast();
    updateIngredientController = StreamController<Ingredient>.broadcast();
    deleteIngredientController = StreamController<Ingredient>.broadcast();

    when(
          () => mockIngredientRepository.newIngredientStream,
    ).thenReturn(newIngredientController);
    when(
          () => mockIngredientRepository.updateIngredientStream,
    ).thenReturn(updateIngredientController);
    when(
          () => mockIngredientRepository.deleteIngredientStream,
    ).thenReturn(deleteIngredientController);
  });

  tearDown(() async {
    await newIngredientController.close();
    await updateIngredientController.close();
    await deleteIngredientController.close();
  });

  IngredientsUtilsViewModel createViewModel({bool withUnitsRepository = true}) {
    return IngredientsUtilsViewModel(
      ingredientRepository: mockIngredientRepository,
      ingredientUnitsRepository: withUnitsRepository ? mockIngredientUnitsRepository : null,
    );
  }

  /// Stub commun pour un chargement réussi.
  void stubSuccessfulLoad({
    List<Ingredient> ingredients = const [],
    Map<String, IngredientUnit> unitsByName = const {},
  }) {
    when(
          () => mockIngredientUnitsRepository.loadIngredientUnits(),
    ).thenAnswer((_) async => const Result.ok(null));
    when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn(unitsByName);
    when(
          () => mockIngredientRepository.getIngredients(),
    ).thenAnswer((_) async => Result.ok(ingredients));
  }

  group('Loading ingredients', () {
    test('loads ingredients successfully', () async {
      stubSuccessfulLoad(ingredients: [carotte, panais]);

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.loadIngredients.completed, isTrue);
      expect(viewModel.loadIngredients.error, isFalse);
      expect(viewModel.filterIngredients(null), [carotte, panais]);
    });

    test('reports an error when fetching ingredients fails', () async {
      when(
            () => mockIngredientUnitsRepository.loadIngredientUnits(),
      ).thenAnswer((_) async => const Result.ok(null));
      when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({});
      when(() => mockIngredientRepository.getIngredients()).thenAnswer(
            (_) async => Result.error(IngredientRepositoryError('db error')),
      );

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.loadIngredients.error, isTrue);
    });

    test('still loads ingredients when no IngredientUnitsRepository is provided', () async {
      when(
            () => mockIngredientRepository.getIngredients(),
      ).thenAnswer((_) async => const Result.ok([]));

      final viewModel = createViewModel(withUnitsRepository: false);
      await flushMicrotasks();

      expect(viewModel.loadIngredients.completed, isTrue);
    });

    test(
      'throws when calling handleSearch without an IngredientUnitsRepository, '
          'because the search regex is only built when units are loaded',
          () async {
        when(
              () => mockIngredientRepository.getIngredients(),
        ).thenAnswer((_) async => const Result.ok([]));

        final viewModel = createViewModel(withUnitsRepository: false);
        await flushMicrotasks();

        expect(() => viewModel.handleSearch('carotte'), throwsA(isA<IngredientSearchError>()));
      },
    );
  });

  group('ingredientTypes', () {
    test('delegates to the repository\'s ingredientTypes map', () async {
      stubSuccessfulLoad(ingredients: []);
      when(
            () => mockIngredientRepository.ingredientTypes,
      ).thenReturn({3: ingredientType});

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.ingredientTypes, [ingredientType]);
    });
  });

  group('Reacting to ingredient repository streams', () {
    test('adds a new ingredient pushed on newIngredientStream to the local cache', () async {
      stubSuccessfulLoad(ingredients: [carotte]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      newIngredientController.add(panais);
      await flushMicrotasks();

      expect(viewModel.filterIngredients(null), [carotte, panais]);
    });

    test('does not add a duplicate when the exact same ingredient is pushed twice', () async {
      stubSuccessfulLoad(ingredients: [carotte]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      newIngredientController.add(carotte);
      await flushMicrotasks();

      expect(viewModel.filterIngredients(null), [carotte]);
    });

    test('updates a cached ingredient when updateIngredientStream fires', () async {
      stubSuccessfulLoad(ingredients: [carotte]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      const renamedCarotte = Ingredient(id: 1, name: 'carotte bio', type: ingredientType);
      updateIngredientController.add(renamedCarotte);
      await flushMicrotasks();

      expect(viewModel.filterIngredients(null), [renamedCarotte]);
    });

    test(
      'bumps updatedIngredient only when the updated ingredient is part of the '
          'current filtered search results',
          () async {
        stubSuccessfulLoad(ingredients: [carotte]);
        final viewModel = createViewModel();
        await flushMicrotasks();
        viewModel.handleSearch(''); // populates _filteredIngredients with [carotte]

        expect(viewModel.updatedIngredient.value, 0);

        const renamedCarotte = Ingredient(id: 1, name: 'carotte bio', type: ingredientType);
        updateIngredientController.add(renamedCarotte);
        await flushMicrotasks();

        expect(viewModel.updatedIngredient.value, 1);
      },
    );

    test(
      'removes an ingredient and notifies listeners when deleteIngredientStream fires',
          () async {
        stubSuccessfulLoad(ingredients: [carotte, panais]);
        final viewModel = createViewModel();
        await flushMicrotasks();
        viewModel.filterIngredients(null);

        var notified = false;
        viewModel.addListener(() => notified = true);

        deleteIngredientController.add(carotte);
        await flushMicrotasks();

        expect(viewModel.filterIngredients(null), [panais]);
        expect(notified, isTrue);
      },
    );
  });

  group('updateIngredient command', () {
    test('updates an existing ingredient in the repository and the local cache', () async {
      stubSuccessfulLoad(ingredients: [carotte]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      const updatedCarotte = Ingredient(id: 1, name: 'carotte bio', type: ingredientType);
      when(
            () => mockIngredientRepository.updateIngredient(updatedCarotte),
      ).thenAnswer((_) async => const Result.ok(null));

      await viewModel.updateIngredient.execute(updatedCarotte);

      expect(viewModel.updateIngredient.error, isFalse);
      expect(viewModel.filterIngredients(null), [updatedCarotte]);
    });

    test('does not call the repository when the ingredient has no id yet', () async {
      stubSuccessfulLoad(ingredients: []);
      final viewModel = createViewModel();
      await flushMicrotasks();

      const newIngredient = Ingredient(name: 'Nouveau', type: ingredientType);
      await viewModel.updateIngredient.execute(newIngredient);

      verifyNever(() => mockIngredientRepository.updateIngredient(any()));
      expect(viewModel.updateIngredient.error, isFalse);
    });

    test(
      'Don\'t updates the local cache even when the repository call fails',
          () async {
        stubSuccessfulLoad(ingredients: [carotte]);
        final viewModel = createViewModel();
        await flushMicrotasks();

        const updatedCarotte = Ingredient(id: 1, name: 'carotte bio', type: ingredientType);
        when(() => mockIngredientRepository.updateIngredient(updatedCarotte)).thenAnswer(
              (_) async => Result.error(IngredientRepositoryError('db error')),
        );

        await viewModel.updateIngredient.execute(updatedCarotte);

        expect(viewModel.updateIngredient.error, isTrue);
        expect(viewModel.filterIngredients(null), [carotte]);
      },
    );

    test(
      'Returns an error when updating an ingredient that is not in the '
          'local cache',
          () async {
        stubSuccessfulLoad(ingredients: []); // cache stays empty
        final viewModel = createViewModel();
        await flushMicrotasks();

        when(
              () => mockIngredientRepository.updateIngredient(carotte),
        ).thenAnswer((_) async => const Result.ok(null));

        viewModel.updateIngredient.execute(carotte);
        await flushMicrotasks();

        expect(viewModel.updateIngredient.error, isTrue);
        expect(viewModel.updateIngredient.completed, isFalse);

      },
    );
  });

  group('filterIngredients', () {
    test('returns every ingredient sorted by name when the query is null or empty', () async {
      stubSuccessfulLoad(ingredients: [panais, carotte]); // stored out of order
      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.filterIngredients(null), [carotte, panais]);
      expect(viewModel.filterIngredients(''), [carotte, panais]);
    });
  });

  group('handleSearch', () {
    test('parses quantity, unit and name from the search input', () async {
      stubSuccessfulLoad(
        ingredients: [carotte, panais],
        unitsByName: {'kg': kgUnit, 'g': gUnit},
      );
      final viewModel = createViewModel();
      await flushMicrotasks();

      final result = viewModel.handleSearch('2 kg de carotte');

      expect(result.quantity, 2);
      expect(result.unit, kgUnit);
      expect(result.filteredIngredients.map((i) => i.name), contains('carotte'));
    });

    test('falls back to the default unit when none is specified', () async {
      stubSuccessfulLoad(
        ingredients: [carotte, panais],
        unitsByName: {'kg': kgUnit, 'g': gUnit},
      );
      final viewModel = createViewModel();
      await flushMicrotasks();

      final result = viewModel.handleSearch('1 carotte');

      expect(result.quantity, 1);
      expect(result.unit, defaultIngredientUnit);
      expect(result.filteredIngredients.map((i) => i.name), contains('carotte'));
    });

    test('defaults to quantity 1 when none is specified in the search', () async {
      stubSuccessfulLoad(ingredients: [carotte, panais], unitsByName: {'kg': kgUnit});
      final viewModel = createViewModel();
      await flushMicrotasks();

      final result = viewModel.handleSearch('carotte');

      expect(result.quantity, 1);
      expect(result.unit, defaultIngredientUnit);
      expect(result.filteredIngredients.map((i) => i.name), contains('carotte'));
    });

    test(
      'inserts a brand-new ingredient candidate (type id 15) when no exact name '
          'match exists',
          () async {
        stubSuccessfulLoad(ingredients: [carotte, panais], unitsByName: {'kg': kgUnit});
        when(() => mockIngredientRepository.ingredientTypes).thenReturn({
          15: const IngredientTypes(id: 15, name: 'other', color: 0),
        });

        final viewModel = createViewModel();
        await flushMicrotasks();

        final result = viewModel.handleSearch('2 kg de kiwi improbable inconnu');

        expect(result.filteredIngredients.first.name, 'kiwi improbable inconnu');
        expect(result.filteredIngredients.first.id, isNull);
        expect(result.filteredIngredients.first.type.id, 15);
      },
    );
  });
}