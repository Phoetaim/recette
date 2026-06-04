import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:recette/data/services/models/raw_ingredient.dart';
import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/data/services/models/raw_shopping_ingredient.dart' hide IngredientUnit;
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';

part 'import_data.freezed.dart';
part 'import_data.g.dart';

@freezed
abstract class ImportData with _$ImportData {
  const factory ImportData({
    @Default(0) int version,

    @Default([]) List<RawRecipe> rawRecipes,

    @Default([]) List<RawShoppingIngredient> rawShoppingIngredients,

    @Default([]) List<RawIngredientWithQuantity> rawIngredientsWithQuantity,

    @Default([]) List<RawIngredient> rawIngredients,

    @Default([]) List<IngredientUnit> ingredientUnits,

    @Default([]) List<IngredientTypes> ingredientTypes,
  }) = _ImportData;

  factory ImportData.fromJson(Map<String, Object?> json) => _$ImportDataFromJson(json);
}
