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
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockImportExportUseCase = MockImportExportUseCase();
    mockIngredientWithQuantityUseCase = MockIngredientWithQuantityUseCase();
    mockShoppingListRepository = MockShoppingListRepository();
    updatedRecipeListController = StreamController<RawRecipe>.broadcast();

    when(() => mockRecipeRepository.updatedRecipeList).thenReturn(updatedRecipeListController);

    // Comportement par défaut : chargement réussi avec une liste vide.
    // Les tests qui ont besoin d'un contenu spécifique redéfinissent ce stub.
    when(
      () => mockRecipeRepository.getRecipeList(),
    ).thenAnswer((_) async => Result.ok(<RawRecipe>[]));
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

  group('Chargement de la recette', () {
    test('charge de la recette complète avec succès à la création', () async {
      const nbOfPeople = 10;
      final rawRecipe = const RawRecipe(
        id: 1,
        name: 'Soupe',
        nbOfPeople: nbOfPeople,
        preparationTime: '10h',
        cookingTime: '10h',
        ingredientWithQuantityIds: [1, 2],
        steps: 'Étape 1.\nÉtape 2.',
      );

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

      const recipe = Recipe(
        id: 1,
        name: 'Soupe',
        nbOfPeople: nbOfPeople,
        preparationTime: '10h',
        cookingTime: '10h',
        ingredients: [ingredientWithQuantity1, ingredientWithQuantity2],
        steps: ['Étape 1.', 'Étape 2.'],
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

    test('Instanciation d\' nouvelle recette fonctionne', () async {
      const recipe = Recipe();
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('-1');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.completed, isTrue);
      expect(viewModel.recipe.value, recipe);
      expect(viewModel.currentNumberOfPeople.value, recipe.nbOfPeople);
    });

    test('charge de la recette par défaut avec succès à la création', () async {
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

    test('Mauvais paramètre d\'entree', () async {
      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('not a number');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.error, isTrue);
    });

    test('L\'id de la recette n\'existe pas', () async {
      when(
        () => mockRecipeRepository.getRecipe(any(that: equals(1))),
      ).thenAnswer((_) async => Result.error(RecipeRepositoryError('Recipe does not exists')));

      final viewModel = createViewModel();
      viewModel.loadRecipeById.execute('1');
      await flushMicrotasks();
      expect(viewModel.loadRecipeById.error, isTrue);
    });

    test('L\'id d\'un ingredient n\'existe pas rend une liste vide', () async {
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
}
