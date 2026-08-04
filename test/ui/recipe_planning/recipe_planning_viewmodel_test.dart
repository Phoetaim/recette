// test/ui/recipe_planning/view_model/recipe_planning_viewmodel_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/recipe/recipe_planning_repository.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/domain/models/recipe/recipe_planning.dart';
import 'package:recette/domain/use_cases/recipe_utils.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_viewmodel.dart';
import 'package:recette/utils/result.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockRecipePlanningRepository extends Mock implements RecipePlanningRepository {}

class MockRecipeUtilsUseCase extends Mock implements RecipeUtilsUseCase {}

final rawRecipe1 = RawRecipe(id: 1, name: 'Pates');
final rawRecipe2 = RawRecipe(id: 2, name: 'Salade');
final rawRecipe3 = RawRecipe(id: 3, name: 'Pizza');

final planning1 = RecipePlanning(
  id: 1,
  recipeId: 1,
  nbOfPeople: 2,
  progress: RecipePlanningProgress.planned,
);
final planning2 = RecipePlanning(
  id: 2,
  recipeId: 2,
  nbOfPeople: 4,
  progress: RecipePlanningProgress.planned,
);
final planning3 = RecipePlanning(
  id: 3,
  recipeId: 1,
  nbOfPeople: 3,
  progress: RecipePlanningProgress.completed,
);

/// Laisse le temps aux Futures/microtasks en attente de se résoudre.
Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockRecipePlanningRepository mockRecipePlanningRepository;
  late MockRecipeUtilsUseCase mockRecipeUtilsUseCase;
  late StreamController<RawRecipe> updatedRecipeListController;
  late StreamController<RecipePlanning> updatedPlanningController;

  setUpAll(() {
    registerFallbackValue(RawRecipe(name: 'fallback'));
    registerFallbackValue(
      const RecipePlanning(
        recipeId: 0,
        nbOfPeople: 1,
        progress: RecipePlanningProgress.planned,
      ),
    );
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockRecipePlanningRepository = MockRecipePlanningRepository();
    mockRecipeUtilsUseCase = MockRecipeUtilsUseCase();
    updatedRecipeListController = StreamController<RawRecipe>.broadcast();
    updatedPlanningController = StreamController<RecipePlanning>.broadcast();

    when(
          () => mockRecipeRepository.updatedRecipeList,
    ).thenReturn(updatedRecipeListController);
    when(
          () => mockRecipePlanningRepository.updatedRecipePlanning,
    ).thenReturn(updatedPlanningController);
  });

  tearDown(() async {
    await updatedRecipeListController.close();
    await updatedPlanningController.close();
  });

  RecipePlanningViewModel createViewModel() {
    return RecipePlanningViewModel(
      recipeRepository: mockRecipeRepository,
      planningRepository: mockRecipePlanningRepository,
      recipeUtilsUseCase: mockRecipeUtilsUseCase,
    );
  }

  /// Stub commun pour un chargement réussi.
  void stubSuccessfulLoad({
    List<RawRecipe> recipes = const [],
    List<RecipePlanning> plannings = const [],
  }) {
    when(
          () => mockRecipeRepository.getRecipeList(),
    ).thenAnswer((_) async => Result.ok(recipes));
    when(
          () => mockRecipePlanningRepository.getPlannings(),
    ).thenAnswer((_) async => Result.ok(plannings));
  }

  group('Loading view model', () {
    test('loads recipes and plannings successfully', () async {
      stubSuccessfulLoad(
        recipes: [rawRecipe1, rawRecipe2],
        plannings: [planning1, planning2],
      );

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.initViewModel.completed, isTrue);
      expect(viewModel.initViewModel.error, isFalse);
      expect(viewModel.plannings, [planning1, planning2]);
    });

    test('reports an error when fetching recipes fails', () async {
      when(
            () => mockRecipeRepository.getRecipeList(),
      ).thenAnswer(
            (_) async => Result.error(RecipePlanningError('recipe load failed')),
      );

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.initViewModel.error, isTrue);
    });

    test('reports an error when fetching plannings fails', () async {
      when(
            () => mockRecipeRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.ok([rawRecipe1]));
      when(
            () => mockRecipePlanningRepository.getPlannings(),
      ).thenAnswer(
            (_) async => Result.error(RecipePlanningError('planning load failed')),
      );

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.initViewModel.error, isTrue);
    });

    test('sets up subscriptions to recipe and planning streams', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1], plannings: [planning1]);

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.initViewModel.completed, isTrue);
      expect(viewModel.plannings.length, 1);
    });
  });

  group('Reacting to recipe repository streams', () {
    test('adds a new recipe pushed on updatedRecipeList to the local cache', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1], plannings: []);
      final viewModel = createViewModel();
      await flushMicrotasks();

      updatedRecipeListController.add(rawRecipe2);
      await flushMicrotasks();

      expect(viewModel.filterRecipes(null).map((r) => r.id), [1, 2]);
    });

    test('updates a cached recipe when updatedRecipeList fires', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1], plannings: []);
      final viewModel = createViewModel();
      await flushMicrotasks();

      final updatedRecipe = RawRecipe(id: 1, name: 'Pates Fraîches');
      updatedRecipeListController.add(updatedRecipe);
      await flushMicrotasks();

      expect(viewModel.filterRecipes(null).first.name, 'Pates Fraîches');
    });
  });

  group('Reacting to planning repository streams', () {
    test('adds a new planning pushed on updatedRecipePlanning to the local cache', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      updatedPlanningController.add(planning2);
      await flushMicrotasks();

      expect(viewModel.plannings.map((p) => p.id), [1, 2]);
    });

    test('updates a cached planning when updatedRecipePlanning fires', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      final updatedPlanning = planning1.copyWith(nbOfPeople: 5);
      updatedPlanningController.add(updatedPlanning);
      await flushMicrotasks();

      expect(viewModel.plannings.first.nbOfPeople, 5);
    });
  });

  group('getRecipe', () {
    test('returns the recipe with the matching id', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1, rawRecipe2], plannings: []);
      final viewModel = createViewModel();
      await flushMicrotasks();

      final recipe = viewModel.getRecipe(2);

      expect(recipe.id, 2);
      expect(recipe.name, 'Salade');
    });

    test('returns a placeholder recipe when no recipe matches the id', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1], plannings: []);
      final viewModel = createViewModel();
      await flushMicrotasks();

      final recipe = viewModel.getRecipe(999);

      expect(recipe.name, 'Recipe not found');
    });
  });

  group('filterRecipes', () {
    test('returns all recipes sorted by name when query is null or empty', () async {
      stubSuccessfulLoad(
        recipes: [rawRecipe3, rawRecipe1, rawRecipe2], // out of order
        plannings: [],
      );
      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.filterRecipes(null).map((r) => r.name), ['Pates', 'Pizza', 'Salade']);
      expect(viewModel.filterRecipes('').map((r) => r.name), ['Pates', 'Pizza', 'Salade']);
    });

    test('filters recipes by fuzzy search', () async {
      stubSuccessfulLoad(
        recipes: [rawRecipe1, rawRecipe2, rawRecipe3],
        plannings: [],
      );
      final viewModel = createViewModel();
      await flushMicrotasks();

      final results = viewModel.filterRecipes('Pizza');

      expect(results.map((r) => r.name), ['Pizza']);
    });

    test('returns a copy of the filtered list, not a reference', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1], plannings: []);
      final viewModel = createViewModel();
      await flushMicrotasks();

      final list1 = viewModel.filterRecipes(null);
      final list2 = viewModel.filterRecipes(null);

      expect(identical(list1, list2), isFalse);
      expect(list1, equals(list2));
    });
  });

  group('addRecipePlanning command', () {
    test('adds a planning to the repository and local cache', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.addRecipePlanning(planning2),
      ).thenAnswer((_) async => Result.ok(planning2));

      await viewModel.addRecipePlanning.execute(planning2);

      expect(viewModel.addRecipePlanning.error, isFalse);
      expect(viewModel.plannings.map((p) => p.id), [1, 2]);
    });

    test('reports an error when the repository call fails', () async {
      stubSuccessfulLoad(recipes: [], plannings: []);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.addRecipePlanning(any()),
      ).thenAnswer(
            (_) async => Result.error(RecipePlanningError('db error')),
      );

      await viewModel.addRecipePlanning.execute(planning1);

      expect(viewModel.addRecipePlanning.error, isTrue);
      expect(viewModel.plannings.length, 0);
    });
  });

  group('deleteRecipePlanning command', () {
    test('deletes a planning from the repository and local cache', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1, planning2]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.deleteRecipePlanning(1),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.deleteRecipePlanning.execute(1);

      expect(viewModel.deleteRecipePlanning.error, isFalse);
      expect(viewModel.plannings.map((p) => p.id), [2]);
    });

    test('reports an error when the repository call fails', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.deleteRecipePlanning(1),
      ).thenAnswer(
            (_) async => Result.error(RecipePlanningError('db error')),
      );

      await viewModel.deleteRecipePlanning.execute(1);

      expect(viewModel.deleteRecipePlanning.error, isTrue);
      expect(viewModel.plannings.length, 1);
    });

    test('does nothing when deleting a planning id that doesn\'t exist', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.deleteRecipePlanning(999),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.deleteRecipePlanning.execute(999);

      expect(viewModel.deleteRecipePlanning.error, isFalse);
      expect(viewModel.plannings.length, 1);
    });
  });

  group('toggleRecipePlanningStatus', () {
    test('toggles a planned planning to completed', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.updateRecipePlanning(any()),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.toggleRecipePlanningStatus(planning1);

      verify(
            () => mockRecipePlanningRepository.updateRecipePlanning(
          planning1.copyWith(progress: RecipePlanningProgress.completed),
        ),
      ).called(1);
    });

    test('toggles a completed planning to planned', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning3]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.updateRecipePlanning(any()),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.toggleRecipePlanningStatus(planning3);

      verify(
            () => mockRecipePlanningRepository.updateRecipePlanning(
          planning3.copyWith(progress: RecipePlanningProgress.planned),
        ),
      ).called(1);
    });

    test('does not crash when toggling a planning that is no longer in cache', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.updateRecipePlanning(any()),
      ).thenAnswer((_) async => Result.ok(null));

      // Create a planning with an id that's not in cache
      final orphanedPlanning = planning1.copyWith(id: 999);
      await viewModel.toggleRecipePlanningStatus(orphanedPlanning);

      // Should not crash
      expect(viewModel.plannings.length, 1);
    });

    test('silently handles repository errors', () async {
      stubSuccessfulLoad(recipes: [], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(
            () => mockRecipePlanningRepository.updateRecipePlanning(any()),
      ).thenAnswer((_) async => Result.error(RecipePlanningError('db error')));

      await viewModel.toggleRecipePlanningStatus(planning1);

      // Should not throw and plannings should remain unchanged
      expect(viewModel.plannings.first.progress, RecipePlanningProgress.planned);
    });
  });

  group('addPlanningsToShoppingList command', () {
    test('compacts multiple plannings for the same recipe', () async {
      final finalNbOfPeople = 42;
      final planning1Bis = planning1.copyWith(nbOfPeople: finalNbOfPeople - planning1.nbOfPeople);
      stubSuccessfulLoad(
        recipes: [rawRecipe1, rawRecipe2],
        plannings: [planning1, planning1Bis],
      );
      final viewModel = createViewModel();
      await flushMicrotasks();

      final mockRecipe = Recipe(id: 1, name: 'Pates', ingredients: []);
      when(
            () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(rawRecipe1));
      when(
            () => mockRecipeUtilsUseCase.loadRecipe(rawRecipe1),
      ).thenAnswer((_) async => mockRecipe);
      when(
            () => mockRecipeUtilsUseCase.addRecipeToShoppingList(mockRecipe, finalNbOfPeople),
      ).thenAnswer((_) async => false);

      await viewModel.addPlanningsToShoppingList.execute();

      verify(
            () => mockRecipeUtilsUseCase.addRecipeToShoppingList(mockRecipe, finalNbOfPeople),
      ).called(1);
    });

    test('skips plannings with null recipeId', () async {
      final planningNoRecipeId = const RecipePlanning(
        id: 100,
        recipeId: null,
        nbOfPeople: 2,
        progress: RecipePlanningProgress.planned,
      );
      stubSuccessfulLoad(recipes: [], plannings: [planningNoRecipeId]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      await viewModel.addPlanningsToShoppingList.execute();

      verifyNever(() => mockRecipeRepository.getRecipe(any()));
      expect(viewModel.addPlanningsToShoppingList.error, isFalse);
    });

    test('skips completed plannings', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1], plannings: [planning3]); // planning3 is completed
      final viewModel = createViewModel();
      await flushMicrotasks();

      await viewModel.addPlanningsToShoppingList.execute();

      verifyNever(() => mockRecipeRepository.getRecipe(any()));
      expect(viewModel.addPlanningsToShoppingList.error, isFalse);
    });

    test('reports an error if any planning fails to add to shopping list', () async {
      stubSuccessfulLoad(
        recipes: [rawRecipe1, rawRecipe2],
        plannings: [planning1, planning2],
      );
      final viewModel = createViewModel();
      await flushMicrotasks();

      final mockRecipe1 = Recipe(id: 1, name: 'Pates', ingredients: []);
      final mockRecipe2 = Recipe(id: 2, name: 'Salade', ingredients: []);
      when(() => mockRecipeRepository.getRecipe(1)).thenAnswer(
            (_) async => Result.ok(rawRecipe1),
      );
      when(() => mockRecipeRepository.getRecipe(2)).thenAnswer(
            (_) async => Result.ok(rawRecipe2),
      );
      when(() => mockRecipeUtilsUseCase.loadRecipe(rawRecipe1)).thenAnswer(
            (_) async => mockRecipe1,
      );
      when(() => mockRecipeUtilsUseCase.loadRecipe(rawRecipe2)).thenAnswer(
            (_) async => mockRecipe2,
      );
      when(() => mockRecipeUtilsUseCase.addRecipeToShoppingList(mockRecipe1, 2)).thenAnswer(
            (_) async => false,
      );
      when(() => mockRecipeUtilsUseCase.addRecipeToShoppingList(mockRecipe2, 4)).thenAnswer(
            (_) async => true, // This one fails
      );

      await viewModel.addPlanningsToShoppingList.execute();

      expect(viewModel.addPlanningsToShoppingList.error, isTrue);
    });

    test('succeeds when all plannings are added to shopping list', () async {
      stubSuccessfulLoad(
        recipes: [rawRecipe1],
        plannings: [planning1],
      );
      final viewModel = createViewModel();
      await flushMicrotasks();

      final mockRecipe = Recipe(id: 1, name: 'Pates', ingredients: []);
      when(() => mockRecipeRepository.getRecipe(1)).thenAnswer(
            (_) async => Result.ok(rawRecipe1),
      );
      when(() => mockRecipeUtilsUseCase.loadRecipe(rawRecipe1)).thenAnswer(
            (_) async => mockRecipe,
      );
      when(() => mockRecipeUtilsUseCase.addRecipeToShoppingList(mockRecipe, 2)).thenAnswer(
            (_) async => false,
      );

      await viewModel.addPlanningsToShoppingList.execute();

      expect(viewModel.addPlanningsToShoppingList.error, isFalse);
    });

    test('handles repository errors when fetching recipes', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      when(() => mockRecipeRepository.getRecipe(1)).thenAnswer(
            (_) async => Result.error(RecipePlanningError('recipe fetch failed')),
      );

      await viewModel.addPlanningsToShoppingList.execute();

      expect(viewModel.addPlanningsToShoppingList.error, isTrue);
    });
  });

  group('Disposal', () {
    test('cancels stream subscriptions when disposed', () async {
      stubSuccessfulLoad(recipes: [rawRecipe1], plannings: [planning1]);
      final viewModel = createViewModel();
      await flushMicrotasks();

      viewModel.dispose();

      // Adding to the stream after disposal should not affect the view model
      updatedRecipeListController.add(rawRecipe2);
      await flushMicrotasks();

      // Plannings should still only have the original 1
      expect(viewModel.plannings.length, 1);
    });
  });
}