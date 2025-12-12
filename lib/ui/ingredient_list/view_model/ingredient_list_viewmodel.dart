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
    addIngredient = Command1(_addIngredient);
    deleteIngredient = Command1(_deleteIngredient);
  }

  final IngredientRepository _ingredientRepository;

  late final Command0<void> loadIngredientList;
  late final Command1<void, Ingredient> addIngredient;
  late final Command1<void, Recipe> deleteIngredient;

  late final List<Ingredient> _ingredients;
  late List<Ingredient> _filteredIngredients;

  List<Ingredient> get getFilteredIngredients => _filteredIngredients;


  Future<Result<void>> _loadIngredientList() async {
    var result = await _ingredientRepository.getIngredients();
    switch (result) {
      case Ok<List<Ingredient>>():
        _ingredients = result.value;
        return Result.ok(null);
      case Error<List<Ingredient>>():
        return Result.error(result.error);
    }
  }

  void setFilteredIngredients(String filter) {
    if (filter.length < 2) {
      _filteredIngredients = _ingredients;
    }
    else {
      _filteredIngredients = _ingredients.where((ingredient)
      => ingredient.name.contains(filter)).toList();
    }
    notifyListeners();
  }

  Future<Result<void>> _addIngredient(Ingredient ingredient) async {
    var result = await _ingredientRepository.addIngredient(ingredient);
    switch (result) {
      case Ok<Ingredient>():
        _ingredients.add(result.value);
        notifyListeners();
        return Result.ok(null);
      case Error<Ingredient>():
        return Result.error(result.error);
    }

  }


  Future<Result<void>> _deleteIngredient(Recipe recipe) async {
    notifyListeners();
    return Result.ok(null);
  }
}
