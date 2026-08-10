import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';
import 'package:recette/utils/result.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockIngredientWithQuantityUseCase extends Mock implements IngredientWithQuantityUseCase {}

class MockImportExportUseCase extends Mock implements ImportExportUseCase {}

class MockRecipeUtilsUseCase extends Mock implements RecipeUtilsUseCase {}

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
  late MockRecipeUtilsUseCase mockRecipeUtilsUseCase;

  setUpAll(() {
    registerFallbackValue(<RawRecipe>[]);
    registerFallbackValue(RawRecipe());
    registerFallbackValue(Recipe());
    registerFallbackValue(const IngredientWithQuantity(ingredient: ingredient1));
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockImportExportUseCase = MockImportExportUseCase();
    mockIngredientWithQuantityUseCase = MockIngredientWithQuantityUseCase();
    mockRecipeUtilsUseCase = MockRecipeUtilsUseCase();
  });

  RecipeDetailViewModel createViewModel() {
    return RecipeDetailViewModel(
      recipeRepository: mockRecipeRepository,
      importExportUseCase: mockImportExportUseCase,
      ingredientWithQuantityUseCase: mockIngredientWithQuantityUseCase,
      recipeUtilsUseCase: mockRecipeUtilsUseCase,
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
        steps: 'Step 1.\nStep 2.',
      );

      when(
        () => mockRecipeRepository.getRecipe(rawRecipe.id!),
      ).thenAnswer((_) async => Result.ok(rawRecipe));

      when(() => mockRecipeUtilsUseCase.loadRecipe(rawRecipe)).thenAnswer((_) async => recipe);

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

      when(() => mockRecipeUtilsUseCase.loadRecipe(rawRecipe)).thenAnswer((_) async => recipe);

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
  });

  group('Saving recipe', () {
    test('Saving a new recipe', () async {
      const rawRecipe = RawRecipe(id: 1);

      when(
        () => mockRecipeRepository.addRecipe(any()),
      ).thenAnswer((_) async => Result.ok(rawRecipe));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();

      viewModel.saveRecipe.execute(const Recipe());
      await flushMicrotasks();

      expect(viewModel.saveRecipe.completed, isTrue);
      verify(() => mockRecipeRepository.addRecipe(any())).called(1);
    });

    test('Saving an existing recipe', () async {
      const recipe = Recipe(id: 1);

      when(() => mockRecipeRepository.updateRecipe(any())).thenAnswer((_) async => Result.ok(null));

      final viewModel = createViewModel();
      viewModel.recipe.value = recipe;

      viewModel.saveRecipe.execute(recipe);
      await flushMicrotasks();

      expect(viewModel.saveRecipe.completed, isTrue);
      verifyNever(() => mockRecipeRepository.updateRecipe(any()));
    });

    test('Saving with new ingredients', () async {
      const newIngredient = IngredientWithQuantity(
        id: -1,
        ingredient: ingredient1,
        unit: unit,
        quantity: 2,
      );
      const recipeWithNewIngredient = Recipe(id: 1, ingredients: [newIngredient]);

      const savedIngredient = IngredientWithQuantity(
        id: 10,
        ingredient: ingredient1,
        unit: unit,
        quantity: 2,
      );

      when(
        () => mockIngredientWithQuantityUseCase.addIngredientWithQuantity(any()),
      ).thenAnswer((_) async => Result.ok(savedIngredient));

      when(() => mockRecipeRepository.updateRecipe(any())).thenAnswer((_) async => Result.ok(null));

      final viewModel = createViewModel();
      viewModel.recipe.value = recipeWithNewIngredient;

      viewModel.saveRecipe.execute(recipeWithNewIngredient);
      await flushMicrotasks();

      expect(viewModel.saveRecipe.completed, isTrue);
      verify(() => mockIngredientWithQuantityUseCase.addIngredientWithQuantity(any())).called(1);
    });

    test('Handle error when saving new ingredient fails', () async {
      const newIngredient = IngredientWithQuantity(
        id: -1,
        ingredient: ingredient1,
        unit: unit,
        quantity: 2,
      );
      const recipeWithNewIngredient = Recipe(id: 1, ingredients: [newIngredient]);

      when(
        () => mockIngredientWithQuantityUseCase.addIngredientWithQuantity(any()),
      ).thenAnswer((_) async => Result.error(RecipeRepositoryError('Save failed')));

      final viewModel = createViewModel();
      viewModel.recipe.value = recipeWithNewIngredient;

      viewModel.saveRecipe.execute(recipeWithNewIngredient);
      await flushMicrotasks();

      expect(viewModel.saveRecipe.error, isTrue);
    });
  });

  group('Deleting recipe', () {
    test('Deletes the recipe with a valid id', () async {
      const recipe = Recipe(id: 1);

      when(() => mockRecipeRepository.deleteRecipe(any())).thenAnswer((_) async => Result.ok(null));

      final viewModel = createViewModel();
      viewModel.recipe.value = recipe;

      viewModel.deleteRecipe.execute();
      await flushMicrotasks();

      expect(viewModel.deleteRecipe.completed, isTrue);
      verify(() => mockRecipeRepository.deleteRecipe(1)).called(1);
    });

    test('Does not call delete for recipe without id', () async {
      const recipe = Recipe();

      final viewModel = createViewModel();
      viewModel.recipe.value = recipe;

      viewModel.deleteRecipe.execute();
      await flushMicrotasks();

      expect(viewModel.deleteRecipe.completed, isTrue);
      verifyNever(() => mockRecipeRepository.deleteRecipe(any()));
    });

    test('Handle error when delete fails', () async {
      const recipe = Recipe(id: 1);

      when(
        () => mockRecipeRepository.deleteRecipe(any()),
      ).thenAnswer((_) async => Result.error(RecipeRepositoryError('Delete failed')));

      final viewModel = createViewModel();
      viewModel.recipe.value = recipe;

      viewModel.deleteRecipe.execute();
      await flushMicrotasks();

      expect(viewModel.deleteRecipe.error, isTrue);
    });
  });

  group('Adding recipe to shopping list', () {
    test('Adds recipe to shopping list with scaled quantity', () async {
      const rawRecipe = RawRecipe(id: 1, nbOfPeople: 4, ingredientWithQuantityIds: [1, 2]);
      const recipe = Recipe(
        id: 1,
        nbOfPeople: 4,
        ingredients: [ingredientWithQuantity1, ingredientWithQuantity2],
      );

      when(
        () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => Result.ok(rawRecipe));
      when(() => mockRecipeUtilsUseCase.loadRecipe(rawRecipe)).thenAnswer((_) async => recipe);
      when(() => mockRecipeRepository.updateRecipe(any())).thenAnswer((_) async => Result.ok(null));
      when(
        () => mockRecipeUtilsUseCase.addRecipeToShoppingList(recipe, 8),
      ).thenAnswer((_) async => false);

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('1');
      await flushMicrotasks();

      viewModel.currentNumberOfPeople.value = 8;
      viewModel.addToShoppingList.execute(recipe);
      await flushMicrotasks();

      expect(viewModel.addToShoppingList.completed, isTrue);
      verify(() => mockRecipeUtilsUseCase.addRecipeToShoppingList(recipe, 8)).called(1);
    });

    test('Handle error when adding to shopping list fails', () async {
      const rawRecipe = RawRecipe(id: 1, ingredientWithQuantityIds: [1]);
      const recipe = Recipe(id: 1, ingredients: [ingredientWithQuantity1]);

      when(
        () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => Result.ok(rawRecipe));
      when(() => mockRecipeUtilsUseCase.loadRecipe(rawRecipe)).thenAnswer((_) async => recipe);
      when(() => mockRecipeRepository.updateRecipe(any())).thenAnswer((_) async => Result.ok(null));
      when(
        () => mockRecipeUtilsUseCase.addRecipeToShoppingList(any(), any()),
      ).thenAnswer((_) async => true);

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('1');
      await flushMicrotasks();

      viewModel.addToShoppingList.execute(recipe);
      await flushMicrotasks();

      expect(viewModel.addToShoppingList.error, isTrue);
    });
  });

  group('Exporting recipe', () {
    test('Exports the recipe', () async {
      const rawRecipe = RawRecipe(id: 1);

      when(
        () => mockRecipeRepository.addRecipe(any()),
      ).thenAnswer((_) async => Result.ok(rawRecipe));
      when(() => mockImportExportUseCase.exportRecipes(any())).thenAnswer((_) async {});

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();

      await flushMicrotasks();

      await viewModel.exportRecipe(const Recipe());

      verify(() => mockImportExportUseCase.exportRecipes({rawRecipe.id!})).called(1);
    });
  });
}
