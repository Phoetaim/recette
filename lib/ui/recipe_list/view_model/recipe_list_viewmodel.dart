import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class RecipeListViewModel extends ChangeNotifier {
  RecipeListViewModel({required RecipeRepository recipeRepository}) : _recipeRepository = recipeRepository {
    loadRecipes = Command0(_loadRecipeList)..execute();
    deleteRecipe = Command1(_deleteRecipe);
  }

  final RecipeRepository _recipeRepository;
  late List<RawRecipe> _recipes;

  StreamSubscription? _subscription;
  List<RawRecipe> get recipes => _recipes;
  late final Command0 loadRecipes;
  late final Command1<void, int> deleteRecipe;

  Future<Result<void>> _loadRecipeList() async {
    final result = await _recipeRepository.getRecipeList();
    switch (result) {
      case Ok<List<RawRecipe>>():
        _recipes = result.value;
      case Error<List<RawRecipe>>():
        return Result.error(RecipeListError('Could not retrieve recipe list'));
    }
    _subscription ??= _recipeRepository.updatedRecipeList.stream.listen((
        recipe,
        ) {
      _updateCachedRecipeList(recipe);
      notifyListeners();
    });
    notifyListeners();
    return Result.ok(null);
  }

  void _updateCachedRecipeList (RawRecipe rawRecipe) {

    final int index = _recipes.indexWhere((element) => element.id == rawRecipe.id!);
    if (index == -1){
      _recipes.add(rawRecipe);
    } else {
      _recipes[index] = rawRecipe;
    }

  }
  Future<Result<void>> _deleteRecipe(int id) async {
    final result = await _recipeRepository.deleteRecipe(id);
    switch (result) {
      case Ok<void>():
        _recipes.removeWhere((rawRecipe) => rawRecipe.id == id);
      case Error<void>():
        return Result.error(RecipeListError('Could not delete recipe'));
    }
    notifyListeners();
    return Result.ok(null);
  }

  RawRecipe getRecipeByIndex(int index) {
    try {
      return recipes[index];
    } on IndexError {
      print('No index $index returning first recipe');
      return recipes[0];
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class RecipeListError implements Exception {
  String cause;
  RecipeListError(this.cause);
}
