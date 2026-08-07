import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/recipe/recipe.dart';

enum ControllerNames {
  nameController,
  prepController,
  cookingController,
  peopleController,
  stepsController,
}

class RecipeControllers extends ChangeNotifier {
  RecipeControllers();

  final Map<ControllerNames, TextEditingController> _controllers = {};
  final GlobalKey<FormFieldState<List<IngredientWithQuantity>>> ingredientsKey =
      GlobalKey<FormFieldState<List<IngredientWithQuantity>>>();

  late final ValueNotifier<bool> isRecipeUpdated;
  late Recipe _originalRecipe;
  late List<IngredientWithQuantity> _originalIngredients;
  bool _controllersInitialized = false;

  void initControllers() {
    for (var controller in ControllerNames.values) {
      _controllers[controller] = TextEditingController();
      _controllers[controller]!.addListener(computeIfRecipeIsUpdated);
    }
    isRecipeUpdated = ValueNotifier(false);
  }

  TextEditingController get recipeNameController => _controllers[ControllerNames.nameController]!;

  TextEditingController get preparationController => _controllers[ControllerNames.prepController]!;

  TextEditingController get cookingController => _controllers[ControllerNames.cookingController]!;

  TextEditingController get peopleController => _controllers[ControllerNames.peopleController]!;

  TextEditingController get stepsController => _controllers[ControllerNames.stepsController]!;

  void initControllerValues(Recipe recipe) {
    if (_controllersInitialized) return;
    _originalRecipe = recipe;
    recipeNameController.text = recipe.name;
    preparationController.text = recipe.preparationTime;
    cookingController.text = recipe.cookingTime;
    peopleController.text = '${recipe.nbOfPeople}';
    stepsController.text = recipe.steps.join('\n');
    _originalIngredients = List.from(recipe.ingredients)..sort();
    _controllersInitialized = true;
  }

  void setOriginalRecipe(Recipe recipe) {
    _originalRecipe = recipe;
    isRecipeUpdated.value = false;
  }

  List<IngredientWithQuantity> get recipeIngredients =>
      ingredientsKey.currentState?.value ?? _originalIngredients;

  Recipe getRecipe() {
    int nbOfPeople = _originalRecipe.id == null
        ? RawRecipe().nbOfPeople
        : _originalRecipe.nbOfPeople;
    if (peopleController.text.isNotEmpty) {
      try {
        nbOfPeople = int.parse(peopleController.text);
      } on FormatException {
        // Pass
      }
    }
    return Recipe(
      id: _originalRecipe.id,
      name: recipeNameController.text,
      preparationTime: preparationController.text,
      cookingTime: cookingController.text,
      nbOfPeople: nbOfPeople,
      steps: stepsController.text.split('\n'),
      ingredients: List.from(recipeIngredients)..sort(),
    );
  }

  void resetInitialization() {
    _controllersInitialized = false;
  }

  void computeIfRecipeIsUpdated() {
    if (!_controllersInitialized) return;
    final recipe = getRecipe();
    isRecipeUpdated.value =
        _originalRecipe.id == null ||
        recipe != _originalRecipe ||
        !recipe.ingredients.equals(_originalIngredients);
  }

  @override
  void dispose() {
    for (var controller in ControllerNames.values) {
      _controllers[controller]!.dispose();
    }
    isRecipeUpdated.dispose();
    super.dispose();
  }
}
