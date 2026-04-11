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

  late List<Ingredient> _ingredients;
  late List<Ingredient> _filteredIngredients;

  List<Ingredient> get getFilteredIngredients => _filteredIngredients;



  Future<Result<void>> _loadIngredientList() async {
    var result = await _ingredientRepository.getIngredients();
    switch (result) {
      case Ok<List<Ingredient>>():
        _ingredients = result.value;
        notifyListeners();
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
    _filteredIngredients.sort(compareIngredientName);
    notifyListeners();
  }

  Future<Result<void>> _addIngredients() async {
    return Result.ok(null);
  }


  Future<Result<void>> _deleteIngredient(Recipe recipe) async {
    notifyListeners();
    return Result.ok(null);
  }
}
