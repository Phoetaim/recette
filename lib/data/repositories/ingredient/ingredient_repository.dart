import 'package:recette/utils/result.dart';

class Ingredient {
  Ingredient({required this.id, required this.name});

  int id;
  final String name;
}

final List<String> ingredientNames = [
  'pate brisée',
  'tomates',
  'chèvre',
  'onions',
];

class IngredientRepository {
  List<Ingredient> _ingredientList = [];
  int _sequentialId = 0;
  bool initialized = false;

  void initDb() {
    if (!initialized) {
      for (String ingredientName in ingredientNames) {
        addIngredient(Ingredient(id: 0, name: ingredientName));
      }
      initialized = true;
    }
  }

  List<Ingredient> get getIngredientList => _ingredientList;

  Future<Result<void>> addIngredient(Ingredient ingredient) async {
    ingredient.id = _sequentialId++;
    _ingredientList.add(ingredient);
    return Result.ok(null);
  }

  Future<Result<void>> removeIngredient(Ingredient ingredient) async {
    _ingredientList.removeWhere((item) => item.id == ingredient.id);
    return Result.ok(null);
  }

  Future<Result<Ingredient>> getIngredientbyId(int ingredientId) async {
    try {
      return Result.ok(
        getIngredientList
            .where((ingredient) => ingredient.id == ingredientId)
            .first,
      );
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
