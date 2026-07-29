// test/ui/recipe_list/widgets/recipe_list_screen_test.dart
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';
import 'package:recette/ui/recipe_list/widgets/recipe_list_screen.dart';
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

  /// GoRouter minimal avec 3 routes : l'écran testé, une route de détail factice
  /// (affiche l'id reçu) et une route "liste de courses" factice, pour vérifier
  /// les 2 navigations déclenchées par l'écran.
  Widget buildTestApp(RecipeListViewModel viewModel) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => RecipeListScreen(viewModel: viewModel)),
        GoRoute(
          path: '/recipe/:recipeId',
          name: Routes.recipeDetail,
          builder: (context, state) {
            return Scaffold(body: Text('detail-${state.pathParameters['recipeId']}'));
          },
        ),
        GoRoute(
          path: Routes.shoppingList,
          builder: (context, state) => const Scaffold(body: Text('shopping-list-screen')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('Loading state', () {
    testWidgets('shows a loading indicator while recipes are being fetched', (tester) async {
      final completer = Completer<Result<List<RawRecipe>>>();
      when(() => mockRecipeRepository.getRecipeList()).thenAnswer((_) => completer.future);

      final viewModel = createViewModel();

      await tester.pumpWidget(buildTestApp(viewModel));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Result.ok(<RawRecipe>[]));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows a retry button on error, and retry reloads the list', (tester) async {
      var callCount = 0;
      when(() => mockRecipeRepository.getRecipeList()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return Result.error(RecipeRepositoryError('boom'));
        }
        return const Result.ok([RawRecipe(id: 1, name: 'Soupe')]);
      });

      final viewModel = createViewModel();

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      expect(find.text('Retry?'), findsOneWidget);

      await tester.tap(find.text('Retry?'));
      await tester.pumpAndSettle();

      expect(find.text('Retry?'), findsNothing);
      expect(find.text('Soupe'), findsOneWidget);
    });
  });

  group('Floating action button', () {
    testWidgets('tapping the add FAB navigates to a new recipe (id -1)', (tester) async {
      final viewModel = createViewModel();

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('detail--1'), findsOneWidget);
    });

    testWidgets('shows the selection FAB with an export button once something is selected', (
        tester,
        ) async {
      when(
            () => mockRecipeRepository.getRecipeList(),
      ).thenAnswer((_) async => const Result.ok([RawRecipe(id: 42, name: 'Soupe')]));

      final viewModel = createViewModel();
      viewModel.enterSelection(42);

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      expect(find.text('Sélectionne tout'), findsOneWidget);
      expect(find.text('Désélectionne tout'), findsOneWidget);
      expect(find.text('Exporter'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('hides the export button when selection mode has nothing selected', (
        tester,
        ) async {
      final viewModel = createViewModel();
      // Enters selection mode without selecting any recipe id.
      viewModel.isSelecting.value = true;

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      expect(find.text('Exporter'), findsNothing);
    });

    testWidgets('"Sélectionne tout" selects every loaded recipe', (tester) async {
      when(() => mockRecipeRepository.getRecipeList()).thenAnswer(
            (_) async => const Result.ok([
          RawRecipe(id: 1, name: 'Soupe'),
          RawRecipe(id: 2, name: 'Salade'),
        ]),
      );

      final viewModel = createViewModel();
      viewModel.enterSelection(1);

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      await tester.tap(find.text('Sélectionne tout'));
      await tester.pump();

      expect(viewModel.selectedRecipes, {1, 2});
    });

    testWidgets('the clear FAB quits selection mode', (tester) async {
      when(
            () => mockRecipeRepository.getRecipeList(),
      ).thenAnswer((_) async => const Result.ok([RawRecipe(id: 42, name: 'Soupe')]));

      final viewModel = createViewModel();
      viewModel.enterSelection(42);

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(viewModel.isSelecting.value, isFalse);
      expect(viewModel.selectedRecipes, isEmpty);
    });
  });

  group('Deleting a recipe', () {
    testWidgets('shows a success snackbar when deletion succeeds', (tester) async {
      when(
            () => mockRecipeRepository.getRecipeList(),
      ).thenAnswer((_) async => Result.ok([RawRecipe(id: 42, name: 'Soupe')]));
      when(
            () => mockRecipeRepository.deleteRecipe(42),
      ).thenAnswer((_) async => const Result.ok(null));

      final viewModel = createViewModel();

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete));
      // Not pumpAndSettle: the SnackBar's duration is only 1000 microseconds,
      // so we assert right after the frame where it appears.
      await tester.pumpAndSettle();

      expect(find.text('Recette supprimée'), findsOneWidget);
    });

    testWidgets('shows an error snackbar when deletion fails', (tester) async {
      when(
            () => mockRecipeRepository.getRecipeList(),
      ).thenAnswer((_) async => const Result.ok([RawRecipe(id: 42, name: 'Soupe')]));
      when(
            () => mockRecipeRepository.deleteRecipe(42),
      ).thenAnswer((_) async => Result.error(RecipeRepositoryError('boom')));

      final viewModel = createViewModel();

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Error while loading'), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('the back arrow navigates to the shopping list', (tester) async {
      final viewModel = createViewModel();

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('shopping-list-screen'), findsOneWidget);
    });
  });

  group('Importing recipes', () {
    testWidgets('opens the import dialog and submits the pasted data', (tester) async {
      when(() => mockImportExportUseCase.importRecipes(any())).thenAnswer((_) async {});

      final viewModel = createViewModel();

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      await tester.tap(find.byIcon(CupertinoIcons.arrow_down_left));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'encoded-data');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      verify(() => mockImportExportUseCase.importRecipes('encoded-data')).called(1);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('closing without entering data submits an empty string', (tester) async {
      when(() => mockImportExportUseCase.importRecipes(any())).thenAnswer((_) async {});

      final viewModel = createViewModel();

      await tester.pumpWidget(buildTestApp(viewModel));
      await tester.pump();

      await tester.tap(find.byIcon(CupertinoIcons.arrow_down_left));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      verify(() => mockImportExportUseCase.importRecipes('')).called(1);
    });
  });
}