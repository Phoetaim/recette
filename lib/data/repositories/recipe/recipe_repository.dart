import 'dart:async';

import 'package:recette/utils/result.dart';

import '../../services/database/database_recipe.dart';
import '../../services/models/raw_recipe.dart';

final int startLength = 3;

class RecipeRepository {
  RecipeRepository({required DatabaseRecipeService database}) : _database = database;

  final DatabaseRecipeService _database;
  StreamController<RawRecipe> updatedRecipeList = StreamController.broadcast();


  Future<Result<RawRecipe>> getRecipe(int id) async {
    try {
      final recipe = await _database.getRecipeById(id);
      return Result.ok(recipe);
    } on Exception {
      return Result.error(RecipeRepositoryError('Could not retrieve recipe'));
    }
  }

  Future<Result<List<RawRecipe>>> getRecipeList() async {
    try {
      final recipes = await _database.getRecipeList();
      return Result.ok(recipes);
    } on Exception {
      return Result.error(RecipeRepositoryError('Could not retrieve recipe list'));
    }
  }

  Future<Result<RawRecipe>> addRecipe(RawRecipe recipe) async {
    try {
      final recipeWithId = await _database.insertRecipe(recipe);
      updatedRecipeList.add(recipeWithId);
      return Result.ok(recipeWithId);
    } on Exception {
      return Result.error(RecipeRepositoryError('Could not add recipe'));
    }
  }

  Future<Result<void>> updateRecipe(RawRecipe newRecipe) async {
    try {
      await _database.updateRecipe(newRecipe);
      updatedRecipeList.add(newRecipe);
      return Result.ok(null);
    } on Exception {
      return Result.error(RecipeRepositoryError('Could not update recipe'));
    }
  }

  Future<Result<void>> deleteRecipe(int id) async {
    try {
      await _database.deleteRecipe(id);
      return Result.ok(null);
    } on Exception {
      return Result.error(RecipeRepositoryError('Could not update recipe'));
    }
  }
}

class RecipeRepositoryError implements Exception {
  String cause;
  RecipeRepositoryError(this.cause);
}
