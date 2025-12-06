// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_ingredient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShoppingIngredient {

 int? get id;// If the item is checked
 bool get bought;// Ingredient def
 IngredientWithQuantity get ingredient;
/// Create a copy of ShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingIngredientCopyWith<ShoppingIngredient> get copyWith => _$ShoppingIngredientCopyWithImpl<ShoppingIngredient>(this as ShoppingIngredient, _$identity);

  /// Serializes this ShoppingIngredient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingIngredient&&(identical(other.id, id) || other.id == id)&&(identical(other.bought, bought) || other.bought == bought)&&(identical(other.ingredient, ingredient) || other.ingredient == ingredient));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bought,ingredient);

@override
String toString() {
  return 'ShoppingIngredient(id: $id, bought: $bought, ingredient: $ingredient)';
}


}

/// @nodoc
abstract mixin class $ShoppingIngredientCopyWith<$Res>  {
  factory $ShoppingIngredientCopyWith(ShoppingIngredient value, $Res Function(ShoppingIngredient) _then) = _$ShoppingIngredientCopyWithImpl;
@useResult
$Res call({
 int? id, bool bought, IngredientWithQuantity ingredient
});


$IngredientWithQuantityCopyWith<$Res> get ingredient;

}
/// @nodoc
class _$ShoppingIngredientCopyWithImpl<$Res>
    implements $ShoppingIngredientCopyWith<$Res> {
  _$ShoppingIngredientCopyWithImpl(this._self, this._then);

  final ShoppingIngredient _self;
  final $Res Function(ShoppingIngredient) _then;

/// Create a copy of ShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? bought = null,Object? ingredient = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,bought: null == bought ? _self.bought : bought // ignore: cast_nullable_to_non_nullable
as bool,ingredient: null == ingredient ? _self.ingredient : ingredient // ignore: cast_nullable_to_non_nullable
as IngredientWithQuantity,
  ));
}
/// Create a copy of ShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngredientWithQuantityCopyWith<$Res> get ingredient {
  
  return $IngredientWithQuantityCopyWith<$Res>(_self.ingredient, (value) {
    return _then(_self.copyWith(ingredient: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShoppingIngredient].
extension ShoppingIngredientPatterns on ShoppingIngredient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingIngredient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingIngredient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingIngredient value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingIngredient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingIngredient value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingIngredient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  bool bought,  IngredientWithQuantity ingredient)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingIngredient() when $default != null:
return $default(_that.id,_that.bought,_that.ingredient);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  bool bought,  IngredientWithQuantity ingredient)  $default,) {final _that = this;
switch (_that) {
case _ShoppingIngredient():
return $default(_that.id,_that.bought,_that.ingredient);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  bool bought,  IngredientWithQuantity ingredient)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingIngredient() when $default != null:
return $default(_that.id,_that.bought,_that.ingredient);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShoppingIngredient implements ShoppingIngredient {
  const _ShoppingIngredient({this.id, this.bought = false, required this.ingredient});
  factory _ShoppingIngredient.fromJson(Map<String, dynamic> json) => _$ShoppingIngredientFromJson(json);

@override final  int? id;
// If the item is checked
@override@JsonKey() final  bool bought;
// Ingredient def
@override final  IngredientWithQuantity ingredient;

/// Create a copy of ShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingIngredientCopyWith<_ShoppingIngredient> get copyWith => __$ShoppingIngredientCopyWithImpl<_ShoppingIngredient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShoppingIngredientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingIngredient&&(identical(other.id, id) || other.id == id)&&(identical(other.bought, bought) || other.bought == bought)&&(identical(other.ingredient, ingredient) || other.ingredient == ingredient));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bought,ingredient);

@override
String toString() {
  return 'ShoppingIngredient(id: $id, bought: $bought, ingredient: $ingredient)';
}


}

/// @nodoc
abstract mixin class _$ShoppingIngredientCopyWith<$Res> implements $ShoppingIngredientCopyWith<$Res> {
  factory _$ShoppingIngredientCopyWith(_ShoppingIngredient value, $Res Function(_ShoppingIngredient) _then) = __$ShoppingIngredientCopyWithImpl;
@override @useResult
$Res call({
 int? id, bool bought, IngredientWithQuantity ingredient
});


@override $IngredientWithQuantityCopyWith<$Res> get ingredient;

}
/// @nodoc
class __$ShoppingIngredientCopyWithImpl<$Res>
    implements _$ShoppingIngredientCopyWith<$Res> {
  __$ShoppingIngredientCopyWithImpl(this._self, this._then);

  final _ShoppingIngredient _self;
  final $Res Function(_ShoppingIngredient) _then;

/// Create a copy of ShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? bought = null,Object? ingredient = null,}) {
  return _then(_ShoppingIngredient(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,bought: null == bought ? _self.bought : bought // ignore: cast_nullable_to_non_nullable
as bool,ingredient: null == ingredient ? _self.ingredient : ingredient // ignore: cast_nullable_to_non_nullable
as IngredientWithQuantity,
  ));
}

/// Create a copy of ShoppingIngredient
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngredientWithQuantityCopyWith<$Res> get ingredient {
  
  return $IngredientWithQuantityCopyWith<$Res>(_self.ingredient, (value) {
    return _then(_self.copyWith(ingredient: value));
  });
}
}

// dart format on
