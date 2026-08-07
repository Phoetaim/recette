// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recipe _$RecipeFromJson(Map<String, dynamic> json) => _Recipe(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String? ?? 'Sans nom',
  preparationTime: json['preparationTime'] as String? ?? '-',
  cookingTime: json['cookingTime'] as String? ?? '-',
  nbOfPeople: (json['nbOfPeople'] as num?)?.toInt() ?? 4,
  ingredients: json['ingredients'] == null
      ? const []
      : ingredientWithQuantitiesFromJson(
          json['ingredients'] as List<Map<String, dynamic>>,
        ),
  steps: json['steps'] as String? ?? '',
  source: json['source'] as String? ?? '',
);

Map<String, dynamic> _$RecipeToJson(_Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'preparationTime': instance.preparationTime,
  'cookingTime': instance.cookingTime,
  'nbOfPeople': instance.nbOfPeople,
  'ingredients': ingredientWithQuantitiesToJson(instance.ingredients),
  'steps': instance.steps,
  'source': instance.source,
};
