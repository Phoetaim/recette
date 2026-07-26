import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';

part 'shopping_ingredient.freezed.dart';
part 'shopping_ingredient.g.dart';

@freezed
abstract class ShoppingIngredient with _$ShoppingIngredient {
  const factory ShoppingIngredient({
    int? id,

    // If the item is checked
    @Default(false) bool bought,

    // Ingredient def
    @JsonKey(toJson: ingredientWithQuantityToJson, fromJson: IngredientWithQuantity.fromJson)
    required IngredientWithQuantity ingredientWithQuantity,
  }) = _ShoppingIngredient;

  factory ShoppingIngredient.fromJson(Map<String, Object?> json) =>
      _$ShoppingIngredientFromJson(json);
}

int compareShoppingIngredients(
  ShoppingIngredient shoppingIngredient1,
  ShoppingIngredient shoppingIngredient2,
) => compareIngredients(
  shoppingIngredient1.ingredientWithQuantity.ingredient,
  shoppingIngredient2.ingredientWithQuantity.ingredient,
);
