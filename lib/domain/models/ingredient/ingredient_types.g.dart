// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientTypes _$IngredientTypesFromJson(Map<String, dynamic> json) =>
    _IngredientTypes(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      color: (json['color'] as num).toInt(),
    );

Map<String, dynamic> _$IngredientTypesToJson(_IngredientTypes instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
    };
