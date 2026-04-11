import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:collection/collection.dart';
import 'ingredient_types.dart';

part 'ingredient.freezed.dart';

part 'ingredient.g.dart';

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    int? id,

    required String name,

    @Default(IngredientTypes(id: 0, name: 'other', color: 4292269782)) IngredientTypes type,

  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, Object?> json) => _$IngredientFromJson(json);
}


int compareIngredientType(Ingredient ingredient1, Ingredient ingredient2) =>
    ingredient1.type.name.compareTo(ingredient2.type.name);

int compareIngredientName(Ingredient ingredient1, Ingredient ingredient2) =>
    ingredient1.name.compareTo(ingredient2.name);

final compareIngredients = compareIngredientType.then(compareIngredientName);


