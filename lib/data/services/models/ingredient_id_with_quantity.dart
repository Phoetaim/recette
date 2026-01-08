import 'package:freezed_annotation/freezed_annotation.dart';


part 'ingredient_id_with_quantity.freezed.dart';

part 'ingredient_id_with_quantity.g.dart';

@freezed
abstract class IngredientIdWithQuantity with _$IngredientIdWithQuantity {
  const factory IngredientIdWithQuantity({
    int? id,

    required int ingredientId,

    @Default(IngredientUnit.unit) IngredientUnit unit,

    @Default(1) int quantity,
  }) = _IngredientIdWithQuantity;

  factory IngredientIdWithQuantity.fromJson(Map<String, Object?> json) => _$IngredientIdWithQuantityFromJson(json);
}

enum IngredientUnit { unit, kg, gramme, liter, cL }