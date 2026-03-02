// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawRecipe _$RawRecipeFromJson(Map<String, dynamic> json) => _RawRecipe(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String? ?? 'Sans nom',
  preparationTime: json['preparationTime'] as String? ?? '-',
  cookingTime: json['cookingTime'] as String? ?? '-',
  nbOfPeople: (json['nbOfPeople'] as num?)?.toInt() ?? 4,
  ingredientWithQuantityIds:
      (json['ingredientWithQuantityIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  steps:
      (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$RawRecipeToJson(_RawRecipe instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'preparationTime': instance.preparationTime,
      'cookingTime': instance.cookingTime,
      'nbOfPeople': instance.nbOfPeople,
      'ingredientWithQuantityIds': instance.ingredientWithQuantityIds,
      'steps': instance.steps,
    };
