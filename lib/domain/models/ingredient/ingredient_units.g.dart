// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_units.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientUnit _$IngredientUnitFromJson(Map<String, dynamic> json) =>
    _IngredientUnit(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? 'unit',
    );

Map<String, dynamic> _$IngredientUnitToJson(_IngredientUnit instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
