import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/repositories/ingredient/ingredient_repository.dart';
import '../../../domain/models/ingredient/ingredient.dart';
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
  late final Command1<void, Ingredient> deleteIngredient;

  StreamSubscription? _updatedIngredientSubscription;

  late List<Ingredient> _ingredients;
  late List<Ingredient> _filteredIngredients;

  List<Ingredient> get filteredIngredients => _filteredIngredients;

  Future<Result<void>> _loadIngredientList() async {
    var result = await _ingredientRepository.getIngredients();
    switch (result) {
      case Ok<List<Ingredient>>():
        _ingredients = result.value;
        _updatedIngredientSubscription ??= _ingredientRepository.updateIngredientStream.stream
            .listen(_handleUpdatedIngredientStream);
        notifyListeners();
        return Result.ok(null);
      case Error<List<Ingredient>>():
        return Result.error(result.error);
    }
  }

  void _handleUpdatedIngredientStream(Ingredient ingredient) async {
    int index = _ingredients.indexWhere((ingredient_) => ingredient_.id == ingredient.id);
    if (index > -1) {
      _ingredients[index] = ingredient;
      notifyListeners();
    }
  }

  void setFilteredIngredients(String filter) {
    if (filter.length < 2) {
      _filteredIngredients = _ingredients;
    } else {
      _filteredIngredients = _ingredients
          .where((ingredient) => ingredient.name.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }
    _filteredIngredients.sort(compareIngredientName);
    notifyListeners();
  }

  Future<Result<void>> _addIngredients() async {
    return Result.ok(null);
  }

  Future<Result<void>> _deleteIngredient(Ingredient ingredient) async {
    final result = await _ingredientRepository.removeIngredient(ingredient);
    switch (result) {
      case Ok<void>():
        _ingredients.removeWhere((element) => element.id == ingredient.id);
        _filteredIngredients.removeWhere((element) => element.id == ingredient.id);
        notifyListeners();
        return Result.ok(null);
      case Error<void>():
        return Result.error(result.error);
    }
  }

  @override
  void dispose() {
    _updatedIngredientSubscription?.cancel();
    super.dispose();
  }
}
