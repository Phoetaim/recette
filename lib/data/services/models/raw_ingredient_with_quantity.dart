import 'package:freezed_annotation/freezed_annotation.dart';


part 'raw_ingredient_with_quantity.freezed.dart';

part 'raw_ingredient_with_quantity.g.dart';

@freezed
abstract class RawIngredientWithQuantity with _$RawIngredientWithQuantity {
  const factory RawIngredientWithQuantity({
    int? id,

    required int ingredientId,

    @Default(1) int unit,

    @Default(1) int quantity,
  }) = _RawIngredientWithQuantity;

  factory RawIngredientWithQuantity.fromJson(Map<String, Object?> json) => _$RawIngredientWithQuantityFromJson(json);

}
