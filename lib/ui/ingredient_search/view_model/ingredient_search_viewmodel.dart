import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuzzy_search_engine/fuzzy_search_engine.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import '../../../data/services/models/raw_ingredient_with_quantity.dart';
import '../../../domain/models/ingredient/ingredient.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

RegExp ingredientRegex = RegExp(
  r'^(?<quantity>[\d./,]*)?\s*(?<unit>' +
      IngredientUnit.listAsString.join('|') +
      r")?\s*(?:de|d')?\s*(?<name>.*)",
);

class IngredientSearchViewModel extends ChangeNotifier {
  IngredientSearchViewModel({required IngredientRepository ingredientRepository})
    : _ingredientRepository = ingredientRepository {
    loadIngredients = Command0(_loadIngredients)..execute();
  }

  final IngredientRepository _ingredientRepository;

  late final Command0<void> loadIngredients;

  StreamSubscription? _subscription;
  late final List<Ingredient> _ingredients;
  late List<SearchableItem> _searchableIngredient;

  List<SearchableItem> _getSearchableIngredients() {
     return List<SearchableItem>.generate(
      _ingredients.length,
          (int index) =>
          SearchableItem(id: _ingredients[index].id.toString(), name: _ingredients[index].name),
    );
  }
  Future<Result<void>> _loadIngredients() async {
    var result = await _ingredientRepository.getIngredients();
    switch (result) {
      case Ok<List<Ingredient>>():
        // gets list of ingredients, not copy of list
        _ingredients = result.value;
        _searchableIngredient = _getSearchableIngredients();
        _subscription ??= _ingredientRepository.newIngredient.stream.listen((
            newIngredient,
            ) {
          final searchable = SearchableItem(id: newIngredient.id.toString(), name: newIngredient.name);
          if (!_searchableIngredient.contains(searchable)) {
            _searchableIngredient.add(SearchableItem(id: newIngredient.id.toString(), name: newIngredient.name));
          }
        });
        return Result.ok(null);
      case Error<List<Ingredient>>():
        return Result.error(result.error);
    }
  }

  IngredientSearchResult filterIngredients(String value) {
    late int quantity;
    late List<Ingredient> filteredIngredients;
    final match = ingredientRegex.firstMatch(value);
    if (match == null) {
      quantity = 1;

      final results = SearchEngine.fuzzySearch(_searchableIngredient, value);
      filteredIngredients = _formatResultsFromSearch(results);
    } else {
      quantity = int.parse(match.namedGroup('quantity')?.replaceAll(',', '.') ?? '1');

      final ingredient = match.namedGroup('name')?.trim();
      if (ingredient == null || ingredient.isEmpty) {
        filteredIngredients = _ingredients;
      } else {
        final results = SearchEngine.fuzzySearch(_searchableIngredient, ingredient);
        filteredIngredients = _formatResultsFromSearch(results);
        if (filteredIngredients.indexWhere((element) => element.name == ingredient) == -1) {
          filteredIngredients.insert(0, Ingredient(name: ingredient));
        }
      }
    }
    return IngredientSearchResult(filteredIngredients, quantity);
  }

  List<Ingredient> _formatResultsFromSearch(List<SearchableItem> results) {
    return List<Ingredient>.generate(
      results.length,
      (index) => _ingredients.where((item) => item.id == int.parse(results[index].id)).first,
    );
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
  IngredientUnit unit = IngredientUnit.unit;
  IngredientSearchResult(this.filteredIngredients, this.quantity);
}

class IngredientSearchError implements Exception {
  String cause;
  IngredientSearchError(this.cause);
}
