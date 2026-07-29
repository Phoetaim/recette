import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';

import 'ingredient.dart';

part 'ingredient_with_quantity.freezed.dart';
part 'ingredient_with_quantity.g.dart';

@freezed
abstract class IngredientWithQuantity with _$IngredientWithQuantity {
  const factory IngredientWithQuantity({
    int? id,

    @JsonKey(toJson: ingredientToJson, fromJson: Ingredient.fromJson)
    required Ingredient ingredient,

    @JsonKey(toJson: ingredientUnitToJson, fromJson: IngredientUnit.fromJson)
    @Default(IngredientUnit(id: 1))
    IngredientUnit unit,

    @Default(1) int quantity,
  }) = _IngredientWithQuantity;

  factory IngredientWithQuantity.fromJson(Map<String, Object?> json) =>
      _$IngredientWithQuantityFromJson(json);
}

Map<String, dynamic> ingredientWithQuantityToJson(IngredientWithQuantity ingredientWithQuantity) =>
    ingredientWithQuantity.toJson();

List<Map<String, dynamic>> ingredientWithQuantitiesToJson(
  List<IngredientWithQuantity> ingredientWithQuantities,
) => ingredientWithQuantities
    .map((ingredientWithQuantity) => ingredientWithQuantity.toJson())
    .toList();

List<IngredientWithQuantity> ingredientWithQuantitiesFromJson(
  List<Map<String, dynamic>> ingredientWithQuantitiesMap,
) => ingredientWithQuantitiesMap.map((json) => IngredientWithQuantity.fromJson(json)).toList();

RawIngredientWithQuantity convertToRawIngredientWithQuantity(
  IngredientWithQuantity ingredientWithQuantity,
) {
  return RawIngredientWithQuantity(
    quantity: ingredientWithQuantity.quantity,
    unit: ingredientWithQuantity.unit.id!,
    ingredientId: ingredientWithQuantity.ingredient.id!,
  );
}
