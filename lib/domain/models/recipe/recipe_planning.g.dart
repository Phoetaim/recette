// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_planning.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipePlanning _$RecipePlanningFromJson(Map<String, dynamic> json) =>
    _RecipePlanning(
      id: (json['id'] as num?)?.toInt(),
      recipeId: (json['recipeId'] as num).toInt(),
      nbOfPeople: (json['nbOfPeople'] as num).toInt(),
    );

Map<String, dynamic> _$RecipePlanningToJson(_RecipePlanning instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipeId': instance.recipeId,
      'nbOfPeople': instance.nbOfPeople,
    };
