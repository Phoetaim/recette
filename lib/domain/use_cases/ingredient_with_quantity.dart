import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';

import '../../data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import '../../data/repositories/ingredient/ingredient_repository.dart';
import '../../data/services/models/raw_ingredient_with_quantity.dart';
import '../../utils/result.dart';
import '../models/ingredient/ingredient.dart';
import '../models/ingredient/ingredient_with_quantity.dart';

class IngredientWithQuantityUseCase {
  IngredientWithQuantityUseCase({
    required IngredientRepository ingredientRepository,
    required IngredientWithQuantityRepository ingredientWithQuantityRepository,
    required IngredientUnitsRepository ingredientUnitsRepository,
  }) : _ingredientRepository = ingredientRepository,
       _ingredientWithQuantityRepository = ingredientWithQuantityRepository,
       _ingredientUnitsRepository = ingredientUnitsRepository;

  final IngredientRepository _ingredientRepository;
  final IngredientWithQuantityRepository _ingredientWithQuantityRepository;
  final IngredientUnitsRepository _ingredientUnitsRepository;

  Future<Result<List<Map<Object, Object>>>> getIngredientWithQuantityByIds(List<int> ids) async {
    await _ingredientUnitsRepository.loadIngredientUnits();
    var ingredientIdWithQuantityResult = await _ingredientWithQuantityRepository
        .getRawIngredientWithQuantityByIds(ids);
    switch (ingredientIdWithQuantityResult) {
      case Ok<List<RawIngredientWithQuantity>>():
        List<Map<Object, Object>> ingredientWithQuantityMaps = <Map<Object, Object>>[];
        for (var rawIngredientWithQuantity in ingredientIdWithQuantityResult.value) {
          var ingredientResult = await _ingredientRepository.getIngredientById(
            rawIngredientWithQuantity.ingredientId,
          );
          switch (ingredientResult) {
            case Ok<Ingredient>():
              var ingredientWithQuantityMap = Map<String, Object>.from(
                rawIngredientWithQuantity.toJson(),
              );
              ingredientWithQuantityMap['unit'] = _ingredientUnitsRepository.ingredientUnitsById[rawIngredientWithQuantity.unit]!.toJson();
              var ingredientJson = ingredientResult.value.toJson();
              ingredientJson['type'] = ingredientResult.value.type.toJson();
              ingredientWithQuantityMap.addEntries(
                {'ingredient': ingredientJson}.entries,
              );
              ingredientWithQuantityMaps.add(ingredientWithQuantityMap);
            case Error<Ingredient>():
              return Result.error(ingredientResult.error);
          }
        }
        return Result.ok(ingredientWithQuantityMaps);
      case Error<List<RawIngredientWithQuantity>>():
        return Result.error(ingredientIdWithQuantityResult.error);
    }
  }

  Future<Result<IngredientWithQuantity>> addIngredientWithQuantity(
    IngredientWithQuantity ingredientWithQuantity,
  ) async {
    try {
      ingredientWithQuantity = await _ensureIngredientExists(ingredientWithQuantity);
    } on IngredientRepositoryError catch (error) {
      return Result.error(error);
    }
    RawIngredientWithQuantity ingredientIdWithQuantity = RawIngredientWithQuantity(
      quantity: ingredientWithQuantity.quantity,
      unit: ingredientWithQuantity.unit.id!,
      ingredientId: ingredientWithQuantity.ingredient.id!,
    );
    var result = await _ingredientWithQuantityRepository.addRawIngredientWithQuantity(
      ingredientIdWithQuantity,
    );
    switch (result) {
      case Ok<RawIngredientWithQuantity>():
        return Result.ok(ingredientWithQuantity.copyWith(id: result.value.id));
      case Error<RawIngredientWithQuantity>():
        return Result.error(result.error);
    }
  }

  Future<Result<void>> updateIngredientWithQuantity(
      RawIngredientWithQuantity rawIngredientWithQuantity,
      ) async {
    return await _ingredientWithQuantityRepository.updateRawIngredientWithQuantity(
      rawIngredientWithQuantity,
    );
  }

  Future<IngredientWithQuantity> _ensureIngredientExists(
    IngredientWithQuantity ingredientWithQuantity,
  ) async {
    if (ingredientWithQuantity.ingredient.id != null) {
      return ingredientWithQuantity;
    }

    var result = await _ingredientRepository.addIngredient(ingredientWithQuantity.ingredient);
    switch (result) {
      case Ok<Ingredient>():
        return ingredientWithQuantity.copyWith(ingredient: result.value);
      case Error<Ingredient>():
        throw result.error;
    }
  }
}
