import 'package:flutter/material.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import '../../../domain/ingredient/ingredient.dart';
import '../../../domain/recipe/recipe.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class IngredientListViewModel extends ChangeNotifier {
  IngredientListViewModel({required IngredientRepository ingredientRepository})
    : _ingredientRepository = ingredientRepository {
    loadIngredientList = Command0(_loadIngredientList)..execute();
    saveIngredient = Command1(_saveIngredient);
    deleteIngredient = Command1(_deleteIngredient);
  }

  final IngredientRepository _ingredientRepository;

  late final Command0<void> loadIngredientList;
  late final Command1<void, Ingredient> saveIngredient;
  late final Command1<void, Recipe> deleteIngredient;

  late final List<Ingredient> _ingredientList;

  List<Ingredient> get getIngredients => _ingredientList;

  Future<Result<void>> _loadIngredientList() async {
    await _ingredientRepository.initDb();
    _ingredientList = _ingredientRepository.getIngredientList;
    return Result.ok(null);
  }

  Future<Result<void>> _saveIngredient(Ingredient ingredient) async {
    if (ingredient.id == null) {
      return Result.ok(null);
    } else {
      return Result.ok(null);
    }
  }

  Future<Result<void>> _deleteIngredient(Recipe recipe) async {
    notifyListeners();
    return Result.ok(null);
  }
}
