import 'package:freezed_annotation/freezed_annotation.dart';


part 'raw_ingredient.freezed.dart';

part 'raw_ingredient.g.dart';

@freezed
abstract class RawIngredient with _$RawIngredient {
  const factory RawIngredient({
    int? id,

    required String name,

    @Default(15) int type,

  }) = _RawIngredient;

  factory RawIngredient.fromJson(Map<String, Object?> json) => _$RawIngredientFromJson(json);
}