import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_planning.freezed.dart';

part 'recipe_planning.g.dart';

@freezed
abstract class RecipePlanning with _$RecipePlanning {
  const factory RecipePlanning({
    int? id,

   required int recipeId,
   required int nbOfPeople,
  }) = _RecipePlanning;

  factory RecipePlanning.fromJson(Map<String, Object?> json) => _$RecipePlanningFromJson(json);
}
