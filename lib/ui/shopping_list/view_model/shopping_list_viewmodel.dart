import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/shopping_list/shopping_ingredient.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import '../../../data/repositories/shopping_list/shopping_list_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

class ShoppingListViewModel extends ChangeNotifier {
  ShoppingListViewModel({
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
    required ShoppingListRepository shoppingListRepository,
  }) : _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase,
       _shoppingListRepository = shoppingListRepository {
    removeFromShoppingList = Command1(_removeFromShoppingList);
  }

  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;
  final ShoppingListRepository _shoppingListRepository;

  ShoppingList get shoppingList => _shoppingListRepository.shoppingList;
  StreamSubscription? _subscription;
  late final Command1<void, ShoppingIngredient> removeFromShoppingList;

  void initShoppingList() async {
    _subscription ??= _shoppingListRepository.updatedShoppingList.stream.listen((value) {
      notifyListeners();
    });
    notifyListeners();
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
    print(dispose);
    _subscription?.cancel();
    super.dispose();
  }
}

class ShoppingListError implements Exception {
  String cause;
  ShoppingListError(this.cause);
}
