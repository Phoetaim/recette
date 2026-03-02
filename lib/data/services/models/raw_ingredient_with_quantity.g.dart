// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_ingredient_with_quantity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawIngredientWithQuantity _$RawIngredientWithQuantityFromJson(
  Map<String, dynamic> json,
) => _RawIngredientWithQuantity(
  id: (json['id'] as num?)?.toInt(),
  ingredientId: (json['ingredientId'] as num).toInt(),
  unit:
      $enumDecodeNullable(_$IngredientUnitEnumMap, json['unit']) ??
      IngredientUnit.unit,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$RawIngredientWithQuantityToJson(
  _RawIngredientWithQuantity instance,
) => <String, dynamic>{
  'id': instance.id,
  'ingredientId': instance.ingredientId,
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
