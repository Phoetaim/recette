// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImportData _$ImportDataFromJson(Map<String, dynamic> json) => _ImportData(
  version: (json['version'] as num?)?.toInt() ?? 0,
  rawRecipes:
      (json['rawRecipes'] as List<dynamic>?)
          ?.map((e) => RawRecipe.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isShoppingList: json['isShoppingList'] as bool? ?? false,
  rawIngredientsWithQuantity:
      (json['rawIngredientsWithQuantity'] as List<dynamic>?)
          ?.map(
            (e) =>
                RawIngredientWithQuantity.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  rawIngredients:
      (json['rawIngredients'] as List<dynamic>?)
          ?.map((e) => RawIngredient.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  ingredientUnits:
      (json['ingredientUnits'] as List<dynamic>?)
          ?.map((e) => IngredientUnit.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  ingredientTypes:
      (json['ingredientTypes'] as List<dynamic>?)
          ?.map((e) => IngredientTypes.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ImportDataToJson(_ImportData instance) =>
    <String, dynamic>{
      'version': instance.version,
      'rawRecipes': instance.rawRecipes,
      'isShoppingList': instance.isShoppingList,
      'rawIngredientsWithQuantity': instance.rawIngredientsWithQuantity,
      'rawIngredients': instance.rawIngredients,
      'ingredientUnits': instance.ingredientUnits,
      'ingredientTypes': instance.ingredientTypes,
    };
