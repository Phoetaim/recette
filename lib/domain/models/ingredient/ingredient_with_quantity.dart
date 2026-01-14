import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/services/models/raw_ingredient_with_quantity.dart';
import 'ingredient.dart';

part 'ingredient_with_quantity.freezed.dart';

part 'ingredient_with_quantity.g.dart';

@freezed
abstract class IngredientWithQuantity with _$IngredientWithQuantity {
  const factory IngredientWithQuantity({
    int? id,

    required Ingredient ingredient,

    @Default(IngredientUnit.unit) IngredientUnit unit,

    @Default(1) int quantity,
  }) = _IngredientWithQuantity;

  factory IngredientWithQuantity.fromJson(Map<String, Object?> json) => _$IngredientWithQuantityFromJson(json);
}

