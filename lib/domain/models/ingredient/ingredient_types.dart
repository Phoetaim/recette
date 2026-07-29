import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_types.freezed.dart';

part 'ingredient_types.g.dart';

@freezed
abstract class IngredientTypes with _$IngredientTypes {
  const IngredientTypes._();

  const factory IngredientTypes({int? id, required String name, required int color}) =
      _IngredientTypes;

  factory IngredientTypes.fromJson(Map<String, Object?> json) => _$IngredientTypesFromJson(json);

  CircleAvatar getIcon() {
    return CircleAvatar(backgroundColor: Color(color));
  }
}

Map<String, dynamic> ingredientTypeToJson(IngredientTypes type) => type.toJson();

