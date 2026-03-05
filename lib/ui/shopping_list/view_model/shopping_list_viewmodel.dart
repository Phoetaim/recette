import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recette/data/services/models/raw_shopping_ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/shopping_list/shopping_ingredient.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import '../../../data/repositories/shopping_list/shopping_list_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

typedef ShoppingList = List<ShoppingIngredient>;

class ShoppingListViewModel extends ChangeNotifier {
  ShoppingListViewModel({
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
    required ShoppingListRepository shoppingListRepository,
  }) : _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase,
       _shoppingListRepository = shoppingListRepository {
    initShoppingList = Command0(_initShoppingList)..execute();
  }

  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;
  final ShoppingListRepository _shoppingListRepository;

  final ShoppingList _shoppingList = [];

  ShoppingList get shoppingList =>
      _shoppingList.where((shoppingIngredient) => !shoppingIngredient.bought).toList();
  ShoppingList get shoppingListBought =>
      _shoppingList.where((shoppingIngredient) => shoppingIngredient.bought).toList();

  StreamSubscription? _subscription;
  late final Command0<void> initShoppingList;

  Future<Result<void>> _initShoppingList() async {
    final result = await _shoppingListRepository.getShoppingList();
    switch (result) {
      case Ok<RawShoppingList>():
        RawShoppingList rawShoppingList = result.value;
        rawShoppingList.removeWhere(
          (rawShoppingIngredient) =>
              (_shoppingList.any((ingredient) => ingredient.id == rawShoppingIngredient.id)),
        );
        await _loadShoppingIngredients(rawShoppingList);
        _subscription ??= _shoppingListRepository.updatedShoppingList.stream.listen((
          shoppingIngredient,
        ) {
          _updateCachedShoppingList(shoppingIngredient);
          notifyListeners();
        });
        return Result.ok(null);
      case Error<RawShoppingList>():
        print('RIP: ${result.error}');
        return Result.error(ShoppingIngredientRepositoryError('Could not init shopping list'));
    }
  }

  Future<void> _loadShoppingIngredients(RawShoppingList rawShoppingList) async {
    final List<int> ids = rawShoppingList
        .map((rawShoppingIngredient) => rawShoppingIngredient.ingredientWithQuantityId)
        .toList();
    final result = await _ingredientWithQuantityUseCase.getIngredientWithQuantityByIds(ids);

    switch (result) {
      case Ok<List<Map<Object, Object>>>():
        for (var ingredientWithQuantityMap in result.value) {
          RawShoppingIngredient rawShoppingIngredient = rawShoppingList.firstWhere(
            (element) => element.ingredientWithQuantityId == ingredientWithQuantityMap['id'],
          );
          var rawShoppingIngredientMap = Map<String, Object>.from({
            'id': rawShoppingIngredient.id,
            'bought': rawShoppingIngredient.bought == 1,
            'ingredientWithQuantity': ingredientWithQuantityMap,
          });
          ShoppingIngredient newShoppingIngredient = ShoppingIngredient.fromJson(
            rawShoppingIngredientMap,
          );
          _shoppingList.add(newShoppingIngredient);
        }
        return;
      case Error<List<Map<Object, Object>>>():
        return;
    }
  }

  void _updateCachedShoppingList(ShoppingIngredient shoppingIngredient) {
    int ingredientIndex = _shoppingList.indexWhere(
      (element) => element.id == shoppingIngredient.id,
    );
    if (ingredientIndex == -1) {
      _shoppingList.add(shoppingIngredient);
    } else {
      _shoppingList.removeAt(ingredientIndex);
    }
  }

  Future<void> addToShoppingList(IngredientWithQuantity ingredientWithQuantity) async {
    var result = await _ingredientWithQuantityUseCase.addIngredientWithQuantity(
      ingredientWithQuantity,
    );
    switch (result) {
      case Ok<IngredientWithQuantity>():
        _shoppingListRepository.addShoppingIngredient(result.value);
      case Error<IngredientWithQuantity>():
        print('RIP: ${result.error}');
        return;
    }
  }

  Future<void> updateShoppingIngredientStatus(ShoppingIngredient shoppingIngredient) async {
    if (shoppingIngredient.bought) {
      await addToShoppingList(shoppingIngredient.ingredientWithQuantity);
    } else {
      final result = await _shoppingListRepository.removeShoppingIngredient(shoppingIngredient);
      switch (result) {
        case Ok<void>():
          _shoppingList.remove(shoppingIngredient);
          _shoppingList.add(shoppingIngredient.copyWith(bought: true));
          notifyListeners();
        case Error<void>():
          print('RIP: ${result.error}');
          return;
      }
    }
  }

  Future<void> deleteAllBoughtIngredients() async {
    var result = await _shoppingListRepository.emptyBoughtShoppingList();
    switch (result) {
      case Ok<void>():
        _shoppingList.removeWhere((shoppingIngredient) => shoppingIngredient.bought);
        notifyListeners();
      case Error<void>():
        return;
    }
  }

  void clearShoppingList() async {
    var result = await _shoppingListRepository.emptyShoppingList();
    switch (result) {
      case Ok<void>():
        ShoppingList ingredientsNotBought = List.from(
          _shoppingList.where((shoppingIngredient) => !shoppingIngredient.bought),
        );
        _shoppingList.retainWhere((shoppingIngredient) => shoppingIngredient.bought);
        _shoppingList.addAll(
          ingredientsNotBought.map(
            (shoppingIngredient) => shoppingIngredient.copyWith(bought: true),
          ),
        );
        notifyListeners();
      case Error<void>():
        return;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class ShoppingListError implements Exception {
  String cause;
  ShoppingListError(this.cause);
}
