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
    removeFromShoppingList = Command1(_removeFromShoppingList);
  }

  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;
  final ShoppingListRepository _shoppingListRepository;

  ShoppingList _shoppingList = [];

  ShoppingList get shoppingList => _shoppingList;
  StreamSubscription? _subscription;
  late final Command0<void> initShoppingList;
  late final Command1<void, ShoppingIngredient> removeFromShoppingList;

  Future<Result<void>> _initShoppingList() async {
    final result = await _shoppingListRepository.getShoppingList();

    switch (result) {
      case Ok<RawShoppingList>():
        RawShoppingList rawShoppingList = result.value;
        rawShoppingList.removeWhere((rawShoppingIngredient) => (_shoppingList.any((ingredient) => ingredient.id == rawShoppingIngredient.id)));
        await _loadShoppingIngredients(rawShoppingList);
        _subscription ??= _shoppingListRepository.updatedShoppingList.stream.listen((shoppingIngredient) {
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
    final List<int> ids = rawShoppingList.map((rawShoppingIngredient) => rawShoppingIngredient.ingredientWithQuantityId).toList();
    final result = await _ingredientWithQuantityUseCase.getIngredientWithQuantityByIds(ids);

    switch (result) {
      case Ok<List<Map<Object, Object>>>():
        for (var ingredientWithQuantityMap in result.value) {
          RawShoppingIngredient rawShoppingIngredient = rawShoppingList.firstWhere((element) => element.ingredientWithQuantityId == ingredientWithQuantityMap['id']);
          var rawShoppingIngredientMap = Map<String, Object>.from(
              {
                'id': rawShoppingIngredient.id,
                'bought': rawShoppingIngredient.bought == 1,
                'ingredientWithQuantity': ingredientWithQuantityMap
              }
          );
          ShoppingIngredient newShoppingIngredient = ShoppingIngredient.fromJson(rawShoppingIngredientMap);
          shoppingList.add(newShoppingIngredient);
        }
        return;
      case Error<List<Map<Object, Object>>>():
        return;
    }

  }

  void _updateCachedShoppingList(ShoppingIngredient shoppingIngredient) {
    int ingredientIndex = _shoppingList.indexWhere((element) => element.id == shoppingIngredient.id);
    if (ingredientIndex == -1){
      _shoppingList.add(shoppingIngredient);
    } else {
    _shoppingList.removeAt(ingredientIndex);
    }
  }

  Future<void> addToShoppingList(
    IngredientWithQuantity ingredientWithQuantity,
  ) async {
    var result = await _ingredientWithQuantityUseCase.addIngredientWithQuantity(
      ingredientWithQuantity,
    );
    switch (result) {
      case Ok<IngredientWithQuantity>():
        _shoppingListRepository.addShoppingIngredient(result.value);
        notifyListeners();
      case Error<IngredientWithQuantity>():
        print('RIP: ${result.error}');
        return;
    }
  }

  Future<Result<void>> _removeFromShoppingList(ShoppingIngredient shoppingIngredient) async {
    notifyListeners();
    return Result.ok(null);
  }

  void clearShoppingList() {
    _shoppingListRepository.emptyShoppingList();
    notifyListeners();
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
