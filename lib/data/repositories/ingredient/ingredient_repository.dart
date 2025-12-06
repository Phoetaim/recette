import 'package:recette/utils/result.dart';

import '../../../domain/ingredient/ingredient.dart';

final List<String> ingredientNames = ['pate brisée', 'tomates', 'chèvre', 'onions'];

class IngredientRepository {
  final List<Ingredient> _ingredientList = [];
  int _sequentialId = 0;
  bool initialized = false;

  Future<void> initDb() async {
    if (!initialized) {
      for (String ingredientName in ingredientNames) {
        addIngredient(Ingredient(id: 0, name: ingredientName));
      }
      initialized = true;
    }
  }

  List<Ingredient> get getIngredientList => _ingredientList;

  Future<Result<void>> addIngredient(Ingredient ingredient) async {
    Ingredient ingredientWithId = ingredient.copyWith(id: _sequentialId++);
    _ingredientList.add(ingredientWithId);
    return Result.ok(null);
  }

  Future<Result<void>> removeIngredient(Ingredient ingredient) async {
    _ingredientList.removeWhere((item) => item.id == ingredient.id);
    return Result.ok(null);
  }

  Future<Result<Ingredient>> getIngredientbyId(int ingredientId) async {
    try {
      return Result.ok(getIngredientList.where((ingredient) => ingredient.id == ingredientId).first);
    } on StateError {
      return Result.error(IngredientRepositoryError('No such ingredient'));
    }
  }

  void resetIngredients() {
    _ingredientList.clear();
  }
}

class IngredientRepositoryError implements Exception {
  String cause;
  IngredientRepositoryError(this.cause);
}
