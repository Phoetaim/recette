// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_with_quantity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientWithQuantity _$IngredientWithQuantityFromJson(
  Map<String, dynamic> json,
) => _IngredientWithQuantity(
  id: (json['id'] as num?)?.toInt(),
  ingredient: Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
  unit: json['unit'] == null
      ? const IngredientUnit(id: 1)
      : IngredientUnit.fromJson(json['unit'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$IngredientWithQuantityToJson(
  _IngredientWithQuantity instance,
) => <String, dynamic>{
  'id': instance.id,
  'ingredient': instance.ingredient,
  'unit': instance.unit,
  'quantity': instance.quantity,
};
