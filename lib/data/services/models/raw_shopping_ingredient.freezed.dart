// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raw_shopping_ingredient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawShoppingIngredient {

 int? get id; int get ingredientWithQuantityId; int get shoppingListId; int get bought;
/// Create a copy of RawShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawShoppingIngredientCopyWith<RawShoppingIngredient> get copyWith => _$RawShoppingIngredientCopyWithImpl<RawShoppingIngredient>(this as RawShoppingIngredient, _$identity);

  /// Serializes this RawShoppingIngredient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawShoppingIngredient&&(identical(other.id, id) || other.id == id)&&(identical(other.ingredientWithQuantityId, ingredientWithQuantityId) || other.ingredientWithQuantityId == ingredientWithQuantityId)&&(identical(other.shoppingListId, shoppingListId) || other.shoppingListId == shoppingListId)&&(identical(other.bought, bought) || other.bought == bought));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ingredientWithQuantityId,shoppingListId,bought);

@override
String toString() {
  return 'RawShoppingIngredient(id: $id, ingredientWithQuantityId: $ingredientWithQuantityId, shoppingListId: $shoppingListId, bought: $bought)';
}


}

/// @nodoc
abstract mixin class $RawShoppingIngredientCopyWith<$Res>  {
  factory $RawShoppingIngredientCopyWith(RawShoppingIngredient value, $Res Function(RawShoppingIngredient) _then) = _$RawShoppingIngredientCopyWithImpl;
@useResult
$Res call({
 int? id, int ingredientWithQuantityId, int shoppingListId, int bought
});




}
/// @nodoc
class _$RawShoppingIngredientCopyWithImpl<$Res>
    implements $RawShoppingIngredientCopyWith<$Res> {
  _$RawShoppingIngredientCopyWithImpl(this._self, this._then);

  final RawShoppingIngredient _self;
  final $Res Function(RawShoppingIngredient) _then;

/// Create a copy of RawShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? ingredientWithQuantityId = null,Object? shoppingListId = null,Object? bought = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,ingredientWithQuantityId: null == ingredientWithQuantityId ? _self.ingredientWithQuantityId : ingredientWithQuantityId // ignore: cast_nullable_to_non_nullable
as int,shoppingListId: null == shoppingListId ? _self.shoppingListId : shoppingListId // ignore: cast_nullable_to_non_nullable
as int,bought: null == bought ? _self.bought : bought // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RawShoppingIngredient].
extension RawShoppingIngredientPatterns on RawShoppingIngredient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawShoppingIngredient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawShoppingIngredient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawShoppingIngredient value)  $default,){
final _that = this;
switch (_that) {
case _RawShoppingIngredient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawShoppingIngredient value)?  $default,){
final _that = this;
switch (_that) {
case _RawShoppingIngredient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int ingredientWithQuantityId,  int shoppingListId,  int bought)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawShoppingIngredient() when $default != null:
return $default(_that.id,_that.ingredientWithQuantityId,_that.shoppingListId,_that.bought);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int ingredientWithQuantityId,  int shoppingListId,  int bought)  $default,) {final _that = this;
switch (_that) {
case _RawShoppingIngredient():
return $default(_that.id,_that.ingredientWithQuantityId,_that.shoppingListId,_that.bought);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int ingredientWithQuantityId,  int shoppingListId,  int bought)?  $default,) {final _that = this;
switch (_that) {
case _RawShoppingIngredient() when $default != null:
return $default(_that.id,_that.ingredientWithQuantityId,_that.shoppingListId,_that.bought);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RawShoppingIngredient implements RawShoppingIngredient {
  const _RawShoppingIngredient({this.id, required this.ingredientWithQuantityId, this.shoppingListId = 1, this.bought = 0});
  factory _RawShoppingIngredient.fromJson(Map<String, dynamic> json) => _$RawShoppingIngredientFromJson(json);

@override final  int? id;
@override final  int ingredientWithQuantityId;
@override@JsonKey() final  int shoppingListId;
@override@JsonKey() final  int bought;

/// Create a copy of RawShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawShoppingIngredientCopyWith<_RawShoppingIngredient> get copyWith => __$RawShoppingIngredientCopyWithImpl<_RawShoppingIngredient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawShoppingIngredientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawShoppingIngredient&&(identical(other.id, id) || other.id == id)&&(identical(other.ingredientWithQuantityId, ingredientWithQuantityId) || other.ingredientWithQuantityId == ingredientWithQuantityId)&&(identical(other.shoppingListId, shoppingListId) || other.shoppingListId == shoppingListId)&&(identical(other.bought, bought) || other.bought == bought));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ingredientWithQuantityId,shoppingListId,bought);

@override
String toString() {
  return 'RawShoppingIngredient(id: $id, ingredientWithQuantityId: $ingredientWithQuantityId, shoppingListId: $shoppingListId, bought: $bought)';
}


}

/// @nodoc
abstract mixin class _$RawShoppingIngredientCopyWith<$Res> implements $RawShoppingIngredientCopyWith<$Res> {
  factory _$RawShoppingIngredientCopyWith(_RawShoppingIngredient value, $Res Function(_RawShoppingIngredient) _then) = __$RawShoppingIngredientCopyWithImpl;
@override @useResult
$Res call({
 int? id, int ingredientWithQuantityId, int shoppingListId, int bought
});




}
/// @nodoc
class __$RawShoppingIngredientCopyWithImpl<$Res>
    implements _$RawShoppingIngredientCopyWith<$Res> {
  __$RawShoppingIngredientCopyWithImpl(this._self, this._then);

  final _RawShoppingIngredient _self;
  final $Res Function(_RawShoppingIngredient) _then;

/// Create a copy of RawShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? ingredientWithQuantityId = null,Object? shoppingListId = null,Object? bought = null,}) {
  return _then(_RawShoppingIngredient(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,ingredientWithQuantityId: null == ingredientWithQuantityId ? _self.ingredientWithQuantityId : ingredientWithQuantityId // ignore: cast_nullable_to_non_nullable
as int,shoppingListId: null == shoppingListId ? _self.shoppingListId : shoppingListId // ignore: cast_nullable_to_non_nullable
as int,bought: null == bought ? _self.bought : bought // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
