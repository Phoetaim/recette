// test/ui/recipe_list/widgets/recipes_import_widget_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/import_data.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';
import 'package:recette/ui/recipe_list/widgets/recipes_import_widget.dart';
import 'package:recette/utils/result.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockImportExportUseCase extends Mock implements ImportExportUseCase {}

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockImportExportUseCase mockImportExportUseCase;
  late StreamController<RawRecipe> updatedRecipeListController;

  setUpAll(() {
    registerFallbackValue(const ImportData());
    registerFallbackValue(<int>{});
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockImportExportUseCase = MockImportExportUseCase();
    updatedRecipeListController = StreamController<RawRecipe>.broadcast();

    when(() => mockRecipeRepository.updatedRecipeList).thenReturn(updatedRecipeListController);
    // Comportement par défaut : liste vide. Les tests qui ont besoin d'un contenu
    // spécifique redéfinissent ce stub.
    when(
          () => mockRecipeRepository.getRecipeList(),
    ).thenAnswer((_) async => const Result.ok(<RawRecipe>[]));
  });

  tearDown(() async {
    await updatedRecipeListController.close();
  });

  RecipeListViewModel createViewModel() {
    return RecipeListViewModel(
      recipeRepository: mockRecipeRepository,
      importExportUseCase: mockImportExportUseCase,
    );
  }

  /// Construit un viewModel dont `recipesToImport` est peuplé, en simulant le
  /// retour de `loadImportData` par le use case mocké. On attend explicitement
  /// `loadRecipes` et `getRawRecipesFromImport` pour être sûr que `recipes` et
  /// `recipesToImport` sont bien initialisés avant de construire le widget.
  Future<RecipeListViewModel> createViewModelWithRecipesToImport(List<RawRecipe> rawRecipes) async {
    final importData = ImportData(rawRecipes: rawRecipes);
    when(() => mockImportExportUseCase.loadImportData(any())).thenAnswer((_) async => importData);

    final viewModel = createViewModel();
    await viewModel.loadRecipes.execute();
    await viewModel.getRawRecipesFromImport.execute('encoded-data');
    return viewModel;
  }

  /// Affiche RecipesImportWidget dans une boîte de dialogue, comme le fait
  /// réellement RecipeListScreen via showDialog.
  Future<void> pumpDialog(WidgetTester tester, RecipeListViewModel viewModel) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RecipesImportWidget(viewModel: viewModel),
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Iterable<CheckboxListTile> recipeTilesOf(WidgetTester tester) {
    return tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .where((tile) => (tile.title as Text).data != 'Recettes à importer');
  }

  group('display', () {
    testWidgets('renders one CheckboxListTile per recipe to import', (tester) async {
      final viewModel = await createViewModelWithRecipesToImport([
        const RawRecipe(id: 1, name: 'Soupe'),
        const RawRecipe(id: 2, name: 'Salade'),
      ]);

      await pumpDialog(tester, viewModel);

      expect(find.text('Soupe'), findsOneWidget);
      expect(find.text('Salade'), findsOneWidget);
      // +1 for the top "select all" CheckboxListTile.
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
    });

    testWidgets('renders no recipe tile when recipesToImport is empty', (tester) async {
      final viewModel = await createViewModelWithRecipesToImport([]);

      await pumpDialog(tester, viewModel);

      expect(find.byType(RawRecipeTile), findsNothing);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('all recipes are selected by default', (tester) async {
      final viewModel = await createViewModelWithRecipesToImport([
        const RawRecipe(id: 1, name: 'Soupe'),
        const RawRecipe(id: 2, name: 'Salade'),
      ]);

      await pumpDialog(tester, viewModel);

      expect(recipeTilesOf(tester).every((tile) => tile.value == true), isTrue);
    });
  });

  group('selection', () {
    testWidgets('unchecking a recipe removes it from the selection', (tester) async {
      final viewModel = await createViewModelWithRecipesToImport([
        const RawRecipe(id: 1, name: 'Soupe'),
        const RawRecipe(id: 2, name: 'Salade'),
      ]);

      await pumpDialog(tester, viewModel);

      await tester.tap(find.text('Soupe'));
      await tester.pumpAndSettle();

      final soupeTile = tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Soupe'));
      expect(soupeTile.value, isFalse);
    });

    testWidgets('re-checking a recipe adds it back to the selection', (tester) async {
      final viewModel = await createViewModelWithRecipesToImport([const RawRecipe(id: 1, name: 'Soupe')]);

      await pumpDialog(tester, viewModel);

      await tester.tap(find.text('Soupe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Soupe'));
      await tester.pumpAndSettle();

      final soupeTile = tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Soupe'));
      expect(soupeTile.value, isTrue);
    });
  });

  group('top checkbox', () {
    // Note : `_isTopCheckBoxChecked` compare `selectedRecipesToImport.length` à
    // `viewModel.recipes.length` (les recettes déjà en base), pas à
    // `recipesToImport.length`. Avec le mock par défaut (`recipes` vide) et des
    // recettes à importer non vides, la case globale démarre donc en état
    // indéterminé plutôt que cochée.
    testWidgets('is indeterminate by default when recipes count differs from recipesToImport count', (
        tester,
        ) async {
      final viewModel = await createViewModelWithRecipesToImport([
        const RawRecipe(id: 1, name: 'Soupe'),
        const RawRecipe(id: 2, name: 'Salade'),
      ]);

      await pumpDialog(tester, viewModel);

      final topTile = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Recettes à importer'),
      );
      expect(topTile.value, isNull);
    });

    testWidgets('tapping it clears the selection when everything is selected', (tester) async {
      when(() => mockRecipeRepository.getRecipeList()).thenAnswer(
            (_) async => const Result.ok([RawRecipe(id: 1, name: 'Soupe'), RawRecipe(id: 2, name: 'Salade')]),
      );
      final viewModel = await createViewModelWithRecipesToImport([
        const RawRecipe(id: 1, name: 'Soupe'),
        const RawRecipe(id: 2, name: 'Salade'),
      ]);

      await pumpDialog(tester, viewModel);

      await tester.tap(find.text('Recettes à importer'));
      await tester.pumpAndSettle();

      expect(recipeTilesOf(tester).every((tile) => tile.value == false), isTrue);
    });

    testWidgets('tapping it selects everything when nothing is selected', (tester) async {
      when(() => mockRecipeRepository.getRecipeList()).thenAnswer(
            (_) async => const Result.ok([RawRecipe(id: 1, name: 'Soupe'), RawRecipe(id: 2, name: 'Salade')]),
      );
      final viewModel = await createViewModelWithRecipesToImport([
        const RawRecipe(id: 1, name: 'Soupe'),
        const RawRecipe(id: 2, name: 'Salade'),
      ]);

      await pumpDialog(tester, viewModel);

      // First tap: fully selected -> clears the selection.
      await tester.tap(find.text('Recettes à importer'));
      await tester.pumpAndSettle();
      // Second tap: nothing selected -> selects everything.
      await tester.tap(find.text('Recettes à importer'));
      await tester.pumpAndSettle();

      expect(recipeTilesOf(tester).every((tile) => tile.value == true), isTrue);
    });
  });

  group('import', () {
    testWidgets('the Importer button imports the selected recipes and closes the dialog', (tester) async {
      when(() => mockImportExportUseCase.importRecipes(any(), any())).thenAnswer((_) async {});

      final viewModel = await createViewModelWithRecipesToImport([
        const RawRecipe(id: 1, name: 'Soupe'),
        const RawRecipe(id: 2, name: 'Salade'),
      ]);

      await pumpDialog(tester, viewModel);

      // Deselect "Salade" before importing.
      await tester.tap(find.text('Salade'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();

      final captured = verify(
            () => mockImportExportUseCase.importRecipes(captureAny(), captureAny()),
      ).captured;
      expect(captured[1], {1});
      expect(find.byType(RecipesImportWidget), findsNothing);
    });
  });
}