// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_with_quantity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientWithQuantity _$IngredientWithQuantityFromJson(
  Map<String, dynamic> json,
) => _IngredientWithQuantity(
  ingredientId: (json['ingredientId'] as num).toInt(),
  unit:
      $enumDecodeNullable(_$IngredientUnitEnumMap, json['unit']) ??
      IngredientUnit.unit,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$IngredientWithQuantityToJson(
  _IngredientWithQuantity instance,
) => <String, dynamic>{
  'ingredientId': instance.ingredientId,
  'unit': _$IngredientUnitEnumMap[instance.unit]!,
  'quantity': instance.quantity,
};

const _$IngredientUnitEnumMap = {
  IngredientUnit.unit: 'unit',
  IngredientUnit.kg: 'kg',
  IngredientUnit.gramme: 'gramme',
  IngredientUnit.liter: 'liter',
  IngredientUnit.cL: 'cL',
};
