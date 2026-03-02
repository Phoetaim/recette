// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raw_ingredient_with_quantity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawIngredientWithQuantity {

 int? get id; int get ingredientId; IngredientUnit get unit; int get quantity;
/// Create a copy of RawIngredientWithQuantity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawIngredientWithQuantityCopyWith<RawIngredientWithQuantity> get copyWith => _$RawIngredientWithQuantityCopyWithImpl<RawIngredientWithQuantity>(this as RawIngredientWithQuantity, _$identity);

  /// Serializes this RawIngredientWithQuantity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawIngredientWithQuantity&&(identical(other.id, id) || other.id == id)&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ingredientId,unit,quantity);

@override
String toString() {
  return 'RawIngredientWithQuantity(id: $id, ingredientId: $ingredientId, unit: $unit, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $RawIngredientWithQuantityCopyWith<$Res>  {
  factory $RawIngredientWithQuantityCopyWith(RawIngredientWithQuantity value, $Res Function(RawIngredientWithQuantity) _then) = _$RawIngredientWithQuantityCopyWithImpl;
@useResult
$Res call({
 int? id, int ingredientId, IngredientUnit unit, int quantity
});




}
/// @nodoc
class _$RawIngredientWithQuantityCopyWithImpl<$Res>
    implements $RawIngredientWithQuantityCopyWith<$Res> {
  _$RawIngredientWithQuantityCopyWithImpl(this._self, this._then);

  final RawIngredientWithQuantity _self;
  final $Res Function(RawIngredientWithQuantity) _then;

/// Create a copy of RawIngredientWithQuantity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? ingredientId = null,Object? unit = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as IngredientUnit,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RawIngredientWithQuantity].
extension RawIngredientWithQuantityPatterns on RawIngredientWithQuantity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawIngredientWithQuantity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawIngredientWithQuantity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawIngredientWithQuantity value)  $default,){
final _that = this;
switch (_that) {
case _RawIngredientWithQuantity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawIngredientWithQuantity value)?  $default,){
final _that = this;
switch (_that) {
case _RawIngredientWithQuantity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int ingredientId,  IngredientUnit unit,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawIngredientWithQuantity() when $default != null:
return $default(_that.id,_that.ingredientId,_that.unit,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int ingredientId,  IngredientUnit unit,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _RawIngredientWithQuantity():
return $default(_that.id,_that.ingredientId,_that.unit,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int ingredientId,  IngredientUnit unit,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _RawIngredientWithQuantity() when $default != null:
return $default(_that.id,_that.ingredientId,_that.unit,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RawIngredientWithQuantity implements RawIngredientWithQuantity {
  const _RawIngredientWithQuantity({this.id, required this.ingredientId, this.unit = IngredientUnit.unit, this.quantity = 1});
  factory _RawIngredientWithQuantity.fromJson(Map<String, dynamic> json) => _$RawIngredientWithQuantityFromJson(json);

@override final  int? id;
@override final  int ingredientId;
@override@JsonKey() final  IngredientUnit unit;
@override@JsonKey() final  int quantity;

/// Create a copy of RawIngredientWithQuantity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawIngredientWithQuantityCopyWith<_RawIngredientWithQuantity> get copyWith => __$RawIngredientWithQuantityCopyWithImpl<_RawIngredientWithQuantity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawIngredientWithQuantityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawIngredientWithQuantity&&(identical(other.id, id) || other.id == id)&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ingredientId,unit,quantity);

@override
String toString() {
  return 'RawIngredientWithQuantity(id: $id, ingredientId: $ingredientId, unit: $unit, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$RawIngredientWithQuantityCopyWith<$Res> implements $RawIngredientWithQuantityCopyWith<$Res> {
  factory _$RawIngredientWithQuantityCopyWith(_RawIngredientWithQuantity value, $Res Function(_RawIngredientWithQuantity) _then) = __$RawIngredientWithQuantityCopyWithImpl;
@override @useResult
$Res call({
 int? id, int ingredientId, IngredientUnit unit, int quantity
});




}
/// @nodoc
class __$RawIngredientWithQuantityCopyWithImpl<$Res>
    implements _$RawIngredientWithQuantityCopyWith<$Res> {
  __$RawIngredientWithQuantityCopyWithImpl(this._self, this._then);

  final _RawIngredientWithQuantity _self;
  final $Res Function(_RawIngredientWithQuantity) _then;

/// Create a copy of RawIngredientWithQuantity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? ingredientId = null,Object? unit = null,Object? quantity = null,}) {
  return _then(_RawIngredientWithQuantity(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as IngredientUnit,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
