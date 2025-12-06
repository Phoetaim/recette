import 'package:freezed_annotation/freezed_annotation.dart';

import '../ingredient/ingredient_with_quantity.dart';

part 'shopping_ingredient.freezed.dart';

part 'shopping_ingredient.g.dart';

@freezed
abstract class ShoppingIngredient with _$ShoppingIngredient {
  const factory ShoppingIngredient({
    int? id,

    // If the item is checked
    @Default(false) bool bought,

    // Ingredient def
    required IngredientWithQuantity ingredient,
  }) = _ShoppingIngredient;

  factory ShoppingIngredient.fromJson(Map<String, Object?> json) => _$ShoppingIngredientFromJson(json);
}
