import 'dart:async';

import 'package:recette/data/services/database/database_recipe_planning.dart';
import 'package:recette/domain/models/recipe/recipe_planning.dart';
import 'package:recette/utils/result.dart';

final int startLength = 3;

class RecipePlanningRepository {
  RecipePlanningRepository({required DatabaseRecipePlanningService database})
    : _database = database;

  final DatabaseRecipePlanningService _database;
  StreamController<RecipePlanning> updatedRecipePlanning = StreamController.broadcast();

  Future<Result<List<RecipePlanning>>> getPlannings() async {
    try {
      final recipes = await _database.getRecipePlanning();
      return Result.ok(recipes);
    } on Exception {
      return Result.error(RecipePlanningRepositoryError('Could not retrieve recipe planning'));
    }
  }

  Future<Result<RecipePlanning>> addRecipePlanning(RecipePlanning planning) async {
    try {
      final planningWithId = await _database.addRecipePlanning(planning);
      updatedRecipePlanning.add(planningWithId);
      return Result.ok(planningWithId);
    } on Exception {
      return Result.error(RecipePlanningRepositoryError('Could not add recipe planning'));
    }
  }

  Future<Result<void>> updateRecipePlanning(RecipePlanning planning) async {
    try {
      await _database.updateRecipePlanning(planning);
      updatedRecipePlanning.add(planning);
      return Result.ok(null);
    } on Exception {
      return Result.error(RecipePlanningRepositoryError('Could not update recipe planning'));
    }
  }

  Future<Result<void>> deleteRecipePlanning(int id) async {
    try {
      await _database.deleteRecipePlanning(id);
      return Result.ok(null);
    } on Exception {
      return Result.error(RecipePlanningRepositoryError('Could not update recipe planning'));
    }
  }
}

class RecipePlanningRepositoryError implements Exception {
  String cause;

  RecipePlanningRepositoryError(this.cause);
}
