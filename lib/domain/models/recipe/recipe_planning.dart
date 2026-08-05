import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_planning.freezed.dart';
part 'recipe_planning.g.dart';

@freezed
abstract class RecipePlanning with _$RecipePlanning {
  const factory RecipePlanning({
    int? id,

    int? recipeId,

    String? textRecipe,

    @Default(4) int nbOfPeople,

    @JsonKey(toJson: recipePlanningProgressToJson, fromJson: recipePlanningProgressFromJson)
    @Default(RecipePlanningProgress.planned)
    RecipePlanningProgress progress,

  }) = _RecipePlanning;

  factory RecipePlanning.fromJson(Map<String, Object?> json) => _$RecipePlanningFromJson(json);
}

enum RecipePlanningProgress { completed, planned }

int recipePlanningProgressToJson(RecipePlanningProgress progress) => progress.index;

RecipePlanningProgress recipePlanningProgressFromJson(int progress) =>
    RecipePlanningProgress.values[progress];
