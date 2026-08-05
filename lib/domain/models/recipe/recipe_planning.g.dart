// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_planning.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipePlanning _$RecipePlanningFromJson(Map<String, dynamic> json) =>
    _RecipePlanning(
      id: (json['id'] as num?)?.toInt(),
      recipeId: (json['recipeId'] as num?)?.toInt(),
      recipeText: json['recipeText'] as String?,
      nbOfPeople: (json['nbOfPeople'] as num?)?.toInt() ?? 4,
      progress: json['progress'] == null
          ? RecipePlanningProgress.planned
          : recipePlanningProgressFromJson((json['progress'] as num).toInt()),
    );

Map<String, dynamic> _$RecipePlanningToJson(_RecipePlanning instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipeId': instance.recipeId,
      'recipeText': instance.recipeText,
      'nbOfPeople': instance.nbOfPeople,
      'progress': recipePlanningProgressToJson(instance.progress),
    };
