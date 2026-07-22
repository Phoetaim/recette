import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/ingredient/ingredient_types.dart';
import '../../../domain/models/ingredient/ingredient_units.dart';
import 'raw_ingredient.dart';
import 'raw_ingredient_with_quantity.dart';
import 'raw_recipe.dart';

part 'import_data.freezed.dart';
part 'import_data.g.dart';

@freezed
abstract class ImportData with _$ImportData {
  const factory ImportData({
    @Default(0) int version,

    @Default([]) List<RawRecipe> rawRecipes,

    @Default(false) bool isShoppingList,

    @Default([]) List<RawIngredientWithQuantity> rawIngredientsWithQuantity,

    @Default([]) List<RawIngredient> rawIngredients,

    @Default([]) List<IngredientUnit> ingredientUnits,

    @Default([]) List<IngredientTypes> ingredientTypes,
  }) = _ImportData;

  factory ImportData.fromJson(Map<String, Object?> json) => _$ImportDataFromJson(json);
}
