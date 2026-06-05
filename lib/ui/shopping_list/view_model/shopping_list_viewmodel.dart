import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/services/models/raw_shopping_ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/shopping_list/shopping_ingredient.dart';
import 'package:recette/domain/use_cases/ingredient_with_quantity.dart';
import 'package:synchronized/synchronized.dart';

import '../../../data/repositories/shopping_list/shopping_list_repository.dart';
import '../../../utils/commands.dart';
import '../../../utils/result.dart';

typedef ShoppingList = List<ShoppingIngredient>;

class ShoppingListViewModel extends ChangeNotifier {
  ShoppingListViewModel({
    required IngredientRepository ingredientRepository,
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
    required ShoppingListRepository shoppingListRepository,
  }) : _ingredientRepository = ingredientRepository,
       _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase,
       _shoppingListRepository = shoppingListRepository {
    initShoppingList = Command0(_initShoppingList)..execute();
  }

  final IngredientRepository _ingredientRepository;
  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;
  final ShoppingListRepository _shoppingListRepository;

  StreamSubscription<ShoppingIngredient>? _newShoppingIngredientSubscription;
  StreamSubscription<Ingredient>? _updatedIngredientSubscription;
  StreamSubscription? _deleteIngredientSubscription;

  var shoppingListLock = Lock();
  final ShoppingList _shoppingList = [];

  ShoppingList get shoppingList =>
      _shoppingList.where((shoppingIngredient) => !shoppingIngredient.bought).toList();

  ShoppingList get shoppingListBought =>
      _shoppingList.where((shoppingIngredient) => shoppingIngredient.bought).toList();

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

        _initSubscriptions();

        return Result.ok(null);
      case Error<RawShoppingList>():
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
          await shoppingListLock.synchronized(() async {
            _shoppingList.add(newShoppingIngredient);
          });
        }
        return;
      case Error<List<Map<Object, Object>>>():
        return;
    }
  }

  void _initSubscriptions() {
    _updatedIngredientSubscription ??= _ingredientRepository.updateIngredientStream.stream.listen(
      _handleUpdatedIngredientStream,
    );
    _newShoppingIngredientSubscription ??= _shoppingListRepository.updatedShoppingList.stream
        .listen(_handleNewShoppingIngredientStream);
    _deleteIngredientSubscription ??= _ingredientRepository.deleteIngredientStream.stream.listen(
      _handleDeletedIngredientStream,
    );
  }

  void _handleUpdatedIngredientStream(Ingredient ingredient) async {
    List<int> indexList = [];
    for (int index = 0; index < _shoppingList.length; index++) {
      if (_shoppingList[index].ingredientWithQuantity.ingredient.id == ingredient.id) {
        indexList.add(index);
      }
    }
    if (indexList.isNotEmpty) {
      await shoppingListLock.synchronized(() async {
        for (int ingredientIndex in indexList) {
          _shoppingList[ingredientIndex] = _shoppingList[ingredientIndex].copyWith(
            ingredientWithQuantity: _shoppingList[ingredientIndex].ingredientWithQuantity.copyWith(
              ingredient: ingredient,
            ),
          );
        }
      });
      notifyListeners();
    }
  }

  void _handleDeletedIngredientStream(Ingredient ingredient) async {
    await shoppingListLock.synchronized(() async {
      _shoppingList.removeWhere(
        ((element) => element.ingredientWithQuantity.ingredient.id == ingredient.id),
      );
    });
    notifyListeners();
  }

  void _handleNewShoppingIngredientStream(ShoppingIngredient shoppingIngredient) async {
    await shoppingListLock.synchronized(() async {
      int ingredientIndex = _shoppingList.indexWhere(
        (element) => element.id == shoppingIngredient.id,
      );
      if (ingredientIndex == -1) {
        _shoppingList.add(shoppingIngredient);
      } else {
        _shoppingList[ingredientIndex] = shoppingIngredient;
      }
    });
    notifyListeners();
  }

  Future<Result<void>> addToShoppingList(IngredientWithQuantity ingredientWithQuantity) async {
    return _shoppingListRepository.addShoppingIngredient(ingredientWithQuantity);
  }

  Future<void> toggleShoppingIngredientStatus(ShoppingIngredient shoppingIngredient) async {
    ShoppingIngredient newShoppingIngredient = shoppingIngredient.copyWith(
      bought: !shoppingIngredient.bought,
    );
    final result = await _shoppingListRepository.toggleShoppingIngredientStatus(
      newShoppingIngredient,
    );
    switch (result) {
      case Ok<void>():
        await shoppingListLock.synchronized(() async {
          _shoppingList.remove(shoppingIngredient);
          _shoppingList.add(newShoppingIngredient);
        });
        notifyListeners();
      case Error<void>():
        return;
    }
  }

  Future<void> deleteAllBoughtIngredients() async {
    var result = await _shoppingListRepository.emptyBoughtShoppingList();
    switch (result) {
      case Ok<void>():
        await shoppingListLock.synchronized(() async {
          _shoppingList.removeWhere((shoppingIngredient) => shoppingIngredient.bought);
        });
        notifyListeners();
      case Error<void>():
        return;
    }
  }

  Future<void> deleteShoppingIngredient(ShoppingIngredient shoppingIngredient) async {
    var result = await _shoppingListRepository.deleteShoppingIngredient(shoppingIngredient.id!);
    switch (result) {
      case Ok<void>():
        await shoppingListLock.synchronized(() async {
          _shoppingList.removeWhere((element) => element.id == shoppingIngredient.id);
        });
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
    _newShoppingIngredientSubscription?.cancel();
    _updatedIngredientSubscription?.cancel();
    super.dispose();
  }
}

class ShoppingListError implements Exception {
  String cause;

  ShoppingListError(this.cause);
}
