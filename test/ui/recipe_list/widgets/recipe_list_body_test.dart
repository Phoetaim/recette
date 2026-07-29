// test/ui/recipe_list/widgets/recipe_list_body_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';
import 'package:recette/ui/recipe_list/widgets/recipe_card.dart';
import 'package:recette/ui/recipe_list/widgets/recipe_list_body.dart';
import 'package:recette/utils/result.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockImportExportUseCase extends Mock implements ImportExportUseCase {}

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockImportExportUseCase mockImportExportUseCase;
  late StreamController<RawRecipe> updatedRecipeListController;

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

  /// Construit l'app de test avec un GoRouter minimal : la page d'accueil affiche
  /// RecipeListBody (enveloppé dans un ListenableBuilder, comme le fait réellement
  /// RecipeListScreen), et une route de détail factice affiche l'id reçu pour
  /// permettre de vérifier la navigation.
  Widget buildTestApp(RecipeListViewModel viewModel) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return Scaffold(
              body: ListenableBuilder(
                listenable: viewModel,
                builder: (context, child) => RecipeListBody(viewModel: viewModel),
              ),
            );
          },
        ),
        GoRoute(
          path: '/recipe/:recipeId',
          name: Routes.recipeDetail,
          builder: (context, state) {
            return Scaffold(body: Text('detail-${state.pathParameters['recipeId']}'));
          },
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders one RecipeCard per recipe from the viewModel', (tester) async {
    when(() => mockRecipeRepository.getRecipeList()).thenAnswer(
          (_) async => const Result.ok([
        RawRecipe(id: 1, name: 'Soupe'),
        RawRecipe(id: 2, name: 'Salade'),
      ]),
    );

    final viewModel = createViewModel();

    await tester.pumpWidget(buildTestApp(viewModel));
    await tester.pump();

    expect(find.text('Soupe'), findsOneWidget);
    expect(find.text('Salade'), findsOneWidget);
    expect(find.byType(RecipeCard), findsNWidgets(2));
  });

  testWidgets('renders nothing when the recipe list is empty', (tester) async {
    final viewModel = createViewModel();

    await tester.pumpWidget(buildTestApp(viewModel));
    await tester.pump();

    expect(find.byType(RecipeCard), findsNothing);
  });

  testWidgets('tapping a recipe navigates to its detail screen with the right id', (
      tester,
      ) async {
    when(
          () => mockRecipeRepository.getRecipeList(),
    ).thenAnswer((_) async => const Result.ok([RawRecipe(id: 42, name: 'Soupe')]));

    final viewModel = createViewModel();

    await tester.pumpWidget(buildTestApp(viewModel));
    await tester.pump();

    await tester.tap(find.text('Soupe'));
    await tester.pumpAndSettle();

    expect(find.text('detail-42'), findsOneWidget);
  });

  testWidgets('long-pressing a recipe enters selection mode and selects it', (tester) async {
    when(
          () => mockRecipeRepository.getRecipeList(),
    ).thenAnswer((_) async => const Result.ok([RawRecipe(id: 42, name: 'Soupe')]));

    final viewModel = createViewModel();

    await tester.pumpWidget(buildTestApp(viewModel));
    await tester.pump();

    expect(find.byType(CheckboxListTile), findsNothing);

    await tester.longPress(find.text('Soupe'));
    await tester.pump();

    expect(viewModel.isSelecting.value, isTrue);
    expect(viewModel.selectedRecipes, {42});
    expect(find.byType(CheckboxListTile), findsOneWidget);
  });

  testWidgets('tapping the checkbox in selection mode toggles the selection', (tester) async {
    when(
          () => mockRecipeRepository.getRecipeList(),
    ).thenAnswer((_) async => const Result.ok([RawRecipe(id: 42, name: 'Soupe')]));

    final viewModel = createViewModel();
    viewModel.enterSelection(42);

    await tester.pumpWidget(buildTestApp(viewModel));
    await tester.pump();

    expect(find.byType(CheckboxListTile), findsOneWidget);

    final checkboxTile = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(checkboxTile.value, isTrue);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(viewModel.selectedRecipes, isEmpty);
  });

  testWidgets('tapping the delete icon removes the recipe from the displayed list', (
      tester,
      ) async {
    when(
          () => mockRecipeRepository.getRecipeList(),
    ).thenAnswer((_) async => Result.ok([RawRecipe(id: 42, name: 'Soupe')]));
    when(
          () => mockRecipeRepository.deleteRecipe(42),
    ).thenAnswer((_) async => const Result.ok(null));

    final viewModel = createViewModel();

    await tester.pumpWidget(buildTestApp(viewModel));
    await tester.pump();

    expect(find.text('Soupe'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('Soupe'), findsNothing);
    expect(find.byType(RecipeCard), findsNothing);
  });

  testWidgets('keeps the recipe displayed if deletion fails', (tester) async {
    when(
          () => mockRecipeRepository.getRecipeList(),
    ).thenAnswer((_) async => const Result.ok([RawRecipe(id: 42, name: 'Soupe')]));
    when(
          () => mockRecipeRepository.deleteRecipe(42),
    ).thenAnswer((_) async => Result.error(RecipeRepositoryError('db error')));

    final viewModel = createViewModel();

    await tester.pumpWidget(buildTestApp(viewModel));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('Soupe'), findsOneWidget);
  });
}