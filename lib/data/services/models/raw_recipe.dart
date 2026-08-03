import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_recipe.freezed.dart';

part 'raw_recipe.g.dart';

@freezed
abstract class RawRecipe with _$RawRecipe {
  const factory RawRecipe({
    /// e.g. 0
    int? id,

    /// e.g. 'Tarte à la tomate'
    @Default('Sans nom') String name,

    /// e.g. '1h'
    @Default('-') String preparationTime,

    /// e.g. '45''
    @Default('-') String cookingTime,

    /// e.g. 4
    @Default(4) int nbOfPeople,

    /// e.g. [1, 323]
    @Default([]) List<int> ingredientWithQuantityIds,

    /// e.g. ['Prépare la tarte', 'Cuis la']
    @Default('') String steps,
  }) = _RawRecipe;

  factory RawRecipe.fromJson(Map<String, Object?> json) => _$RawRecipeFromJson(json);
}

int compareRecipeName(RawRecipe recipe1, RawRecipe recipe2) =>
    recipe1.name.compareTo(recipe2.name);