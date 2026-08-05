import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuzzy_search_engine/fuzzy_search_engine.dart';
import 'package:recette/data/repositories/recipe/recipe_planning_repository.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/recipe/recipe_planning.dart';
import 'package:recette/domain/use_cases/recipe_utils.dart';
import 'package:recette/utils/commands.dart';
import 'package:recette/utils/result.dart';

const searchConfig = SearchConfig(fuzzyEnabled: true, caseSensitive: false, maxResults: 15);

class RecipePlanningViewModel extends ChangeNotifier {
  RecipePlanningViewModel({
    required RecipeRepository recipeRepository,
    required RecipePlanningRepository planningRepository,
    required RecipeUtilsUseCase recipeUtilsUseCase,
  }) : _recipeRepository = recipeRepository,
       _planningRepository = planningRepository,
       _recipeUtilsUseCase = recipeUtilsUseCase {
    initViewModel = Command0(_loadViewModel)..execute();
    addRecipePlanning = Command1(_addRecipePlanning);
    deleteRecipePlanning = Command1(_deleteRecipePlanning);
    addPlanningsToShoppingList = Command0(_addPlanningsToShoppingList);
  }

  final RecipeRepository _recipeRepository;
  final RecipePlanningRepository _planningRepository;
  final RecipeUtilsUseCase _recipeUtilsUseCase;
  late List<RecipePlanning> _plannings;
  late List<RawRecipe> _recipes;

  StreamSubscription? _recipeSubscription;
  StreamSubscription? _planningSubscription;

  ValueNotifier<bool> isSelecting = ValueNotifier(false);
  Set<int> selectedRecipes = {};

  List<RecipePlanning> get plannings => _plannings;
  late final Command0 initViewModel;
  late final Command1<void, RecipePlanning> addRecipePlanning;
  late final Command1<void, int> deleteRecipePlanning;
  late final Command0 addPlanningsToShoppingList;

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

  RawRecipe getRecipe(int id) {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);
    if (index == -1) {
      return RawRecipe(name: 'Recipe not found');
    }
    return _recipes[index];
  }

  List<RawRecipe> filterRecipes(String? recipeName) {
    late List<RawRecipe> filteredRecipes;
    if (recipeName == null || recipeName.isEmpty) {
      filteredRecipes = List.from(_recipes);
      filteredRecipes.sort(compareRecipeName);
    } else {
      final results = SearchEngine.search(
        _getSearchableRecipes(),
        recipeName,
        config: searchConfig,
      );
      filteredRecipes = _formatResultsFromSearch(results);
    }
    return List.from(filteredRecipes);
  }

  List<SearchableItem> _getSearchableRecipes() {
    return _recipes
        .map((rawRecipe) => SearchableItem(id: rawRecipe.id.toString(), name: rawRecipe.name))
        .toList();
  }

  List<RawRecipe> _formatResultsFromSearch(List<SearchableItem> results) {
    return results
        .map(
          (result) => (_recipes.where((rawRecipe) => rawRecipe.id == int.parse(result.id))).first,
        )
        .toList();
  }

  Future<Result<void>> _addRecipePlanning(RecipePlanning planning) async {
    final result = await _planningRepository.addRecipePlanning(planning);
    switch (result) {
      case Ok<RecipePlanning>():
        _plannings.add(result.value);
        return Result.ok(null);
      case Error<RecipePlanning>():
        return Result.error(RecipePlanningError('Could not delete recipe planning'));
    }
  }

  Future<Result<void>> _addPlanningsToShoppingList() async {
    bool error = false;
    for (var planning in _getCompactedRecipePlannings()) {
        final result = await _addPlanningToShoppingList(planning);
        if (result is Error<void>) {
          error = true;
      }
    }
    if (error) {
      return Result.error(RecipePlanningError('Could not add all plannings to shopping list'));
    } else {
      return Result.ok(null);
    }
  }

  List<RecipePlanning> _getCompactedRecipePlannings() {
    Map<int, RecipePlanning> compactedPlannings = {};
    for (var planning in _plannings) {
      if (planning.recipeId != null && planning.progress == RecipePlanningProgress.planned) {
        if (compactedPlannings.keys.contains(planning.recipeId)) {
          int newNbOfPeople =
              planning.nbOfPeople + compactedPlannings[planning.recipeId!]!.nbOfPeople;
          compactedPlannings[planning.recipeId!] = planning.copyWith(nbOfPeople: newNbOfPeople);
        } else {
          compactedPlannings[planning.recipeId!] = planning;
        }
      }
    }
    return compactedPlannings.values.toList();
  }

  Future<Result<void>> _addPlanningToShoppingList(RecipePlanning planning) async {
    if (planning.recipeId == null) {
      return Result.ok(null);
    }
    final result = await _recipeRepository.getRecipe(planning.recipeId!);
    switch (result) {
      case Ok<RawRecipe>():
        final recipe = await _recipeUtilsUseCase.loadRecipe(result.value);
        bool error = await _recipeUtilsUseCase.addRecipeToShoppingList(recipe, planning.nbOfPeople);
        if (error) {
          return Result.error(
            RecipePlanningError('Could not add at least 1 ingredient to shopping list'),
          );
        }
        return Result.ok(null);
      case Error<RawRecipe>():
        return Result.error(RecipePlanningError('Could not retrieve recipe'));
    }
  }

  Future<void> toggleRecipePlanningStatus(RecipePlanning planning) async {
    RecipePlanningProgress newProgress;
    switch (planning.progress) {
      case RecipePlanningProgress.planned:
        newProgress = RecipePlanningProgress.completed;
      case RecipePlanningProgress.completed:
        newProgress = RecipePlanningProgress.planned;
    }
    final result = await _planningRepository.updateRecipePlanning(
      planning.copyWith(progress: newProgress),
    );
    switch (result) {
      case Ok<void>():
        final index = _plannings.indexWhere((planning_) => planning_.id == planning.id);
        if (index > -1) {
          _plannings[index] = planning;
        }
      case Error<void>():
      // Pass
    }
  }
  Future<void> deleteAllRecipePlannings() async {
    for (var planning in List.from(_plannings)) {
      await _deleteRecipePlanning(planning.id!);
    }
  }
  Future<Result<void>> _deleteRecipePlanning(int id) async {
    final result = await _planningRepository.deleteRecipePlanning(id);
    switch (result) {
      case Ok<void>():
        _plannings.removeWhere((planning) => planning.id == id);
      case Error<void>():
        return Result.error(RecipePlanningError('Could not delete recipe planning'));
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
