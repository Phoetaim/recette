// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShoppingIngredient _$ShoppingIngredientFromJson(Map<String, dynamic> json) =>
    _ShoppingIngredient(
      id: (json['id'] as num?)?.toInt(),
      bought: json['bought'] as bool? ?? false,
      ingredient: IngredientWithQuantity.fromJson(
        json['ingredient'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ShoppingIngredientToJson(_ShoppingIngredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bought': instance.bought,
      'ingredient': instance.ingredient,
    };
