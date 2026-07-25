import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuzzy_search_engine/fuzzy_search_engine.dart';

import '../../../data/repositories/ingredient/ingredient_repository.dart';
import '../../../data/repositories/ingredient/ingredient_units_repository.dart';
import '../../../domain/models/ingredient/ingredient.dart';
import '../../../domain/models/ingredient/ingredient_types.dart';
import '../../../domain/models/ingredient/ingredient_units.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

const searchConfig = SearchConfig(fuzzyEnabled: true, caseSensitive: false, maxResults: 15);

class IngredientsUtilsViewModel extends ChangeNotifier {
  IngredientsUtilsViewModel({
    required IngredientRepository ingredientRepository,
    IngredientUnitsRepository? ingredientUnitsRepository,
  }) : _ingredientRepository = ingredientRepository,
       _ingredientUnitsRepository = ingredientUnitsRepository {
    loadIngredients = Command0(_loadIngredients)..execute();
    updateIngredient = Command1(_updateIngredient);
  }

  final IngredientRepository _ingredientRepository;
  final IngredientUnitsRepository? _ingredientUnitsRepository;

  late final Command0<void> loadIngredients;
  late final Command1<void, Ingredient> updateIngredient;

  StreamSubscription? _newIngredientSubscription;
  StreamSubscription? _updatedIngredientSubscription;
  StreamSubscription? _deleteIngredientSubscription;
  ValueNotifier<int> updatedIngredient = ValueNotifier(0);

  late final List<Ingredient> _ingredients;
  late List<SearchableItem> _searchableIngredient;
  List<Ingredient> _filteredIngredients = [];

  late final Map<String, IngredientUnit> _ingredientUnitsByName;
  late final RegExp _ingredientRegex;

  List<IngredientTypes> get ingredientTypes =>
      _ingredientRepository.ingredientTypes.values.toList();

  List<SearchableItem> _getSearchableIngredients() {
    return List<SearchableItem>.generate(
      _ingredients.length,
      (int index) =>
          SearchableItem(id: _ingredients[index].id.toString(), name: _ingredients[index].name),
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

        _initSubscriptions();

        return Result.ok(null);
      case Error<List<Ingredient>>():
        return Result.error(result.error);
    }
  }

  Future<void> _loadIngredientUnits() async {
    if (_ingredientUnitsRepository == null) {
      return;
    }
    await _ingredientUnitsRepository.loadIngredientUnits();
    _ingredientUnitsByName = _ingredientUnitsRepository.ingredientUnitsByName;
    _ingredientRegex = RegExp(
      r'^(?<quantity>[\d./,]*)?\s*(?:(?<unit>' +
          _formatIngredientTypesForRegex() +
          r")\s+)?(?:de |d')?(?<name>.*)",
    );
    print(_ingredientRegex.pattern);
  }

  void _initSubscriptions(){
    _newIngredientSubscription ??= _ingredientRepository.newIngredientStream.stream
        .listen(_handleNewIngredientStream);
    _updatedIngredientSubscription ??= _ingredientRepository.updateIngredientStream.stream
        .listen(_handleUpdatedIngredientStream);
    _deleteIngredientSubscription ??= _ingredientRepository.deleteIngredientStream.stream
        .listen(_handleDeletedIngredientStream);
  }

  void _handleNewIngredientStream(Ingredient newIngredient) async {
    if (!_ingredients.contains(newIngredient)) {
      _ingredients.add(newIngredient);
    }
    final searchable = SearchableItem(id: newIngredient.id.toString(), name: newIngredient.name);
    if (!_searchableIngredient.contains(searchable)) {
      _searchableIngredient.add(searchable);
    }
  }

  void _handleUpdatedIngredientStream(Ingredient ingredient) async {
    int index = _ingredients.indexWhere((ingredient_) => ingredient_.id == ingredient.id);
    if (index > -1) {
      _ingredients[index] = ingredient;
    }
    final indexFiltered = _filteredIngredients.indexWhere((element) => element.id == ingredient.id);
    if (indexFiltered > -1) {
      _filteredIngredients[indexFiltered] = ingredient;
      updatedIngredient.value++;
    }
  }

  void _handleDeletedIngredientStream(Ingredient ingredient) async {
    _ingredients.removeWhere((ingredient_) => ingredient_.id == ingredient.id);
    _filteredIngredients.removeWhere((element) => element.id == ingredient.id);
    notifyListeners();
  }

  Future<Result<void>> _updateIngredient(Ingredient ingredient) async {
    late final Result<void> result;
    if (ingredient.id == null) {
      result = Result.ok(null);
    } else {
      result = await _ingredientRepository.updateIngredient(ingredient);
      final index = _ingredients.indexWhere((element) => element.id == ingredient.id);
      _ingredients[index] = ingredient;
    }

    final indexFiltered = _filteredIngredients.indexWhere((element) => element.id == ingredient.id);
    if (indexFiltered > -1) {
      _filteredIngredients[indexFiltered] = ingredient;
    }
    return result;
  }

  String _formatIngredientTypesForRegex() {
    return _ingredientUnitsByName.keys.toList().join('|');
  }

  IngredientSearchResult handleSearch(String value) {
    final match = _ingredientRegex.firstMatch(value);

    if (match == null) {
      throw IngredientSearchError('This should never happen');
    }

    int quantity = int.parse(match.namedGroup('quantity')?.replaceAll(',', '.') ?? '1');
    IngredientUnit unit =
        _ingredientUnitsByName[match.namedGroup('unit')] ?? defaultIngredientUnit.copyWith();
    _filteredIngredients = filterIngredients(match.namedGroup('name')?.trim());

    return IngredientSearchResult(_filteredIngredients, quantity, unit);
  }

  List<Ingredient> filterIngredients(String? ingredientName) {
    late List<Ingredient> filteredIngredients;
    if (ingredientName == null || ingredientName.isEmpty) {
      filteredIngredients = List.from(_ingredients);
      filteredIngredients.sort(compareIngredientName);
    } else {
      final results = SearchEngine.search(
        _searchableIngredient,
        ingredientName,
        config: searchConfig,
      );
      filteredIngredients = _formatResultsFromSearch(results);
      if (ingredientIsNew(ingredientName, filteredIngredients)) {
        filteredIngredients.insert(
          0,
          Ingredient(name: ingredientName, type: _ingredientRepository.ingredientTypes[15]!),
        );
      }
    }
    return List.from(filteredIngredients);
  }

  bool ingredientIsNew(String ingredient, List<Ingredient> filteredIngredients) {
    return filteredIngredients.indexWhere((element) => element.name == ingredient) == -1;
  }

  List<Ingredient> _formatResultsFromSearch(List<SearchableItem> results) {
    final ingredients = List<Ingredient>.generate(
      results.length,
      (index) => _ingredients.where((item) => item.id == int.parse(results[index].id)).first,
    );
    return ingredients;
  }

  @override
  void dispose() {
    _newIngredientSubscription?.cancel();
    _updatedIngredientSubscription?.cancel();
    _deleteIngredientSubscription?.cancel();
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
