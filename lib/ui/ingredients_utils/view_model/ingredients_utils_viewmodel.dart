import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuzzy_search_engine/fuzzy_search_engine.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import '../../../domain/models/ingredient/ingredient.dart';
import '../../../domain/models/ingredient/ingredient_units.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class IngredientsUtilsViewModel extends ChangeNotifier {
  IngredientsUtilsViewModel({
    required IngredientRepository ingredientRepository,
    required IngredientUnitsRepository ingredientUnitsRepository,
  }) : _ingredientRepository = ingredientRepository,
       _ingredientUnitsRepository = ingredientUnitsRepository {
    loadIngredients = Command0(_loadIngredients)..execute();
    updateIngredient = Command1(_updateIngredient);
  }

  final IngredientRepository _ingredientRepository;
  final IngredientUnitsRepository _ingredientUnitsRepository;

  late final Command0<void> loadIngredients;
  late final Command1<void, Ingredient> updateIngredient;

  StreamSubscription? _subscription;
  late final List<Ingredient> _ingredients;
  late List<SearchableItem> _searchableIngredient;
  late List<Ingredient> _filteredIngredients;
  
  late final Map<String, IngredientUnit> _ingredientUnitsByName;
  late final RegExp _ingredientRegex;

  List<IngredientTypes> get ingredientTypes =>
      _ingredientRepository.ingredientTypes.values.toList();

  List<SearchableItem> _getSearchableIngredients() {
    return List<SearchableItem>.generate(
      _ingredients.length,
      (int index) => SearchableItem(
        id: _ingredients[index].id.toString(),
        name: _ingredients[index].name,
      ),
    );
  }

  Future<Result<void>> _loadIngredients() async {
    await _loadIngredientUnits();
    
    var result = await _ingredientRepository.getIngredients();
    switch (result) {
      case Ok<List<Ingredient>>():
        // gets list of ingredients, not copy of list
        _ingredients = List.from(result.value);
        _searchableIngredient = _getSearchableIngredients();
        _subscription ??= _ingredientRepository.newIngredient.stream.listen((
          newIngredient,
        ) {
          if (!_ingredients.contains(newIngredient)) {
            _ingredients.add(newIngredient);
          }
          final searchable = SearchableItem(
            id: newIngredient.id.toString(),
            name: newIngredient.name,
          );
          if (!_searchableIngredient.contains(searchable)) {
            _searchableIngredient.add(searchable);
          }
        });
        return Result.ok(null);
      case Error<List<Ingredient>>():
        return Result.error(result.error);
    }
  }

  Future<void> _loadIngredientUnits() async {
    await _ingredientUnitsRepository.loadIngredientUnits();
    _ingredientUnitsByName = _ingredientUnitsRepository.ingredientUnitsByName;
    _ingredientRegex = RegExp(
      r'^(?<quantity>[\d./,]*)?\s*(?<unit>' +
          _formatIngredientTypesForRegex() +
          r")?\s*(?:de|d')?\s*(?<name>.*)",
    );
  }
  
  Future<Result<void>> _updateIngredient(Ingredient ingredient) async {
    late final Result<void> result;
    if (ingredient.id == null) {
      result = Result.ok(null);
    } else {
      result = await _ingredientRepository.updateIngredient(ingredient);
      final index = _ingredients.indexWhere(
        (element) => element.id == ingredient.id,
      );
      _ingredients[index] = ingredient;
    }
    final indexFiltered = _filteredIngredients.indexWhere(
      (element) => element.id == ingredient.id,
    );
    _filteredIngredients[indexFiltered] = ingredient;

    notifyListeners();
    return result;
  }
  
  String _formatIngredientTypesForRegex() {
    return _ingredientUnitsByName.keys.toList().join('|');
  }

  IngredientSearchResult filterIngredients(String value) {
    late int quantity;
    IngredientUnit unit = defaultIngredientUnit.copyWith();
    late List<Ingredient> filteredIngredients;
    final match = _ingredientRegex.firstMatch(value);
    if (match == null) {
      quantity = 1;
      final results = SearchEngine.fuzzySearch(_searchableIngredient, value);
      filteredIngredients = _formatResultsFromSearch(results);
    } else {
      quantity = int.parse(
        match.namedGroup('quantity')?.replaceAll(',', '.') ?? '1',
      );
      if (match.namedGroup('unit') != null) {
        unit = _ingredientUnitsByName[match.namedGroup('unit')!]!;
      }
      final ingredient = match.namedGroup('name')?.trim();
      if (ingredient == null || ingredient.isEmpty) {
        filteredIngredients = List.from(_ingredients);
        filteredIngredients.sort(compareIngredientName);
      } else {
        final results = SearchEngine.fuzzySearch(
          _searchableIngredient,
          ingredient,
        );
        filteredIngredients = _formatResultsFromSearch(results);
        if (filteredIngredients.indexWhere(
              (element) => element.name == ingredient,
            ) ==
            -1) {
          filteredIngredients.insert(
            0,
            Ingredient(
              name: ingredient,
              type: _ingredientRepository.ingredientTypes[15]!,
            ),
          );
        }
      }
    }
    _filteredIngredients = List.from(filteredIngredients);
    return IngredientSearchResult(_filteredIngredients, quantity, unit);
  }

  List<Ingredient> _formatResultsFromSearch(List<SearchableItem> results) {
    final ingredients = List<Ingredient>.generate(
      results.length,
      (index) => _ingredients
          .where((item) => item.id == int.parse(results[index].id))
          .first,
    );
    ingredients.sort(compareIngredientName);
    return ingredients;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class IngredientSearchResult {
  List<Ingredient> filteredIngredients;
  int quantity = 1;
  IngredientUnit unit = defaultIngredientUnit.copyWith();

  IngredientSearchResult(this.filteredIngredients, this.quantity, this.unit);
}

class IngredientSearchError implements Exception {
  String cause;

  IngredientSearchError(this.cause);
}
