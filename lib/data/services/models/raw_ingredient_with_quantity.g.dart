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
  unit: (json['unit'] as num?)?.toInt() ?? 1,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$RawIngredientWithQuantityToJson(
  _RawIngredientWithQuantity instance,
) => <String, dynamic>{
  'id': instance.id,
  'ingredientId': instance.ingredientId,
  'unit': instance.unit,
  'quantity': instance.quantity,
};
