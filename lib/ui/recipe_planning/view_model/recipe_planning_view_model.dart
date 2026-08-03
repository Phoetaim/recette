import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recette/data/repositories/recipe/recipe_planning_repository.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/recipe/recipe_planning.dart';
import 'package:recette/utils/commands.dart';
import 'package:recette/utils/result.dart';

class RecipePlanningViewModel extends ChangeNotifier {
  RecipePlanningViewModel({
    required RecipeRepository recipeRepository,
    required RecipePlanningRepository planningRepository,
  }) : _recipeRepository = recipeRepository,
       _planningRepository = planningRepository {
    loadViewModel = Command0(_loadViewModel)..execute();
    deleteRecipePlanning = Command1(_deleteRecipePlanning);
  }

  final RecipeRepository _recipeRepository;
  final RecipePlanningRepository _planningRepository;
  late List<RecipePlanning> _plannings;
  late List<RawRecipe> _recipes;

  StreamSubscription? _recipeSubscription;
  StreamSubscription? _planningSubscription;

  ValueNotifier<bool> isSelecting = ValueNotifier(false);
  Set<int> selectedRecipes = {};

  List<RecipePlanning> get planning => _plannings;
  late final Command0 loadViewModel;
  late final Command1<void, int> deleteRecipePlanning;

  Future<Result<void>> _loadViewModel() async {
    final resultRecipe = await _loadRecipes();
    switch (resultRecipe) {
      case Ok<void>():
        final resultPlanning = await _loadPlannings();
        return resultPlanning;
      case Error<void>():
        return resultRecipe;
    }
  }

  Future<Result<void>> _loadRecipes() async {
    final result = await _recipeRepository.getRecipeList();
    switch (result) {
      case Ok<List<RawRecipe>>():
        _recipes = result.value;
      case Error<List<RawRecipe>>():
        return Result.error(RecipePlanningError('Could not retrieve recipe list'));
    }
    _recipeSubscription ??= _recipeRepository.updatedRecipeList.stream.listen((recipe) {
      _updateCachedRecipeList(recipe);
      notifyListeners();
    });
    return Result.ok(null);
  }

  Future<Result<void>> _loadPlannings() async {
    final result = await _planningRepository.getPlannings();
    switch (result) {
      case Ok<List<RecipePlanning>>():
        _plannings = result.value;
      case Error<List<RecipePlanning>>():
        return Result.error(RecipePlanningError('Could not retrieve plannings '));
    }
    _planningSubscription ??= _planningRepository.updatedRecipePlanning.stream.listen((planning) {
      _updateCachedPlannings(planning);
      notifyListeners();
    });
    return Result.ok(null);
  }

  void _updateCachedRecipeList(RawRecipe rawRecipe) {
    final int index = _recipes.indexWhere((element) => element.id == rawRecipe.id!);
    if (index == -1) {
      _recipes.add(rawRecipe);
    } else {
      _recipes[index] = rawRecipe;
    }
  }

  void _updateCachedPlannings(RecipePlanning planning) {
    final int index = _plannings.indexWhere((element) => element.id == planning.id!);
    if (index == -1) {
      _plannings.add(planning);
    } else {
      _plannings[index] = planning;
    }
  }

  Future<Result<void>> _deleteRecipePlanning(int id) async {
    final result = await _planningRepository.deleteRecipePlanning(id);
    switch (result) {
      case Ok<void>():
        _recipes.removeWhere((planning) => planning.id == id);
      case Error<void>():
        return Result.error(RecipePlanningError('Could not delete recipe'));
    }
    notifyListeners();
    return Result.ok(null);
  }

  @override
  void dispose() {
    _recipeSubscription?.cancel();
    _planningSubscription?.cancel();
    super.dispose();
  }
}

class RecipePlanningError implements Exception {
  String cause;

  RecipePlanningError(this.cause);
}
