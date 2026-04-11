// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ingredient _$IngredientFromJson(Map<String, dynamic> json) => _Ingredient(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  type: json['type'] == null
      ? const IngredientTypes(id: 0, name: 'other', color: 4292269782)
      : IngredientTypes.fromJson(json['type'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IngredientToJson(_Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
    };
