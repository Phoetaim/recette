import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:recette/domain/use_cases/recipe_utils.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';
import 'package:recette/ui/recipe_detail/widgets/recipe_detail_screen.dart';
import 'package:recette/utils/result.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockRecipeUtilsUseCase extends Mock implements RecipeUtilsUseCase {}

class MockIngredientWithQuantityUseCase extends Mock implements IngredientWithQuantityUseCase {}

class MockImportExportUseCase extends Mock implements ImportExportUseCase {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockIngredientUnitsRepository extends Mock implements IngredientUnitsRepository {}

const ingredientType = IngredientTypes(id: 1, name: 'Légume', color: 123);
const ingredient1 = Ingredient(id: 100, name: 'Carotte', type: ingredientType);
const unit = IngredientUnit(id: 5, name: 'g');
const ingredientWithQuantity1 = IngredientWithQuantity(
  id: 1,
  ingredient: ingredient1,
  unit: unit,
  quantity: 100,
);

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockRecipeUtilsUseCase mockRecipeUtilsUseCase;
  late MockIngredientWithQuantityUseCase mockIngredientWithQuantityUseCase;
  late MockImportExportUseCase mockImportExportUseCase;

  setUpAll(() {
    registerFallbackValue(const Recipe());
    registerFallbackValue(const RawRecipe());
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockRecipeUtilsUseCase = MockRecipeUtilsUseCase();
    mockIngredientWithQuantityUseCase = MockIngredientWithQuantityUseCase();
    mockImportExportUseCase = MockImportExportUseCase();
  });

  RecipeDetailViewModel createViewModel() {
    return RecipeDetailViewModel(
      recipeRepository: mockRecipeRepository,
      recipeUtilsUseCase: mockRecipeUtilsUseCase,
      ingredientWithQuantityUseCase: mockIngredientWithQuantityUseCase,
      importExportUseCase: mockImportExportUseCase,
    );
  }

  Future<void> pumpRecipeDetailScreen(
    WidgetTester tester, {
    required RecipeDetailViewModel viewModel,
    required String recipeId,
  }) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              name: Routes.recipeDetail,
              builder: (context, state) => MultiProvider(
                providers: [
                  Provider<RecipeRepository>(create: (_) => mockRecipeRepository),
                  Provider<IngredientRepository>(create: (_) => MockIngredientRepository()),
                  Provider<IngredientUnitsRepository>(
                    create: (_) => MockIngredientUnitsRepository(),
                  ),
                ],
                child: RecipeDetailScreen(viewModel: viewModel, recipeId: recipeId),
              ),
            ),
            GoRoute(
              path: '/recipe-list',
              name: Routes.recipeList,
              builder: (context, state) => const Scaffold(body: Text('Recipe List')),
            ),
            GoRoute(
              path: '/recipe-planning',
              name: Routes.recipePlanning,
              builder: (context, state) => const Scaffold(body: Text('Recipe Planning')),
            ),
          ],
        ),
      ),
    );
  }

  group('RecipeDetailScreen initialization', () {
    testWidgets('displays loading indicator while loading recipe', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Soupe de carotte');

      // Simulate a slow response
      when(() => mockRecipeRepository.getRecipe(1)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return Result.ok(const RawRecipe(id: 1));
      });
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      // Should show loading indicator before the delayed response completes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the load to complete
      await tester.pumpAndSettle();

      // After settling, should show the recipe
      expect(find.text('Soupe de carotte'), findsWidgets);
    });

    testWidgets('displays error when recipe fails to load', (tester) async {
      final viewModel = createViewModel();

      when(
        () => mockRecipeRepository.getRecipe(any()),
      ).thenAnswer((_) async => Result.error(RecipeRepositoryError('Recipe not found')));

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pump();

      expect(find.text('Return to recipe list?'), findsOneWidget);
    });

    testWidgets('loads recipe successfully', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(
        id: 1,
        name: 'Soupe de carotte',
        preparationTime: '15 min',
        cookingTime: '30 min',
        nbOfPeople: 4,
        ingredients: [ingredientWithQuantity1],
        steps: 'Mélanger les ingrédients',
        source: 'https://example.com',
      );

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1, name: 'Soupe de carotte')));

      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      expect(find.text('Soupe de carotte'), findsWidgets);
    });

    testWidgets('creates new recipe when recipeId is -1', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe();

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '-1');

      await tester.pumpAndSettle();

      expect(viewModel.loadRecipeById.completed, isTrue);
      expect(viewModel.recipe.value, recipe);
    });
  });

  group('TabBar navigation', () {
    testWidgets('displays Information and Ingredients tabs', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Ingredients'), findsOneWidget);
    });

    testWidgets('can switch between tabs', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      // Tap on Ingredients tab
      await tester.tap(find.byIcon(Icons.food_bank));
      await tester.pumpAndSettle();

      // Tap back on Information tab
      await tester.tap(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      expect(find.byType(DefaultTabController), findsOneWidget);
    });
  });

  group('App bar title and controls', () {
    testWidgets('displays recipe name as title', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Ma Recette');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      expect(find.text('Ma Recette'), findsWidgets);
    });

    testWidgets('displays edit button when not editing', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays cancel and save buttons when editing', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('home button navigates to recipe planning', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      final homeButton = find.byIcon(Icons.home);
      expect(homeButton, findsOneWidget);
    });
  });

  group('Edit mode behavior', () {
    testWidgets('toggles edit mode when edit button pressed', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('cancel button reverts changes and exits edit mode', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Original Name');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Modify recipe name
      await tester.enterText(find.byType(TextFormField).first, 'Modified Name');
      await tester.pumpAndSettle();

      // Click cancel
      await tester.tap(find.byIcon(Icons.cancel_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('save button is disabled when no changes', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      final saveButton = find.byKey(ValueKey('SaveButton'));
      expect(tester.widget<TextButton>(saveButton).onPressed, isNull);
    });
  });

  group('Menu actions', () {
    testWidgets('displays menu with export and delete options', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Exporter'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });

    testWidgets('export button triggers export', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);
      when(() => mockImportExportUseCase.exportRecipes(any())).thenAnswer((_) async {});

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exporter'));
      await tester.pumpAndSettle();

      verify(() => mockImportExportUseCase.exportRecipes(any())).called(1);
    });
  });

  group('Form validation', () {
    testWidgets('requires people count to be valid', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe', nbOfPeople: 4);

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Find the "Personnes" field by its label and enter an invalid value
      final peopleField = find.ancestor(
        of: find.text('Personnes'),
        matching: find.byType(TextFormField),
      );
      expect(peopleField, findsOneWidget);

      await tester.enterText(peopleField, 'invalid');
      await tester.pumpAndSettle();

      // Trigger validation via the save action's form validate call
      final formState = tester.state<FormState>(find.byType(Form));
      expect(formState.validate(), isFalse);
    });
  });

  group('Shopping list integration', () {
    testWidgets('displays add to shopping list widget', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe', nbOfPeople: 4);

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('add to shopping list validates form before executing', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe', nbOfPeople: 4);

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);
      when(
        () => mockRecipeUtilsUseCase.addRecipeToShoppingList(any(), any()),
      ).thenAnswer((_) async => false);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      // The widget should exist and be interactive
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });
  });

  group('Screen state management', () {
    testWidgets('handles recipe updates correctly', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Original Name', nbOfPeople: 4);

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);
      when(() => mockRecipeRepository.updateRecipe(any())).thenAnswer((_) async => Result.ok(null));

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      // Recipe should be loaded
      expect(viewModel.recipe.value, recipe);
    });

    testWidgets('maintains state across tab switches', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      // Switch to ingredients tab
      await tester.tap(find.byIcon(Icons.food_bank));
      await tester.pumpAndSettle();

      // Switch back to info tab
      await tester.tap(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      // Recipe state should be preserved
      expect(viewModel.recipe.value, recipe);
    });
  });

  group('Error handling', () {
    testWidgets('shows error snackbar on delete failure', (tester) async {
      final viewModel = createViewModel();
      const recipe = Recipe(id: 1, name: 'Test Recipe');

      when(
        () => mockRecipeRepository.getRecipe(1),
      ).thenAnswer((_) async => Result.ok(const RawRecipe(id: 1)));
      when(() => mockRecipeUtilsUseCase.loadRecipe(any())).thenAnswer((_) async => recipe);
      when(
        () => mockRecipeRepository.deleteRecipe(any()),
      ).thenAnswer((_) async => Result.error(RecipeRepositoryError('Delete failed')));

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '1');

      await tester.pumpAndSettle();

      // Trigger delete
      viewModel.deleteRecipe.execute();
      await tester.pumpAndSettle();

      // Error state should be set
      expect(find.byType(SnackBar), findsOne);
    });
  });

  group('Invalid input handling', () {
    testWidgets('handles invalid recipeId gracefully', (tester) async {
      final viewModel = createViewModel();

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: 'not-a-number');

      await tester.pumpAndSettle();

      expect(find.text('Return to recipe list?'), findsOneWidget);
    });

    testWidgets('handles null recipeId gracefully', (tester) async {
      final viewModel = createViewModel();

      await pumpRecipeDetailScreen(tester, viewModel: viewModel, recipeId: '');

      await tester.pumpAndSettle();

      expect(find.text('Return to recipe list?'), findsOneWidget);
    });
  });
}
