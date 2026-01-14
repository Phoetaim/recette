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
  unit:
      $enumDecodeNullable(_$IngredientUnitEnumMap, json['unit']) ??
      IngredientUnit.unit,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$IngredientWithQuantityToJson(
  _IngredientWithQuantity instance,
) => <String, dynamic>{
  'id': instance.id,
  'ingredient': instance.ingredient,
  'unit': _$IngredientUnitEnumMap[instance.unit]!,
  'quantity': instance.quantity,
};

const _$IngredientUnitEnumMap = {
  IngredientUnit.unit: 'unit',
  IngredientUnit.kg: 'kg',
  IngredientUnit.g: 'g',
  IngredientUnit.L: 'L',
  IngredientUnit.dL: 'dL',
  IngredientUnit.cL: 'cL',
  IngredientUnit.mL: 'mL',
  IngredientUnit.cm: 'cm',
  IngredientUnit.tranche: 'tranche',
  IngredientUnit.boite: 'boite',
  IngredientUnit.cac: 'cac',
  IngredientUnit.cas: 'cas',
};
