// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_shopping_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawShoppingIngredient _$RawShoppingIngredientFromJson(
  Map<String, dynamic> json,
) => _RawShoppingIngredient(
  id: (json['id'] as num?)?.toInt(),
  ingredientWithQuantityId: (json['ingredientWithQuantityId'] as num).toInt(),
  shoppingList: (json['shoppingList'] as num?)?.toInt() ?? 1,
  bought: json['bought'] as bool? ?? false,
);

Map<String, dynamic> _$RawShoppingIngredientToJson(
  _RawShoppingIngredient instance,
) => <String, dynamic>{
  'id': instance.id,
  'ingredientWithQuantityId': instance.ingredientWithQuantityId,
  'shoppingList': instance.shoppingList,
  'bought': instance.bought,
};
