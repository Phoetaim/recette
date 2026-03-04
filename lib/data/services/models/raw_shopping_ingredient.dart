import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_shopping_ingredient.freezed.dart';

part 'raw_shopping_ingredient.g.dart';

@freezed
abstract class RawShoppingIngredient with _$RawShoppingIngredient {
  const factory RawShoppingIngredient({
    int? id,

    required int ingredientWithQuantityId,

    @Default(1) int shoppingListId,

    @Default(0) int bought,
  }) = _RawShoppingIngredient;

  factory RawShoppingIngredient.fromJson(Map<String, Object?> json) => _$RawShoppingIngredientFromJson(json);
}

enum IngredientUnit { unit, kg, gramme, liter, cL }
