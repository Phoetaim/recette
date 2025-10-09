// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_with_quantity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngredientWithQuantity {

 int get ingredientId; IngredientUnit get unit; int get quantity;
/// Create a copy of IngredientWithQuantity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientWithQuantityCopyWith<IngredientWithQuantity> get copyWith => _$IngredientWithQuantityCopyWithImpl<IngredientWithQuantity>(this as IngredientWithQuantity, _$identity);

  /// Serializes this IngredientWithQuantity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngredientWithQuantity&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ingredientId,unit,quantity);

@override
String toString() {
  return 'IngredientWithQuantity(ingredientId: $ingredientId, unit: $unit, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $IngredientWithQuantityCopyWith<$Res>  {
  factory $IngredientWithQuantityCopyWith(IngredientWithQuantity value, $Res Function(IngredientWithQuantity) _then) = _$IngredientWithQuantityCopyWithImpl;
@useResult
$Res call({
 int ingredientId, IngredientUnit unit, int quantity
});




}
/// @nodoc
class _$IngredientWithQuantityCopyWithImpl<$Res>
    implements $IngredientWithQuantityCopyWith<$Res> {
  _$IngredientWithQuantityCopyWithImpl(this._self, this._then);

  final IngredientWithQuantity _self;
  final $Res Function(IngredientWithQuantity) _then;

/// Create a copy of IngredientWithQuantity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ingredientId = null,Object? unit = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as IngredientUnit,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [IngredientWithQuantity].
extension IngredientWithQuantityPatterns on IngredientWithQuantity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngredientWithQuantity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngredientWithQuantity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngredientWithQuantity value)  $default,){
final _that = this;
switch (_that) {
case _IngredientWithQuantity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngredientWithQuantity value)?  $default,){
final _that = this;
switch (_that) {
case _IngredientWithQuantity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ingredientId,  IngredientUnit unit,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngredientWithQuantity() when $default != null:
return $default(_that.ingredientId,_that.unit,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ingredientId,  IngredientUnit unit,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _IngredientWithQuantity():
return $default(_that.ingredientId,_that.unit,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ingredientId,  IngredientUnit unit,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _IngredientWithQuantity() when $default != null:
return $default(_that.ingredientId,_that.unit,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IngredientWithQuantity implements IngredientWithQuantity {
  const _IngredientWithQuantity({required this.ingredientId, this.unit = IngredientUnit.unit, this.quantity = 1});
  factory _IngredientWithQuantity.fromJson(Map<String, dynamic> json) => _$IngredientWithQuantityFromJson(json);

@override final  int ingredientId;
@override@JsonKey() final  IngredientUnit unit;
@override@JsonKey() final  int quantity;

/// Create a copy of IngredientWithQuantity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientWithQuantityCopyWith<_IngredientWithQuantity> get copyWith => __$IngredientWithQuantityCopyWithImpl<_IngredientWithQuantity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientWithQuantityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngredientWithQuantity&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ingredientId,unit,quantity);

@override
String toString() {
  return 'IngredientWithQuantity(ingredientId: $ingredientId, unit: $unit, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$IngredientWithQuantityCopyWith<$Res> implements $IngredientWithQuantityCopyWith<$Res> {
  factory _$IngredientWithQuantityCopyWith(_IngredientWithQuantity value, $Res Function(_IngredientWithQuantity) _then) = __$IngredientWithQuantityCopyWithImpl;
@override @useResult
$Res call({
 int ingredientId, IngredientUnit unit, int quantity
});




}
/// @nodoc
class __$IngredientWithQuantityCopyWithImpl<$Res>
    implements _$IngredientWithQuantityCopyWith<$Res> {
  __$IngredientWithQuantityCopyWithImpl(this._self, this._then);

  final _IngredientWithQuantity _self;
  final $Res Function(_IngredientWithQuantity) _then;

/// Create a copy of IngredientWithQuantity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredientId = null,Object? unit = null,Object? quantity = null,}) {
  return _then(_IngredientWithQuantity(
ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as IngredientUnit,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
