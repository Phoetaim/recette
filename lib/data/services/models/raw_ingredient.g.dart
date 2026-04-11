// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawIngredient _$RawIngredientFromJson(Map<String, dynamic> json) =>
    _RawIngredient(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      type: (json['type'] as num?)?.toInt() ?? 15,
    );

Map<String, dynamic> _$RawIngredientToJson(_RawIngredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
    };
