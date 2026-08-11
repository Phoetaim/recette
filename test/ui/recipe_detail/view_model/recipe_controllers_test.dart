import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_controllers.dart';

// Common test data
const ingredientType = IngredientTypes(id: 1, name: 'Légume', color: 123);
const ingredient1 = Ingredient(id: 100, name: 'Carotte', type: ingredientType);
const ingredient2 = Ingredient(id: 101, name: 'Oignon', type: ingredientType);
const unit = IngredientUnit(id: 5, name: 'g');

const ingredientZebra = IngredientWithQuantity(
  id: 1,
  ingredient: Ingredient(id: 100, name: 'Zebra', type: ingredientType),
  unit: unit,
  quantity: 1,
);
const ingredientApple = IngredientWithQuantity(
  id: 2,
  ingredient: Ingredient(id: 101, name: 'Apple', type: ingredientType),
  unit: unit,
  quantity: 2,
);

const defaultIngredient = IngredientWithQuantity(
  id: 1,
  ingredient: ingredient1,
  unit: unit,
  quantity: 1,
);

/// A fully-populated recipe reused across several tests.
const fullRecipe = Recipe(
  id: 1,
  name: 'Soupe de carotte',
  preparationTime: '15 min',
  cookingTime: '30 min',
  nbOfPeople: 4,
  steps: 'Step 1\nStep 2',
  source: 'https://example.com',
);

/// Mounts a minimal [FormField] using [controllers.ingredientsKey] so that
/// `ingredientsKey.currentState` is populated, matching how
/// RecipeDetailIngredientTab wires the key in the real app. Required for any
/// test that reads or drives the ingredients form field state (e.g. calling
/// `.currentState?.didChange(...)`), since a bare GlobalKey has no attached
/// state until a widget using it has actually been built.
Future<void> pumpIngredientsFormField(
    WidgetTester tester,
    RecipeControllers controllers,
    List<IngredientWithQuantity> initialValue,
    ) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Material(
        child: FormField<List<IngredientWithQuantity>>(
          key: controllers.ingredientsKey,
          initialValue: initialValue,
          builder: (state) => const SizedBox.shrink(),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecipeControllers recipeControllers;

  setUp(() {
    recipeControllers = RecipeControllers();
    recipeControllers.initControllers();
  });

  tearDown(() {
    recipeControllers.dispose();
  });

  group('Initialization', () {
    test('Initializes all text controllers', () {
      expect(recipeControllers.recipeNameController, isNotNull);
      expect(recipeControllers.preparationController, isNotNull);
      expect(recipeControllers.cookingController, isNotNull);
      expect(recipeControllers.peopleController, isNotNull);
      expect(recipeControllers.stepsController, isNotNull);
      expect(recipeControllers.sourceController, isNotNull);
    });

    test('Initializes ingredients key', () {
      expect(recipeControllers.ingredientsKey, isNotNull);
    });

    test('Initializes isRecipeUpdated notifier to false', () {
      expect(recipeControllers.isRecipeUpdated.value, isFalse);
    });

    test('Initializes isEditing notifier to false', () {
      expect(recipeControllers.isEditing.value, isFalse);
    });
  });

  group('initControllerValues', () {
    test('Loads all recipe fields into controllers', () {
      recipeControllers.initControllerValues(fullRecipe);

      expect(recipeControllers.recipeNameController.text, 'Soupe de carotte');
      expect(recipeControllers.preparationController.text, '15 min');
      expect(recipeControllers.cookingController.text, '30 min');
      expect(recipeControllers.peopleController.text, '4');
      expect(recipeControllers.stepsController.text, 'Step 1\nStep 2');
      expect(recipeControllers.sourceController.text, 'https://example.com');
    });

    test('Sets isEditing to true for new recipe (id == null)', () {
      recipeControllers.initControllerValues(
        const Recipe(name: 'Nouvelle recette'),
      );

      expect(recipeControllers.isEditing.value, isTrue);
    });

    test('Sets isEditing to false for existing recipe (id != null)', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Recette existante'),
      );

      expect(recipeControllers.isEditing.value, isFalse);
    });

    test('Does not reinitialize if already initialized', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Recette 1'),
      );
      recipeControllers.initControllerValues(
        const Recipe(id: 2, name: 'Recette 2'),
      );

      expect(recipeControllers.recipeNameController.text, 'Recette 1');
    });

    test('Saves original recipe for later restoration', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Ma recette'),
      );
      recipeControllers.recipeNameController.text = 'Changed';

      recipeControllers.cancelEditing();

      expect(recipeControllers.recipeNameController.text, 'Ma recette');
    });

    test('Stores original ingredients sorted by name', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, ingredients: [ingredientZebra, ingredientApple]),
      );

      // After sorting by name: Apple comes before Zebra
      expect(recipeControllers.recipeIngredients[0].ingredient.name, 'Apple');
      expect(recipeControllers.recipeIngredients[1].ingredient.name, 'Zebra');
    });
  });

  group('Editing state', () {
    test('cancelEditing reverts all controller values', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Original', preparationTime: '10 min'),
      );
      recipeControllers.recipeNameController.text = 'Modified';
      recipeControllers.preparationController.text = '20 min';
      recipeControllers.isEditing.value = true;

      recipeControllers.cancelEditing();

      expect(recipeControllers.recipeNameController.text, 'Original');
      expect(recipeControllers.preparationController.text, '10 min');
      expect(recipeControllers.isEditing.value, isFalse);
    });

    test('setOriginalRecipe resets update and editing flags', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Recipe 1'),
      );
      recipeControllers.recipeNameController.text = 'Modified';
      recipeControllers.isRecipeUpdated.value = true;

      recipeControllers.setOriginalRecipe(
        const Recipe(id: 2, name: 'Recipe 2'),
      );

      expect(recipeControllers.isRecipeUpdated.value, isFalse);
      expect(recipeControllers.isEditing.value, isFalse);
    });
  });

  group('getRecipe', () {
    test('Returns a recipe built from current controller values', () {
      recipeControllers.initControllerValues(
        const Recipe(
          id: 1,
          name: 'Original',
          preparationTime: '10 min',
          cookingTime: '20 min',
          nbOfPeople: 4,
          steps: 'Step 1',
          source: 'Book',
        ),
      );

      final result = recipeControllers.getRecipe();

      expect(result.name, 'Original');
      expect(result.preparationTime, '10 min');
      expect(result.cookingTime, '20 min');
      expect(result.nbOfPeople, 4);
      expect(result.steps, 'Step 1');
      expect(result.source, 'Book');
    });

    test('Parses nbOfPeople from the people text field', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, nbOfPeople: 4),
      );
      recipeControllers.peopleController.text = '8';

      expect(recipeControllers.getRecipe().nbOfPeople, 8);
    });

    test('Falls back to default nbOfPeople for a new recipe on invalid input', () {
      recipeControllers.initControllerValues(const Recipe(nbOfPeople: 4));
      recipeControllers.peopleController.text = 'invalid';

      expect(recipeControllers.getRecipe().nbOfPeople, 4);
    });

    test('Falls back to original nbOfPeople for an existing recipe on invalid input', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, nbOfPeople: 6),
      );
      recipeControllers.peopleController.text = 'invalid';

      expect(recipeControllers.getRecipe().nbOfPeople, 6);
    });

    test('Preserves the recipe id', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 42, name: 'Test'),
      );

      expect(recipeControllers.getRecipe().id, 42);
    });

    test('Sorts ingredients by name', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, ingredients: [ingredientZebra, ingredientApple]),
      );

      final result = recipeControllers.getRecipe();

      expect(result.ingredients[0].ingredient.name, 'Apple');
      expect(result.ingredients[1].ingredient.name, 'Zebra');
    });
  });

  group('computeIfRecipeIsUpdated', () {
    test('Detects a name change', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Original'),
      );

      recipeControllers.recipeNameController.text = 'Modified';
      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    test('Detects a preparation time change', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, preparationTime: '10 min'),
      );

      recipeControllers.preparationController.text = '20 min';
      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    test('Detects a cooking time change', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, cookingTime: '30 min'),
      );

      recipeControllers.cookingController.text = '45 min';
      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    test('Detects a people count change', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, nbOfPeople: 4),
      );

      recipeControllers.peopleController.text = '6';
      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    test('Detects a steps change', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, steps: 'Step 1'),
      );

      recipeControllers.stepsController.text = 'Step 1\nStep 2';
      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    test('Detects a source change', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, source: 'Book'),
      );

      recipeControllers.sourceController.text = 'https://example.com';
      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    testWidgets('Detects an ingredient list change', (tester) async {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, ingredients: [defaultIngredient]),
      );
      await pumpIngredientsFormField(tester, recipeControllers, [
        defaultIngredient,
      ]);

      final updatedIngredient = defaultIngredient.copyWith(quantity: 2);
      recipeControllers.ingredientsKey.currentState?.didChange(
        [updatedIngredient],
      );
      await tester.pump();
      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    test('Always returns true for a brand new recipe', () {
      recipeControllers.initControllerValues(const Recipe()); // No id

      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    test('Does nothing before controllers are initialized', () {
      final freshControllers = RecipeControllers()..initControllers();

      freshControllers.recipeNameController.text = 'Something';
      freshControllers.computeIfRecipeIsUpdated();

      expect(freshControllers.isRecipeUpdated.value, isFalse);

      freshControllers.dispose();
    });

    test('Is triggered automatically by controller text changes', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Original'),
      );
      expect(recipeControllers.isRecipeUpdated.value, isFalse);

      // The listener attached in initControllers should fire computeIfRecipeIsUpdated.
      recipeControllers.recipeNameController.text = 'Modified';

      expect(recipeControllers.isRecipeUpdated.value, isTrue);
    });

    test('Stays false when nothing has changed', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Original'),
      );

      recipeControllers.computeIfRecipeIsUpdated();

      expect(recipeControllers.isRecipeUpdated.value, isFalse);
    });
  });

  group('Controller lifecycle', () {
    test('dispose releases all controllers', () {
      // Local, throwaway instance — avoids double-dispose with tearDown()
      final localControllers = RecipeControllers()..initControllers();
      localControllers.dispose();

      // Setting .text (not reading it) is what triggers notifyListeners()
      // internally, which is what actually throws after dispose.
      expect(
            () => localControllers.recipeNameController.text = 'test',
        throwsFlutterError,
      );
    });

    test('resetInitialization allows loading a different recipe', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Recipe 1'),
      );
      expect(recipeControllers.recipeNameController.text, 'Recipe 1');

      recipeControllers.resetInitialization();
      recipeControllers.initControllerValues(
        const Recipe(id: 2, name: 'Recipe 2'),
      );

      expect(recipeControllers.recipeNameController.text, 'Recipe 2');
    });

    test('Supports multiple reset/reinitialize cycles', () {
      const recipes = [
        Recipe(id: 1, name: 'Recipe 1'),
        Recipe(id: 2, name: 'Recipe 2'),
        Recipe(id: 3, name: 'Recipe 3'),
      ];

      for (final recipe in recipes) {
        recipeControllers.resetInitialization();
        recipeControllers.initControllerValues(recipe);
        expect(recipeControllers.recipeNameController.text, recipe.name);
      }
    });
  });

  group('recipeIngredients getter', () {
    testWidgets('Returns the form field value once the form has changed', (
        tester,
        ) async {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, ingredients: [defaultIngredient]),
      );
      await pumpIngredientsFormField(tester, recipeControllers, [
        defaultIngredient,
      ]);

      // Change the form field to a different value than the original
      // ingredients, so the assertion actually proves the getter reads from
      // the form field state rather than falling back to the original list.
      recipeControllers.ingredientsKey.currentState?.didChange([
        ingredientApple,
      ]);
      await tester.pump();

      expect(recipeControllers.recipeIngredients, [ingredientApple]);
    });

    test('Falls back to the original ingredients when no form state is attached', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, ingredients: [defaultIngredient]),
      );

      // No widget has mounted ingredientsKey, so currentState is null and
      // the getter must fall back to the originally stored ingredients.
      expect(recipeControllers.recipeIngredients, [defaultIngredient]);
    });
  });

  group('Change notifications', () {
    test('notifyListeners triggers registered listeners', () {
      bool notified = false;
      recipeControllers.addListener(() => notified = true);

      recipeControllers.notifyListeners();

      expect(notified, isTrue);
    });

    test('isRecipeUpdated listeners are notified when a controller changes', () {
      recipeControllers.initControllerValues(
        const Recipe(id: 1, name: 'Original'),
      );

      bool notified = false;
      recipeControllers.isRecipeUpdated.addListener(() => notified = true);

      recipeControllers.recipeNameController.text = 'Modified';

      expect(notified, isTrue);
    });
  });
}