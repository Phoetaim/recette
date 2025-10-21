// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ingredient _$IngredientFromJson(Map<String, dynamic> json) => _Ingredient(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  type:
      $enumDecodeNullable(_$IngredientTypeEnumMap, json['type']) ??
      IngredientType.other,
);

Map<String, dynamic> _$IngredientToJson(_Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$IngredientTypeEnumMap[instance.type]!,
    };

const _$IngredientTypeEnumMap = {
  IngredientType.other: 'other',
  IngredientType.fruits: 'fruits',
  IngredientType.meat: 'meat',
  IngredientType.house: 'house',
};
