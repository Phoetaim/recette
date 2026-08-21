import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/import_data.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/use_cases/import_export.dart';
import 'package:recette/utils/commands.dart';
import 'package:recette/utils/result.dart';

class RecipeListViewModel extends ChangeNotifier {
  RecipeListViewModel({
    required RecipeRepository recipeRepository,
    required ImportExportUseCase importExportUseCase,
  }) : _recipeRepository = recipeRepository,
       _importExportUseCase = importExportUseCase {
    loadRecipes = Command0(_loadRecipeList)..execute();
    deleteRecipe = Command1(_deleteRecipe);
    importRecipes = Command1(_importRecipes);
    getRawRecipesFromImport = Command1(_getRawRecipesFromImport);
    exportRecipes = Command0(_exportRecipes);
  }

  final RecipeRepository _recipeRepository;
  final ImportExportUseCase _importExportUseCase;
  late List<RawRecipe> _recipes;
  late ImportData _importData;

  StreamSubscription? _subscription;

  ValueNotifier<bool> isSelecting = ValueNotifier(false);
  Set<int> selectedRecipes = {};

  List<RawRecipe> get recipes => _recipes;
  List<RawRecipe> get recipesToImport => _importData.rawRecipes;
  late final Command0 loadRecipes;
  late final Command1<void, int> deleteRecipe;
  late final Command1<void, Set<int>> importRecipes;
  late final Command1<void, String> getRawRecipesFromImport;
  late final Command0<void> exportRecipes;

  Future<Result<void>> _loadRecipeList() async {
    final result = await _recipeRepository.getRecipeList();
    switch (result) {
      case Ok<List<RawRecipe>>():
        _recipes = result.value;
      case Error<List<RawRecipe>>():
        return Result.error(RecipeListError('Could not retrieve recipe list'));
    }
    _subscription ??= _recipeRepository.updatedRecipeList.stream.listen((recipe) {
      _updateCachedRecipeList(recipe);
      notifyListeners();
    });
    notifyListeners();
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
      return recipes[0];
    }
  }

  Future<Result<void>> _importRecipes(Set<int> recipeIds) async {
    await _importExportUseCase.importRecipes(_importData, recipeIds);
    return Result.ok(null);
  }

  Future<Result<void>> _getRawRecipesFromImport(String recipeBase64) async {
    
    final result = await _importExportUseCase.loadImportData(recipeBase64);
    switch (result){
      case Ok<ImportData>():
    _importData = result.value;
    notifyListeners();
    return Result.ok(null);
      case Error<ImportData>():
        return result;
    }
  }

  Future<Result<void>> _exportRecipes() async {
    await _importExportUseCase.exportRecipes(selectedRecipes);
    quitSelection();
    return Result.ok(null);
  }

  void enterSelection(int id) {
    selectedRecipes.add(id);
    isSelecting.value = true;
  }

  void updateSelection(int id) {
    if (!selectedRecipes.remove(id)) {
      selectedRecipes.add(id);
    }
    notifyListeners();
  }

  void toggleSelectionAll() {
    selectedRecipes = _recipes.map((element) => element.id!).toSet();
    notifyListeners();
  }

  void clearSelection() {
    selectedRecipes.clear();
    notifyListeners();
  }

  void quitSelection() {
    selectedRecipes.clear();
    isSelecting.value = false;
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
