// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImportData {

 List<RawRecipe> get rawRecipes; List<RawShoppingIngredient> get rawShoppingIngredients; List<RawIngredientWithQuantity> get rawIngredientsWithQuantity; List<RawIngredient> get rawIngredients; List<IngredientUnit> get ingredientUnits; List<IngredientTypes> get ingredientTypes;
/// Create a copy of ImportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportDataCopyWith<ImportData> get copyWith => _$ImportDataCopyWithImpl<ImportData>(this as ImportData, _$identity);

  /// Serializes this ImportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportData&&const DeepCollectionEquality().equals(other.rawRecipes, rawRecipes)&&const DeepCollectionEquality().equals(other.rawShoppingIngredients, rawShoppingIngredients)&&const DeepCollectionEquality().equals(other.rawIngredientsWithQuantity, rawIngredientsWithQuantity)&&const DeepCollectionEquality().equals(other.rawIngredients, rawIngredients)&&const DeepCollectionEquality().equals(other.ingredientUnits, ingredientUnits)&&const DeepCollectionEquality().equals(other.ingredientTypes, ingredientTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rawRecipes),const DeepCollectionEquality().hash(rawShoppingIngredients),const DeepCollectionEquality().hash(rawIngredientsWithQuantity),const DeepCollectionEquality().hash(rawIngredients),const DeepCollectionEquality().hash(ingredientUnits),const DeepCollectionEquality().hash(ingredientTypes));

@override
String toString() {
  return 'ImportData(rawRecipes: $rawRecipes, rawShoppingIngredients: $rawShoppingIngredients, rawIngredientsWithQuantity: $rawIngredientsWithQuantity, rawIngredients: $rawIngredients, ingredientUnits: $ingredientUnits, ingredientTypes: $ingredientTypes)';
}


}

/// @nodoc
abstract mixin class $ImportDataCopyWith<$Res>  {
  factory $ImportDataCopyWith(ImportData value, $Res Function(ImportData) _then) = _$ImportDataCopyWithImpl;
@useResult
$Res call({
 List<RawRecipe> rawRecipes, List<RawShoppingIngredient> rawShoppingIngredients, List<RawIngredientWithQuantity> rawIngredientsWithQuantity, List<RawIngredient> rawIngredients, List<IngredientUnit> ingredientUnits, List<IngredientTypes> ingredientTypes
});




}
/// @nodoc
class _$ImportDataCopyWithImpl<$Res>
    implements $ImportDataCopyWith<$Res> {
  _$ImportDataCopyWithImpl(this._self, this._then);

  final ImportData _self;
  final $Res Function(ImportData) _then;

/// Create a copy of ImportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawRecipes = null,Object? rawShoppingIngredients = null,Object? rawIngredientsWithQuantity = null,Object? rawIngredients = null,Object? ingredientUnits = null,Object? ingredientTypes = null,}) {
  return _then(_self.copyWith(
rawRecipes: null == rawRecipes ? _self.rawRecipes : rawRecipes // ignore: cast_nullable_to_non_nullable
as List<RawRecipe>,rawShoppingIngredients: null == rawShoppingIngredients ? _self.rawShoppingIngredients : rawShoppingIngredients // ignore: cast_nullable_to_non_nullable
as List<RawShoppingIngredient>,rawIngredientsWithQuantity: null == rawIngredientsWithQuantity ? _self.rawIngredientsWithQuantity : rawIngredientsWithQuantity // ignore: cast_nullable_to_non_nullable
as List<RawIngredientWithQuantity>,rawIngredients: null == rawIngredients ? _self.rawIngredients : rawIngredients // ignore: cast_nullable_to_non_nullable
as List<RawIngredient>,ingredientUnits: null == ingredientUnits ? _self.ingredientUnits : ingredientUnits // ignore: cast_nullable_to_non_nullable
as List<IngredientUnit>,ingredientTypes: null == ingredientTypes ? _self.ingredientTypes : ingredientTypes // ignore: cast_nullable_to_non_nullable
as List<IngredientTypes>,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportData].
extension ImportDataPatterns on ImportData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportData value)  $default,){
final _that = this;
switch (_that) {
case _ImportData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportData value)?  $default,){
final _that = this;
switch (_that) {
case _ImportData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RawRecipe> rawRecipes,  List<RawShoppingIngredient> rawShoppingIngredients,  List<RawIngredientWithQuantity> rawIngredientsWithQuantity,  List<RawIngredient> rawIngredients,  List<IngredientUnit> ingredientUnits,  List<IngredientTypes> ingredientTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportData() when $default != null:
return $default(_that.rawRecipes,_that.rawShoppingIngredients,_that.rawIngredientsWithQuantity,_that.rawIngredients,_that.ingredientUnits,_that.ingredientTypes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RawRecipe> rawRecipes,  List<RawShoppingIngredient> rawShoppingIngredients,  List<RawIngredientWithQuantity> rawIngredientsWithQuantity,  List<RawIngredient> rawIngredients,  List<IngredientUnit> ingredientUnits,  List<IngredientTypes> ingredientTypes)  $default,) {final _that = this;
switch (_that) {
case _ImportData():
return $default(_that.rawRecipes,_that.rawShoppingIngredients,_that.rawIngredientsWithQuantity,_that.rawIngredients,_that.ingredientUnits,_that.ingredientTypes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RawRecipe> rawRecipes,  List<RawShoppingIngredient> rawShoppingIngredients,  List<RawIngredientWithQuantity> rawIngredientsWithQuantity,  List<RawIngredient> rawIngredients,  List<IngredientUnit> ingredientUnits,  List<IngredientTypes> ingredientTypes)?  $default,) {final _that = this;
switch (_that) {
case _ImportData() when $default != null:
return $default(_that.rawRecipes,_that.rawShoppingIngredients,_that.rawIngredientsWithQuantity,_that.rawIngredients,_that.ingredientUnits,_that.ingredientTypes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportData implements ImportData {
  const _ImportData({final  List<RawRecipe> rawRecipes = const [], final  List<RawShoppingIngredient> rawShoppingIngredients = const [], final  List<RawIngredientWithQuantity> rawIngredientsWithQuantity = const [], final  List<RawIngredient> rawIngredients = const [], final  List<IngredientUnit> ingredientUnits = const [], final  List<IngredientTypes> ingredientTypes = const []}): _rawRecipes = rawRecipes,_rawShoppingIngredients = rawShoppingIngredients,_rawIngredientsWithQuantity = rawIngredientsWithQuantity,_rawIngredients = rawIngredients,_ingredientUnits = ingredientUnits,_ingredientTypes = ingredientTypes;
  factory _ImportData.fromJson(Map<String, dynamic> json) => _$ImportDataFromJson(json);

 final  List<RawRecipe> _rawRecipes;
@override@JsonKey() List<RawRecipe> get rawRecipes {
  if (_rawRecipes is EqualUnmodifiableListView) return _rawRecipes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rawRecipes);
}

 final  List<RawShoppingIngredient> _rawShoppingIngredients;
@override@JsonKey() List<RawShoppingIngredient> get rawShoppingIngredients {
  if (_rawShoppingIngredients is EqualUnmodifiableListView) return _rawShoppingIngredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rawShoppingIngredients);
}

 final  List<RawIngredientWithQuantity> _rawIngredientsWithQuantity;
@override@JsonKey() List<RawIngredientWithQuantity> get rawIngredientsWithQuantity {
  if (_rawIngredientsWithQuantity is EqualUnmodifiableListView) return _rawIngredientsWithQuantity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rawIngredientsWithQuantity);
}

 final  List<RawIngredient> _rawIngredients;
@override@JsonKey() List<RawIngredient> get rawIngredients {
  if (_rawIngredients is EqualUnmodifiableListView) return _rawIngredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rawIngredients);
}

 final  List<IngredientUnit> _ingredientUnits;
@override@JsonKey() List<IngredientUnit> get ingredientUnits {
  if (_ingredientUnits is EqualUnmodifiableListView) return _ingredientUnits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredientUnits);
}

 final  List<IngredientTypes> _ingredientTypes;
@override@JsonKey() List<IngredientTypes> get ingredientTypes {
  if (_ingredientTypes is EqualUnmodifiableListView) return _ingredientTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredientTypes);
}


/// Create a copy of ImportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportDataCopyWith<_ImportData> get copyWith => __$ImportDataCopyWithImpl<_ImportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportData&&const DeepCollectionEquality().equals(other._rawRecipes, _rawRecipes)&&const DeepCollectionEquality().equals(other._rawShoppingIngredients, _rawShoppingIngredients)&&const DeepCollectionEquality().equals(other._rawIngredientsWithQuantity, _rawIngredientsWithQuantity)&&const DeepCollectionEquality().equals(other._rawIngredients, _rawIngredients)&&const DeepCollectionEquality().equals(other._ingredientUnits, _ingredientUnits)&&const DeepCollectionEquality().equals(other._ingredientTypes, _ingredientTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rawRecipes),const DeepCollectionEquality().hash(_rawShoppingIngredients),const DeepCollectionEquality().hash(_rawIngredientsWithQuantity),const DeepCollectionEquality().hash(_rawIngredients),const DeepCollectionEquality().hash(_ingredientUnits),const DeepCollectionEquality().hash(_ingredientTypes));

@override
String toString() {
  return 'ImportData(rawRecipes: $rawRecipes, rawShoppingIngredients: $rawShoppingIngredients, rawIngredientsWithQuantity: $rawIngredientsWithQuantity, rawIngredients: $rawIngredients, ingredientUnits: $ingredientUnits, ingredientTypes: $ingredientTypes)';
}


}

/// @nodoc
abstract mixin class _$ImportDataCopyWith<$Res> implements $ImportDataCopyWith<$Res> {
  factory _$ImportDataCopyWith(_ImportData value, $Res Function(_ImportData) _then) = __$ImportDataCopyWithImpl;
@override @useResult
$Res call({
 List<RawRecipe> rawRecipes, List<RawShoppingIngredient> rawShoppingIngredients, List<RawIngredientWithQuantity> rawIngredientsWithQuantity, List<RawIngredient> rawIngredients, List<IngredientUnit> ingredientUnits, List<IngredientTypes> ingredientTypes
});




}
/// @nodoc
class __$ImportDataCopyWithImpl<$Res>
    implements _$ImportDataCopyWith<$Res> {
  __$ImportDataCopyWithImpl(this._self, this._then);

  final _ImportData _self;
  final $Res Function(_ImportData) _then;

/// Create a copy of ImportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawRecipes = null,Object? rawShoppingIngredients = null,Object? rawIngredientsWithQuantity = null,Object? rawIngredients = null,Object? ingredientUnits = null,Object? ingredientTypes = null,}) {
  return _then(_ImportData(
rawRecipes: null == rawRecipes ? _self._rawRecipes : rawRecipes // ignore: cast_nullable_to_non_nullable
as List<RawRecipe>,rawShoppingIngredients: null == rawShoppingIngredients ? _self._rawShoppingIngredients : rawShoppingIngredients // ignore: cast_nullable_to_non_nullable
as List<RawShoppingIngredient>,rawIngredientsWithQuantity: null == rawIngredientsWithQuantity ? _self._rawIngredientsWithQuantity : rawIngredientsWithQuantity // ignore: cast_nullable_to_non_nullable
as List<RawIngredientWithQuantity>,rawIngredients: null == rawIngredients ? _self._rawIngredients : rawIngredients // ignore: cast_nullable_to_non_nullable
as List<RawIngredient>,ingredientUnits: null == ingredientUnits ? _self._ingredientUnits : ingredientUnits // ignore: cast_nullable_to_non_nullable
as List<IngredientUnit>,ingredientTypes: null == ingredientTypes ? _self._ingredientTypes : ingredientTypes // ignore: cast_nullable_to_non_nullable
as List<IngredientTypes>,
  ));
}


}

// dart format on
