import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:recette/domain/use_cases/recipe_utils.dart';
import 'package:recette/utils/result.dart';

class MockIngredientWithQuantityUseCase extends Mock implements IngredientWithQuantityUseCase {}

class MockShoppingListRepository extends Mock implements ShoppingListRepository {}

// Common test data
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

void main() {
  late MockIngredientWithQuantityUseCase mockIngredientWithQuantityUseCase;
  late MockShoppingListRepository mockShoppingListRepository;
  late RecipeUtilsUseCase recipeUtilsUseCase;

  setUpAll(() {
    registerFallbackValue(<int>[]);
    registerFallbackValue(IngredientWithQuantity(ingredient: ingredient1));
  });

  setUp(() {
    mockIngredientWithQuantityUseCase = MockIngredientWithQuantityUseCase();
    mockShoppingListRepository = MockShoppingListRepository();
    recipeUtilsUseCase = RecipeUtilsUseCase(
      ingredientWithQuantityUseCase: mockIngredientWithQuantityUseCase,
      shoppingListRepository: mockShoppingListRepository,
    );
  });

  group('loadRecipe', () {
    test('Successfully loads recipe with all ingredients and steps', () async {
      const rawRecipe = RawRecipe(
        id: 1,
        name: 'Soupe',
        nbOfPeople: 4,
        preparationTime: '15 min',
        cookingTime: '30 min',
        ingredientWithQuantityIds: [1, 2],
        steps: 'Étape 1: Préparer\nÉtape 2: Cuire\nÉtape 3: Servir',
      );

      final ingredientMaps = [ingredientWithQuantity1.toJson(), ingredientWithQuantity2.toJson()];

      when(
        () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds([1, 2]),
      ).thenAnswer((_) async => Result.ok(ingredientMaps));

      final recipe = await recipeUtilsUseCase.loadRecipe(rawRecipe);

      expect(recipe.id, 1);
      expect(recipe.name, 'Soupe');
      expect(recipe.nbOfPeople, 4);
      expect(recipe.preparationTime, '15 min');
      expect(recipe.cookingTime, '30 min');
      expect(recipe.ingredients, [ingredientWithQuantity1, ingredientWithQuantity2]);
      expect(recipe.steps, ['Étape 1: Préparer', 'Étape 2: Cuire', 'Étape 3: Servir']);
    });

    test('Correctly splits steps by newline', () async {
      const rawRecipe = RawRecipe(
        id: 2,
        name: 'Tarte',
        ingredientWithQuantityIds: [],
        steps: 'Step A\nStep B\nStep C\nStep D',
      );

      when(
        () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds([]),
      ).thenAnswer((_) async => const Result.ok([]));

      final recipe = await recipeUtilsUseCase.loadRecipe(rawRecipe);

      expect(recipe.steps, ['Step A', 'Step B', 'Step C', 'Step D']);
    });

    test('Returns empty ingredient list when ingredient loading fails', () async {
      const rawRecipe = RawRecipe(
        id: 3,
        name: 'Gâteau',
        ingredientWithQuantityIds: [1, 2, 3],
        steps: 'Step 1\nStep 2',
      );

      when(
        () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds([1, 2, 3]),
      ).thenAnswer((_) async => Result.error(Exception('Repository error')));

      final recipe = await recipeUtilsUseCase.loadRecipe(rawRecipe);

      expect(recipe.id, 3);
      expect(recipe.name, 'Gâteau');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.steps, ['Step 1', 'Step 2']);
    });

    test('Removes ingredientWithQuantityIds from JSON during conversion', () async {
      const rawRecipe = RawRecipe(
        id: 4,
        name: 'Pizza',
        ingredientWithQuantityIds: [1],
        steps: 'Mix\nBake',
      );

      final ingredientMaps = [ingredientWithQuantity1.toJson()];

      when(
        () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds([1]),
      ).thenAnswer((_) async => Result.ok(ingredientMaps));

      final recipe = await recipeUtilsUseCase.loadRecipe(rawRecipe);

      // The recipe should not have ingredientWithQuantityIds in its fields
      expect(recipe.id, 4);
      expect(recipe.name, 'Pizza');
      // Verify by converting back to JSON that ingredientWithQuantityIds is gone
      final recipeJson = recipe.toJson();
      expect(recipeJson.containsKey('ingredientWithQuantityIds'), isFalse);
    });

    test('Handles recipe with no ingredients', () async {
      const rawRecipe = RawRecipe(
        id: 5,
        name: 'Eau chaude',
        ingredientWithQuantityIds: [],
        steps: 'Chauffer\nVerser',
      );

      when(
        () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds([]),
      ).thenAnswer((_) async => const Result.ok([]));

      final recipe = await recipeUtilsUseCase.loadRecipe(rawRecipe);

      expect(recipe.ingredients, isEmpty);
      expect(recipe.steps, ['Chauffer', 'Verser']);
    });

    test('Handles recipe with single step (no newlines)', () async {
      const rawRecipe = RawRecipe(
        id: 6,
        name: 'Simple',
        ingredientWithQuantityIds: [],
        steps: 'Just do it',
      );

      when(
        () => mockIngredientWithQuantityUseCase.getIngredientWithQuantityByIds([]),
      ).thenAnswer((_) async => const Result.ok([]));

      final recipe = await recipeUtilsUseCase.loadRecipe(rawRecipe);

      expect(recipe.steps, ['Just do it']);
    });
  });

  group('addRecipeToShoppingList', () {
    test('Successfully adds all ingredients with scaled quantities', () async {
      const recipe = Recipe(
        id: 1,
        name: 'Soupe',
        nbOfPeople: 4,
        ingredients: [ingredientWithQuantity1, ingredientWithQuantity2],
      );

      when(
        () => mockShoppingListRepository.addShoppingIngredient(any()),
      ).thenAnswer((_) async => Result.ok(null));

      final error = await recipeUtilsUseCase.addRecipeToShoppingList(recipe, 8);

      expect(error, isFalse);
      verify(
        () => mockShoppingListRepository.addShoppingIngredient(
          ingredientWithQuantity1.copyWith(quantity: 6), // 3 * 8 / 4 = 6
        ),
      ).called(1);
      verify(
        () => mockShoppingListRepository.addShoppingIngredient(
          ingredientWithQuantity2.copyWith(quantity: 8), // 4 * 8 / 4 = 8
        ),
      ).called(1);
    });

    test('Correctly scales ingredient quantities based on numberOfPeople', () async {
      const recipe = Recipe(
        id: 2,
        name: 'Tarte',
        nbOfPeople: 6,
        ingredients: [ingredientWithQuantity1], // quantity: 3
      );

      when(
        () => mockShoppingListRepository.addShoppingIngredient(any()),
      ).thenAnswer((_) async => Result.ok(null));

      await recipeUtilsUseCase.addRecipeToShoppingList(recipe, 2);

      // Expected: 3 * 2 / 6 = 1
      verify(
        () => mockShoppingListRepository.addShoppingIngredient(
          ingredientWithQuantity1.copyWith(quantity: 1),
        ),
      ).called(1);
    });

    test('Returns false when all ingredients are added successfully', () async {
      const recipe = Recipe(
        id: 3,
        name: 'Gâteau',
        nbOfPeople: 2,
        ingredients: [ingredientWithQuantity1, ingredientWithQuantity2],
      );

      when(
        () => mockShoppingListRepository.addShoppingIngredient(any()),
      ).thenAnswer((_) async => Result.ok(null));

      final error = await recipeUtilsUseCase.addRecipeToShoppingList(recipe, 4);

      expect(error, isFalse);
      verify(() => mockShoppingListRepository.addShoppingIngredient(any())).called(2);
    });

    test('Returns true when any ingredient fails to add', () async {
      const recipe = Recipe(
        id: 4,
        name: 'Pizza',
        nbOfPeople: 2,
        ingredients: [ingredientWithQuantity1, ingredientWithQuantity2],
      );

      // First call succeeds, second call fails
      when(
        () => mockShoppingListRepository.addShoppingIngredient(
          ingredientWithQuantity1.copyWith(quantity: 6),
        ),
      ).thenAnswer((_) async => Result.ok(null));

      when(
        () => mockShoppingListRepository.addShoppingIngredient(
          ingredientWithQuantity2.copyWith(quantity: 8),
        ),
      ).thenAnswer((_) async => Result.error(Exception('Failed to add')));

      final error = await recipeUtilsUseCase.addRecipeToShoppingList(recipe, 4);

      expect(error, isTrue);
      verify(() => mockShoppingListRepository.addShoppingIngredient(any())).called(2);
    });

    test('Returns true when first ingredient fails to add', () async {
      const recipe = Recipe(
        id: 5,
        nbOfPeople: 1,
        ingredients: [ingredientWithQuantity1, ingredientWithQuantity2],
      );

      when(
        () => mockShoppingListRepository.addShoppingIngredient(ingredientWithQuantity1),
      ).thenAnswer((_) async => Result.error(Exception('Failed')));

      when(
        () => mockShoppingListRepository.addShoppingIngredient(ingredientWithQuantity2),
      ).thenAnswer((_) async => Result.ok(null));

      final error = await recipeUtilsUseCase.addRecipeToShoppingList(recipe, 1);

      expect(error, isTrue);
    });

    test('Handles recipe with no ingredients', () async {
      const recipe = Recipe(id: 6, nbOfPeople: 4, ingredients: []);

      final error = await recipeUtilsUseCase.addRecipeToShoppingList(recipe, 2);

      expect(error, isFalse);
      verifyNever(() => mockShoppingListRepository.addShoppingIngredient(any()));
    });

    test('Rounds scaled quantity to nearest int', () async {
      const recipeIngredient = IngredientWithQuantity(
        id: 10,
        ingredient: ingredient1,
        unit: unit,
        quantity: 5, // 5 * 3 / 2 = 7.5, should round to 8
      );

      const recipe = Recipe(id: 7, nbOfPeople: 2, ingredients: [recipeIngredient]);

      when(
        () => mockShoppingListRepository.addShoppingIngredient(any()),
      ).thenAnswer((_) async => Result.ok(null));

      await recipeUtilsUseCase.addRecipeToShoppingList(recipe, 3);

      verify(
        () => mockShoppingListRepository.addShoppingIngredient(
          recipeIngredient.copyWith(quantity: 8), // 5 * 3 / 2 = 7.5 rounds to 8
        ),
      ).called(1);
    });

    test('Continues adding ingredients even if one fails', () async {
      const recipe = Recipe(
        id: 8,
        nbOfPeople: 1,
        ingredients: [ingredientWithQuantity1, ingredientWithQuantity2],
      );

      when(
        () => mockShoppingListRepository.addShoppingIngredient(ingredientWithQuantity1),
      ).thenAnswer((_) async => Result.error(Exception('Failed')));

      when(
        () => mockShoppingListRepository.addShoppingIngredient(ingredientWithQuantity2),
      ).thenAnswer((_) async => Result.ok(null));

      final error = await recipeUtilsUseCase.addRecipeToShoppingList(recipe, 1);

      // Both should be called despite first one failing
      expect(error, isTrue);
      verify(() => mockShoppingListRepository.addShoppingIngredient(any())).called(2);
    });
  });
}
