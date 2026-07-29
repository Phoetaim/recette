import 'package:recette/data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';
import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/utils/result.dart';

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

  Future<Result<List<Map<String, dynamic>>>> getIngredientWithQuantityByIds(List<int> ids) async {
    await _ingredientUnitsRepository.loadIngredientUnits();
    var ingredientIdWithQuantityResult = await _ingredientWithQuantityRepository
        .getRawIngredientWithQuantityByIds(ids);
    switch (ingredientIdWithQuantityResult) {
      case Ok<List<RawIngredientWithQuantity>>():
        List<Map<String, dynamic>> ingredientWithQuantityMaps = <Map<String, dynamic>>[];
        for (var rawIngredientWithQuantity in ingredientIdWithQuantityResult.value) {
          var ingredientResult = await _ingredientRepository.getIngredientById(
            rawIngredientWithQuantity.ingredientId,
          );
          switch (ingredientResult) {
            case Ok<Ingredient>():
              var ingredientWithQuantityMap = Map<String, dynamic>.from(
                rawIngredientWithQuantity.toJson(),
              );
              ingredientWithQuantityMap['unit'] = _ingredientUnitsRepository
                  .ingredientUnitsById[rawIngredientWithQuantity.unit]!
                  .toJson();
              ingredientWithQuantityMap.addEntries(
                {'ingredient': ingredientResult.value.toJson()}.entries,
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
    final ingredientIdWithQuantity = convertToRawIngredientWithQuantity(ingredientWithQuantity);
    final result = await _ingredientWithQuantityRepository.addRawIngredientWithQuantity(
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
