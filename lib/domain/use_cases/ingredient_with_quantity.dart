import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/services/models/ingredient_id_with_quantity.dart';
import 'package:recette/utils/result.dart';

import '../../data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import '../models/ingredient/ingredient.dart';
import '../models/ingredient/ingredient_with_quantity.dart';

class IngredientWithQuantityUseCase {
  IngredientWithQuantityUseCase({
    required IngredientRepository ingredientRepository,
    required IngredientIdWithQuantityRepository ingredientIdWithQuantityRepository
  }) : _ingredientRepository = ingredientRepository,
        _ingredientIdWithQuantityRepository = ingredientIdWithQuantityRepository;

  final IngredientRepository _ingredientRepository;
  final IngredientIdWithQuantityRepository _ingredientIdWithQuantityRepository;

  Future<Result<IngredientWithQuantity>> getIngredientWithQuantity(int id) async {
    var ingredientIdWithQuantityResult = await _ingredientIdWithQuantityRepository.getIngredientIdWithQuantityById(id);
    switch (ingredientIdWithQuantityResult) {
      case Ok<IngredientIdWithQuantity>():
        IngredientIdWithQuantity ingredientIdWithQuantity = ingredientIdWithQuantityResult.value;
        var ingredientResult = await _ingredientRepository.getIngredientById(ingredientIdWithQuantity.ingredientId);
        switch (ingredientResult) {
          case Ok<Ingredient>():
            var ingredientIdInJson = ingredientIdWithQuantity.toJson() as Map<String, Object>;
            ingredientIdInJson.addEntries({'ingredient': ingredientResult.value}.entries);
            return Result.ok(IngredientWithQuantity.fromJson(ingredientIdInJson));
          case Error<Ingredient>():
            return Result.error(ingredientResult.error);
        }
      case Error<IngredientIdWithQuantity>():
        return Result.error(ingredientIdWithQuantityResult.error);
    }
  }
}
