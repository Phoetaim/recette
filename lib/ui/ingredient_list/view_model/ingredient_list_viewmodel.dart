import 'package:flutter/material.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import '../../../domain/models/ingredient/ingredient.dart';
import '../../../domain/models/recipe/recipe.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class IngredientListViewModel extends ChangeNotifier {
  IngredientListViewModel({required IngredientRepository ingredientRepository})
    : _ingredientRepository = ingredientRepository {
    loadIngredientList = Command0(_loadIngredientList)..execute();
    addIngredients = Command0(_addIngredients);
    deleteIngredient = Command1(_deleteIngredient);
  }

  final IngredientRepository _ingredientRepository;

  late final Command0<void> loadIngredientList;
  late final Command0<void> addIngredients;
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
      => ingredient.name.toLowerCase().contains(filter.toLowerCase())).toList();
    }
    notifyListeners();
  }

  Future<Result<void>> _addIngredients() async {
    List<String> ingredients = ['patates', 'carottes', 'ognons', 'patatartiner'];
    for (var ingredient in ingredients) {
      var result = await _ingredientRepository.addIngredient(Ingredient(name: ingredient));
    switch (result) {
      case Ok<Ingredient>():
        _ingredients.add(result.value);
        notifyListeners();
      case Error<Ingredient>():
        // Skipp
    }
    }
    return Result.ok(null);
  }


  Future<Result<void>> _deleteIngredient(Recipe recipe) async {
    notifyListeners();
    return Result.ok(null);
  }
}
