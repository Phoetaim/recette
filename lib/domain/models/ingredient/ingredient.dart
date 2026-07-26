import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:recette/data/services/models/raw_ingredient.dart';

import 'ingredient_types.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    int? id,

    required String name,
    @JsonKey(toJson: ingredientTypeToJson, fromJson: IngredientTypes.fromJson)
    @Default(IngredientTypes(id: 0, name: 'other', color: 4292269782))
    IngredientTypes type,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, Object?> json) => _$IngredientFromJson(json);
}

Map<String, dynamic> ingredientToJson(Ingredient ingredient) => ingredient.toJson();

int compareIngredientType(Ingredient ingredient1, Ingredient ingredient2) =>
    ingredient1.type.name.compareTo(ingredient2.type.name);

int compareIngredientName(Ingredient ingredient1, Ingredient ingredient2) =>
    ingredient1.name.compareTo(ingredient2.name);

final compareIngredients = compareIngredientType.then(compareIngredientName);

RawIngredient convertIngredientToRawIngredient(Ingredient ingredient) {
  return RawIngredient(id: ingredient.id, name: ingredient.name, type: ingredient.type.id!);
}
