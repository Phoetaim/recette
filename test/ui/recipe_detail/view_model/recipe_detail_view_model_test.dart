// test/ui/recipe_list/view_model/recipe_list_viewmodel_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';
import 'package:recette/utils/result.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockIngredientWithQuantityUseCase extends Mock implements IngredientWithQuantityUseCase {}

class MockImportExportUseCase extends Mock implements ImportExportUseCase {}

class MockShoppingListRepository extends Mock implements ShoppingListRepository {}

// Common data
const ingredientType = IngredientTypes(id: 3, name: 'Légume', color: 123);
const ingredient1 = Ingredient(id: 100, name: 'Carotte', type: ingredientType);
const ingredient2 = Ingredient(id: 101, name: 'Navets', type: ingredientType);
const unit = IngredientUnit(id: 5, name: 'dL');
const ingredientWithQuantity1 = IngredientWithQuantity(
  id: 1,
  ingredient: ingredient1,
  unit: unit,
  quantity: 3,
);
const ingredientWithQuantity2 = IngredientWithQuantity(
  id: 2,
  ingredient: ingredient2,
  unit: unit,
  quantity: 4,
);

/// Laisse le temps aux Futures/microtasks en attente (ex: le chargement
/// déclenché dans le constructeur du viewmodel) de se résoudre.
Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockImportExportUseCase mockImportExportUseCase;
  late MockIngredientWithQuantityUseCase mockIngredientWithQuantityUseCase;
  late MockShoppingListRepository mockShoppingListRepository;
  late StreamController<RawRecipe> updatedRecipeListController;

  setUpAll(() {
    registerFallbackValue(<RawRecipe>[]);
    registerFallbackValue(RawRecipe());
    registerFallbackValue(const IngredientWithQuantity(ingredient: ingredient1));
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockImportExportUseCase = MockImportExportUseCase();
    mockIngredientWithQuantityUseCase = MockIngredientWithQuantityUseCase();
    mockShoppingListRepository = MockShoppingListRepository();
    updatedRecipeListController = StreamController<RawRecipe>.broadcast();

    when(() => mockRecipeRepository.updatedRecipeList).thenReturn(updatedRecipeListController);
  });

  tearDown(() async {
    await updatedRecipeListController.close();
  });

  RecipeDetailViewModel createViewModel() {
    return RecipeDetailViewModel(
      recipeRepository: mockRecipeRepository,
      importExportUseCase: mockImportExportUseCase,
      ingredientWithQuantityUseCase: mockIngredientWithQuantityUseCase,
      shoppingListRepository: mockShoppingListRepository,
    );
  }

  group('Recipe loading', () {
    test('The recipe is correctly loaded', () async {
      const nbOfPeople = 10;
      final rawRecipe = const RawRecipe(
        id: 1,
        name: 'Soupe',
        nbOfPeople: nbOfPeople,
        preparationTime: '10h',
        cookingTime: '10h',
        ingredientWithQuantityIds: [1, 2],
        steps: 'Step 1.\nStep 2.',
      );

      const recipe = Recipe(
        id: 1,
        name: 'Soupe',
        nbOfPeople: nbOfPeople,
        preparationTime: '10h',
        cookingTime: '10h',
        ingredients: [ingredientWithQuantity1, ingredientWithQuantity2],
        steps: ['Step 1.', 'Step 2.'],
      );

      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(rawRecipe.id!))),
      ).thenAnswer((_) async => Result.ok(rawRecipe));

      when(
            () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
          any(that: equals(rawRecipe.ingredientWithQuantityIds)),
        ),
      ).thenAnswer(
            (_) async =>
            Result.ok([ingredientWithQuantity1.toJson(), ingredientWithQuantity2.toJson()]),
      );

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('${rawRecipe.id!}');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.completed, isTrue);
      expect(viewModel.recipe.value, recipe);
      expect(viewModel.currentNumberOfPeople.value, nbOfPeople);
    });

    test('New recipe is correctly instantiated', () async {
      const recipe = Recipe();
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.completed, isTrue);
      expect(viewModel.recipe.value, recipe);
      expect(viewModel.currentNumberOfPeople.value, recipe.nbOfPeople);
    });

    test('Default recipe can be loaded', () async {
      final rawRecipe = const RawRecipe(id: 1);

      const recipe = Recipe(id: 1);

      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => Result.ok(rawRecipe));

      when(
            () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
          any(that: equals(rawRecipe.ingredientWithQuantityIds)),
        ),
      ).thenAnswer((_) async => Result.ok([]));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('${rawRecipe.id!}');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.completed, isTrue);
      expect(viewModel.recipe.value, recipe);
      expect(viewModel.currentNumberOfPeople.value, recipe.nbOfPeople);
    });

    test('Input parameter is not an int', () async {
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('not a number');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.error, isTrue);
    });

    test('Recipe id does not exists', () async {
      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => Result.error(RecipeRepositoryError('Recipe does not exists')));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('1');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.error, isTrue);
    });

    test('If a problem occurs with an ingredient, returns empty list', () async {
      const rawRecipe = RawRecipe(id: 1, name: 'Soupe', ingredientWithQuantityIds: [1, 3]);
      const recipe = Recipe(id: 1, name: 'Soupe');

      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(rawRecipe.id!))),
      ).thenAnswer((_) async => Result.ok(rawRecipe));

      when(
            () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
          any(that: equals(rawRecipe.ingredientWithQuantityIds)),
        ),
      ).thenAnswer((_) async => Result.error(Exception('An error occurred')));
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('${rawRecipe.id!}');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.completed, isTrue);
      expect(viewModel.recipe.value, recipe);
    });
  });

  group(('Saving recipe'), () {
    test('Saving an unchanged newRecipe', () async {
      const rawRecipe = RawRecipe(id: 1);

      when(
            () => mockRecipeRepository.addRecipe(any(that: equals(RawRecipe()))),
      ).thenAnswer((_) async => Result.ok(rawRecipe));

      when(
            () => mockRecipeRepository.updateRecipe(any(that: equals(rawRecipe)), any(that: equals(rawRecipe))),
      ).thenAnswer((_) async => Result.ok(null));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      viewModel.saveRecipe.execute();
      await flushMicrotasks();
      viewModel.saveRecipe.execute();
      await flushMicrotasks();

      expect(viewModel.saveRecipe .completed, isTrue);
      verify(() => mockRecipeRepository.addRecipe(const RawRecipe())).called(1);
      verify(() => mockRecipeRepository.updateRecipe(rawRecipe, rawRecipe)).called(1);
    });

    test('Saving new ingredients', () async {
      const rawRecipe = RawRecipe(id: 1);
      const secondRawRecipe = RawRecipe(id: 1, ingredientWithQuantityIds: [1, 2]);

      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => Result.ok(rawRecipe));

      when(
            () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
          any(that: equals(rawRecipe.ingredientWithQuantityIds)),
        ),
      ).thenAnswer((_) async => Result.ok([]));


      // Le viewmodel n'utilise pas l'id qu'on lui passe : addIngredientWithQuantity()
      // l'écrase avec un id temporaire négatif (tmpIngredientId, qui part de -1 et
      // décrémente à chaque appel). Le use case est donc bien appelé avec ces id
      // temporaires, pas avec ingredientWithQuantity1/2 tels quels.
      when(
            () => mockIngredientWithQuantityUseCase.addIngredientWithQuantity(
          ingredientWithQuantity1.copyWith(id: -1),
        ),
      ).thenAnswer((_) async => Result.ok(ingredientWithQuantity1));

      when(
            () => mockIngredientWithQuantityUseCase.addIngredientWithQuantity(
          ingredientWithQuantity2.copyWith(id: -2),
        ),
      ).thenAnswer((_) async => Result.ok(ingredientWithQuantity2));

      when(
            () => mockRecipeRepository.updateRecipe(any(that: equals(rawRecipe)), any(that: equals(secondRawRecipe))),
      ).thenAnswer((_) async => Result.ok(null));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('${rawRecipe.id!}');
      await flushMicrotasks();
      viewModel.addIngredientWithQuantity(ingredientWithQuantity1);
      viewModel.addIngredientWithQuantity(ingredientWithQuantity2);
      viewModel.saveRecipe.execute();
      await flushMicrotasks();

      expect(viewModel.loadRecipeById.completed, isTrue);
      verify(() => mockRecipeRepository.updateRecipe(rawRecipe, secondRawRecipe)).called(1);
    });
  });

  group('Deleting recipe', () {
    test('calls the repository with the recipe id when the recipe exists', () async {
      const rawRecipe = RawRecipe(id: 1);

      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => const Result.ok(rawRecipe));
      when(
            () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
          any(that: equals(<int>[])),
        ),
      ).thenAnswer((_) async => const Result.ok([]));
      when(
            () => mockRecipeRepository.deleteRecipe(1),
      ).thenAnswer((_) async => const Result.ok(null));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('1');
      await flushMicrotasks();

      viewModel.deleteRecipe.execute();
      await flushMicrotasks();

      verify(() => mockRecipeRepository.deleteRecipe(1)).called(1);
      expect(viewModel.deleteRecipe.completed, isTrue);
    });

    test('does not call the repository for a new, unsaved recipe (no id yet)', () async {
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();

      viewModel.deleteRecipe.execute();
      await flushMicrotasks();

      verifyNever(() => mockRecipeRepository.deleteRecipe(any()));
      expect(viewModel.deleteRecipe.completed, isTrue);
    });

    test(
      'Report error if the repository deletion fails',
          () async {
        const rawRecipe = RawRecipe(id: 1);

        when(
              () => mockRecipeRepository.getRecipe(any(that: equals(1))),
        ).thenAnswer((_) async => const Result.ok(rawRecipe));
        when(
              () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
            any(that: equals(<int>[])),
          ),
        ).thenAnswer((_) async => const Result.ok([]));
        when(
              () => mockRecipeRepository.deleteRecipe(1),
        ).thenAnswer((_) async => Result.error(RecipeRepositoryError('db error')));

        final viewModel = createViewModel();
        viewModel.loadRecipeById.execute('1');
        await flushMicrotasks();

        viewModel.deleteRecipe.execute();
        await flushMicrotasks();

        expect(viewModel.deleteRecipe.error, isTrue);
        expect(viewModel.deleteRecipe.completed, isFalse);
      },
    );
  });

  group('Updating recipe fields', () {
    test('updateRecipeName updates the recipe name', () async {
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();

      viewModel.updateRecipeName('Tarte aux pommes');

      expect(viewModel.recipe.value.name, 'Tarte aux pommes');
    });

    test('updateRecipePreparationTime updates the preparation time', () async {
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();

      viewModel.updateRecipePreparationTime('20min');

      expect(viewModel.recipe.value.preparationTime, '20min');
    });

    test('updateRecipeCookingTime updates the cooking time', () async {
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();

      viewModel.updateRecipeCookingTime('45min');

      expect(viewModel.recipe.value.cookingTime, '45min');
    });

    test(
      'updateRecipeNbOfPeople updates both the recipe and currentNumberOfPeople',
          () async {
        final viewModel = createViewModel();
        viewModel.loadRecipeById.execute('-1');
        await flushMicrotasks();

        viewModel.updateRecipeNbOfPeople('6');

        expect(viewModel.recipe.value.nbOfPeople, 6);
        expect(viewModel.currentNumberOfPeople.value, 6);
      },
    );

    // Note: updateRecipeNbOfPeople throws a bare TypeError on invalid input, but the
    // method's return type is `void` (not `Future<void>`) despite being `async`. That
    // means the exception is delivered as an uncaught zone error rather than a
    // catchable Future error, so it isn't reliably assertable with a plain
    // `expect(() => ..., throwsA(...))` unit test. Flagging this as a testability gap
    // rather than writing a flaky test for it.
  });

  group('Managing ingredients locally', () {
    test(
      'addIngredientWithQuantity appends the ingredient with a decreasing temporary id',
          () async {
        final viewModel = createViewModel();
        viewModel.loadRecipeById.execute('-1');
        await flushMicrotasks();

        viewModel.addIngredientWithQuantity(ingredientWithQuantity1);
        viewModel.addIngredientWithQuantity(ingredientWithQuantity2);

        expect(viewModel.recipe.value.ingredients, [
          ingredientWithQuantity1.copyWith(id: -1),
          ingredientWithQuantity2.copyWith(id: -2),
        ]);
      },
    );

    test(
      'removeIngredientWithQuantity removes the ingredient from the recipe and its '
          'id from the raw recipe',
          () async {
        const originalRawRecipe = RawRecipe(id: 1, ingredientWithQuantityIds: [1, 2]);
        const updatedRawRecipe = RawRecipe(id: 1, ingredientWithQuantityIds: [2]);

        when(
              () => mockRecipeRepository.getRecipe(any(that: equals(1))),
        ).thenAnswer((_) async => const Result.ok(originalRawRecipe));
        when(
              () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
            any(that: equals(<int>[1, 2])),
          ),
        ).thenAnswer(
              (_) async =>
              Result.ok([ingredientWithQuantity1.toJson(), ingredientWithQuantity2.toJson()]),
        );
        when(
              () => mockRecipeRepository.updateRecipe(originalRawRecipe, updatedRawRecipe),
        ).thenAnswer((_) async => const Result.ok(null));

        final viewModel = createViewModel();
        viewModel.loadRecipeById.execute('1');
        await flushMicrotasks();

        viewModel.removeIngredientWithQuantity(ingredientWithQuantity1);

        expect(viewModel.recipe.value.ingredients, [ingredientWithQuantity2]);

        // Confirms the id was also removed from the underlying raw recipe, by
        // checking what gets persisted on save.
        viewModel.saveRecipe.execute();
        await flushMicrotasks();

        verify(
              () => mockRecipeRepository.updateRecipe(originalRawRecipe, updatedRawRecipe),
        ).called(1);
      },
    );
  });

  group('isRecipeUpdated', () {
    test('returns false right after loading an existing recipe with no changes', () async {
      const rawRecipe = RawRecipe(id: 1);

      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => const Result.ok(rawRecipe));
      when(
            () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
          any(that: equals(<int>[])),
        ),
      ).thenAnswer((_) async => const Result.ok([]));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('1');
      await flushMicrotasks();

      expect(viewModel.isRecipeUpdated(), isFalse);
    });

    test('returns true after a field is changed', () async {
      const rawRecipe = RawRecipe(id: 1);

      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => const Result.ok(rawRecipe));
      when(
            () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
          any(that: equals(<int>[])),
        ),
      ).thenAnswer((_) async => const Result.ok([]));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('1');
      await flushMicrotasks();

      viewModel.updateRecipeName('New name');

      expect(viewModel.isRecipeUpdated(), isTrue);
    });

    test('returns true after adding a local ingredient that is not saved yet', () async {
      const rawRecipe = RawRecipe(id: 1);

      when(
            () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => const Result.ok(rawRecipe));
      when(
            () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
          any(that: equals(<int>[])),
        ),
      ).thenAnswer((_) async => const Result.ok([]));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('1');
      await flushMicrotasks();

      viewModel.addIngredientWithQuantity(ingredientWithQuantity1);

      expect(viewModel.isRecipeUpdated(), isTrue);
    });
  });

  group('Exporting recipe', () {
    test('saves the recipe first, then exports the saved raw recipe', () async {
      const rawRecipe = RawRecipe(id: 1);

      when(
            () => mockRecipeRepository.addRecipe(const RawRecipe()),
      ).thenAnswer((_) async => const Result.ok(rawRecipe));
      when(() => mockImportExportUseCase.exportRecipes(any())).thenAnswer((_) async {});

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();

      await viewModel.exportRecipe();

      verify(() => mockImportExportUseCase.exportRecipes([rawRecipe])).called(1);
    });
  });

  group('Adding recipe to shopping list', () {
    test(
      'adds each ingredient to the shopping list with the quantity scaled to '
          'currentNumberOfPeople',
          () async {
        const rawRecipe = RawRecipe(id: 1, nbOfPeople: 4, ingredientWithQuantityIds: [1, 2]);

        when(
              () => mockRecipeRepository.getRecipe(any(that: equals(1))),
        ).thenAnswer((_) async => const Result.ok(rawRecipe));
        when(
              () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
            any(that: equals(<int>[1, 2])),
          ),
        ).thenAnswer(
              (_) async =>
              Result.ok([ingredientWithQuantity1.toJson(), ingredientWithQuantity2.toJson()]),
        );
        when(
              () => mockRecipeRepository.updateRecipe(any(), any()),
        ).thenAnswer((_) async => const Result.ok(null));
        when(
              () => mockShoppingListRepository.addShoppingIngredient(any()),
        ).thenAnswer((_) async => const Result.ok(null));

        final viewModel = createViewModel();
        viewModel.loadRecipeById.execute('1');
        await flushMicrotasks();

        viewModel.currentNumberOfPeople.value = 8;

        viewModel.addRecipeToShoppingList.execute();
        await flushMicrotasks();

        // quantity 3 scaled by 8/4 = 6, quantity 4 scaled by 8/4 = 8.
        verify(
              () => mockShoppingListRepository.addShoppingIngredient(
            ingredientWithQuantity1.copyWith(quantity: 6),
          ),
        ).called(1);
        verify(
              () => mockShoppingListRepository.addShoppingIngredient(
            ingredientWithQuantity2.copyWith(quantity: 8),
          ),
        ).called(1);
      },
    );

    test(
      'Handle error in addShoppingIngredient correctly',
          () async {
        const rawRecipe = RawRecipe(id: 1, ingredientWithQuantityIds: [1]);

        when(
              () => mockRecipeRepository.getRecipe(any(that: equals(1))),
        ).thenAnswer((_) async => const Result.ok(rawRecipe));
        when(
              () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds(
            any(that: equals(<int>[1])),
          ),
        ).thenAnswer((_) async => Result.ok([ingredientWithQuantity1.toJson()]));
        when(
              () => mockRecipeRepository.updateRecipe(any(), any()),
        ).thenAnswer((_) async => const Result.ok(null));
        // The repository call fails...
        when(
              () => mockShoppingListRepository.addShoppingIngredient(any()),
        ).thenAnswer((_) async => Result.error(Exception('db error')));

        final viewModel = createViewModel();
        viewModel.loadRecipeById.execute('1');
        await flushMicrotasks();

        viewModel.addRecipeToShoppingList.execute();
        await flushMicrotasks();

        expect(viewModel.addRecipeToShoppingList.error, isTrue);
        expect(viewModel.addRecipeToShoppingList.completed, isFalse);
      },
    );
  });
}