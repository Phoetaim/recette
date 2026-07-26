// test/ui/recipe_list/view_model/recipe_list_viewmodel_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';
import 'package:recette/utils/result.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockIngredientWithQuantityUseCase extends Mock implements IngredientWithQuantityUseCase {}

class MockImportExportUseCase extends Mock implements ImportExportUseCase {}

/// Laisse le temps aux Futures/microtasks en attente (ex: le chargement
/// déclenché dans le constructeur du viewmodel) de se résoudre.
Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  late MockRecipeRepository mockRepository;
  late MockImportExportUseCase mockImportExportUseCase;
  late MockIngredientWithQuantityUseCase mockIngredientWithQuantityUseCase;
  late StreamController<RawRecipe> updatedRecipeListController;

  setUpAll(() {
    registerFallbackValue(<RawRecipe>[]);
  });

  setUp(() {
    mockRepository = MockRecipeRepository();
    mockImportExportUseCase = MockImportExportUseCase();
    mockIngredientWithQuantityUseCase = MockIngredientWithQuantityUseCase()
    ;
    updatedRecipeListController = StreamController<RawRecipe>.broadcast();

    when(
          () => mockRepository.updatedRecipeList,
    ).thenReturn(updatedRecipeListController);

    // Comportement par défaut : chargement réussi avec une liste vide.
    // Les tests qui ont besoin d'un contenu spécifique redéfinissent ce stub.
    when(
          () => mockRepository.getRecipeList(),
    ).thenAnswer((_) async => Result.ok(<RawRecipe>[]));
  });

  tearDown(() async {
    await updatedRecipeListController.close();
  });

  RecipeListViewModel createViewModel() {
    return RecipeListViewModel(
      recipeRepository: mockRepository,
      importExportUseCase: mockImportExportUseCase,
    );
  }

  group('chargement initial', () {
    test('charge les recettes avec succès à la création', () async {
      final recipes = [const RawRecipe(id: 1, name: 'Soupe')];
      when(
            () => mockRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.ok(recipes));

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.recipes, recipes);
      expect(viewModel.loadRecipes.completed, isTrue);
      expect(viewModel.loadRecipes.error, isFalse);
    });

    test('expose une erreur si le chargement échoue', () async {
      when(
            () => mockRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.error(Exception('boom')));

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.loadRecipes.error, isTrue);
    });
  });

  group('mise à jour via le stream updatedRecipeList', () {
    test('ajoute une nouvelle recette reçue via le stream', () async {
      final viewModel = createViewModel();
      await flushMicrotasks();

      const newRecipe = RawRecipe(id: 42, name: 'Nouvelle recette');
      updatedRecipeListController.add(newRecipe);
      await flushMicrotasks();

      expect(viewModel.recipes, contains(newRecipe));
    });

    test('met à jour une recette existante plutôt que de la dupliquer', () async {
      const original = RawRecipe(id: 1, name: 'Ancien nom');
      when(
            () => mockRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.ok([original]));

      final viewModel = createViewModel();
      await flushMicrotasks();

      const updated = RawRecipe(id: 1, name: 'Nouveau nom');
      updatedRecipeListController.add(updated);
      await flushMicrotasks();

      expect(viewModel.recipes, [updated]);
    });
  });

  group('deleteRecipe', () {
    test('supprime la recette de la liste en cas de succès', () async {
      const recipe = RawRecipe(id: 1, name: 'À supprimer');
      when(
            () => mockRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.ok([recipe]));
      when(
            () => mockRepository.deleteRecipe(1),
      ).thenAnswer((_) async => const Result.ok(null));

      final viewModel = createViewModel();
      await flushMicrotasks();

      await viewModel.deleteRecipe.execute(1);

      expect(viewModel.recipes, isEmpty);
      expect(viewModel.deleteRecipe.error, isFalse);
    });

    test('garde la recette et expose une erreur si la suppression échoue', () async {
      const recipe = RawRecipe(id: 1, name: 'Reste là');
      when(
            () => mockRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.ok([recipe]));
      when(
            () => mockRepository.deleteRecipe(1),
      ).thenAnswer((_) async => Result.error(Exception('fail')));

      final viewModel = createViewModel();
      await flushMicrotasks();

      await viewModel.deleteRecipe.execute(1);

      expect(viewModel.recipes, [recipe]);
      expect(viewModel.deleteRecipe.error, isTrue);
    });
  });

  group('getRecipeByIndex', () {
    test('retourne la recette au bon index', () async {
      const recipeA = RawRecipe(id: 1, name: 'A');
      const recipeB = RawRecipe(id: 2, name: 'B');
      when(
            () => mockRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.ok([recipeA, recipeB]));

      final viewModel = createViewModel();
      await flushMicrotasks();

      expect(viewModel.getRecipeByIndex(1), recipeB);
    });
  });

  group('sélection multiple', () {
    test('enterSelection ajoute l\'id et active le mode sélection', () async {
      final viewModel = createViewModel();
      await flushMicrotasks();

      viewModel.enterSelection(1);

      expect(viewModel.selectedRecipes, {1});
      expect(viewModel.isSelecting.value, isTrue);
    });

    test('updateSelection ajoute un id non présent', () async {
      final viewModel = createViewModel();
      await flushMicrotasks();

      viewModel.updateSelection(1);

      expect(viewModel.selectedRecipes, {1});
    });

    test('updateSelection retire un id déjà présent', () async {
      final viewModel = createViewModel();
      await flushMicrotasks();

      viewModel.enterSelection(1);
      viewModel.updateSelection(1);

      expect(viewModel.selectedRecipes, isEmpty);
    });

    test('toggleSelectionAll sélectionne toutes les recettes chargées', () async {
      const recipeA = RawRecipe(id: 1, name: 'A');
      const recipeB = RawRecipe(id: 2, name: 'B');
      when(
            () => mockRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.ok([recipeA, recipeB]));

      final viewModel = createViewModel();
      await flushMicrotasks();

      viewModel.toggleSelectionAll();

      expect(viewModel.selectedRecipes, {1, 2});
    });

    test('clearSelection vide la sélection sans quitter le mode sélection', () async {
      final viewModel = createViewModel();
      await flushMicrotasks();

      viewModel.enterSelection(1);
      viewModel.clearSelection();

      expect(viewModel.selectedRecipes, isEmpty);
      expect(viewModel.isSelecting.value, isTrue);
    });

    test('quitSelection vide la sélection et désactive le mode sélection', () async {
      final viewModel = createViewModel();
      await flushMicrotasks();

      viewModel.enterSelection(1);
      viewModel.quitSelection();

      expect(viewModel.selectedRecipes, isEmpty);
      expect(viewModel.isSelecting.value, isFalse);
    });
  });

  group('exportRecipes', () {
    test('exporte uniquement les recettes sélectionnées puis quitte la sélection',
            () async {
          const recipeA = RawRecipe(id: 1, name: 'A');
          const recipeB = RawRecipe(id: 2, name: 'B');
          when(
                () => mockRepository.getRecipeList(),
          ).thenAnswer((_) async => Result.ok([recipeA, recipeB]));
          when(
                () => mockImportExportUseCase.exportRecipes(any()),
          ).thenAnswer((_) async {});

          final viewModel = createViewModel();
          await flushMicrotasks();

          viewModel.enterSelection(1);
          await viewModel.exportRecipes.execute();

          final captured = verify(
                () => mockImportExportUseCase.exportRecipes(captureAny()),
          ).captured.single as List<RawRecipe>;

          expect(captured, [recipeA]);
          expect(viewModel.isSelecting.value, isFalse);
          expect(viewModel.selectedRecipes, isEmpty);
        });
  });

  group('importRecipes', () {
    test('appelle le use case avec la chaîne fournie', () async {
      when(
            () => mockImportExportUseCase.importRecipes(any()),
      ).thenAnswer((_) async {});

      final viewModel = createViewModel();
      await flushMicrotasks();

      await viewModel.importRecipes.execute('encoded-data');

      verify(
            () => mockImportExportUseCase.importRecipes('encoded-data'),
      ).called(1);
    });
  });
}