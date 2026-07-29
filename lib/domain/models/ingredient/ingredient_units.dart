import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_units.freezed.dart';

part 'ingredient_units.g.dart';

@freezed
abstract class IngredientUnit with _$IngredientUnit {
  const factory IngredientUnit({int? id, @Default('unit') String name}) =
      _IngredientUnit;

  factory IngredientUnit.fromJson(Map<String, Object?> json) =>
      _$IngredientUnitFromJson(json);
}

Map<String, dynamic> ingredientUnitToJson(IngredientUnit unit) => unit.toJson();

final IngredientUnit defaultIngredientUnit = IngredientUnit(id: 1);
