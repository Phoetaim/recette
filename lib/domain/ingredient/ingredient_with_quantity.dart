import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_with_quantity.freezed.dart';

part 'ingredient_with_quantity.g.dart';

@freezed
abstract class IngredientWithQuantity with _$IngredientWithQuantity {
  const factory IngredientWithQuantity({

  required int ingredientId,

  @Default(IngredientUnit.unit) IngredientUnit unit,
  
  @Default(1) int quantity,
  }) = _IngredientWithQuantity;

  factory IngredientWithQuantity.fromJson(Map<String, Object?> json) =>
      _$IngredientWithQuantityFromJson(json);
}



enum IngredientUnit { unit, kg, gramme, liter, cL }