import 'package:freezed_annotation/freezed_annotation.dart';


part 'raw_ingredient_with_quantity.freezed.dart';

part 'raw_ingredient_with_quantity.g.dart';

@freezed
abstract class RawIngredientWithQuantity with _$RawIngredientWithQuantity {
  const factory RawIngredientWithQuantity({
    int? id,

    required int ingredientId,

    @Default(IngredientUnit.unit) IngredientUnit unit,

    @Default(1) int quantity,
  }) = _RawIngredientWithQuantity;

  factory RawIngredientWithQuantity.fromJson(Map<String, Object?> json) => _$RawIngredientWithQuantityFromJson(json);

}

enum IngredientUnit {
  unit,
  kg,
  g,
  L,
  dL,
  cL,
  mL,
  cm,
  tranche,
  boite,
  cac,
  cas,;

  static List<String> listAsString = List.generate(IngredientUnit.values.length, (index) => IngredientUnit.values[index].name);

}