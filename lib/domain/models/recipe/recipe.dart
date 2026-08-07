import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
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

    @JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson)
    @Default([])
    List<IngredientWithQuantity> ingredients,

    /// e.g. ['Prépare la tarte', 'Cuis la']
    @Default(['']) List<String> steps,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(json);
}

RawRecipe convertToRawRecipe(Recipe recipe) {
  return RawRecipe(
    id: recipe.id,
    name: recipe.name,
    preparationTime: recipe.preparationTime,
    cookingTime: recipe.cookingTime,
    nbOfPeople: recipe.nbOfPeople,
    ingredientWithQuantityIds: recipe.ingredients.map((ingredient) => ingredient.id!).toList(),
    steps: recipe.steps.join('\n'),
  );
}