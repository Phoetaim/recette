// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngredientTypes {

 int? get id; String get name; int get color;
/// Create a copy of IngredientTypes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientTypesCopyWith<IngredientTypes> get copyWith => _$IngredientTypesCopyWithImpl<IngredientTypes>(this as IngredientTypes, _$identity);

  /// Serializes this IngredientTypes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngredientTypes&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color);

@override
String toString() {
  return 'IngredientTypes(id: $id, name: $name, color: $color)';
}


}

/// @nodoc
abstract mixin class $IngredientTypesCopyWith<$Res>  {
  factory $IngredientTypesCopyWith(IngredientTypes value, $Res Function(IngredientTypes) _then) = _$IngredientTypesCopyWithImpl;
@useResult
$Res call({
 int? id, String name, int color
});




}
/// @nodoc
class _$IngredientTypesCopyWithImpl<$Res>
    implements $IngredientTypesCopyWith<$Res> {
  _$IngredientTypesCopyWithImpl(this._self, this._then);

  final IngredientTypes _self;
  final $Res Function(IngredientTypes) _then;

/// Create a copy of IngredientTypes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? color = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [IngredientTypes].
extension IngredientTypesPatterns on IngredientTypes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngredientTypes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngredientTypes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngredientTypes value)  $default,){
final _that = this;
switch (_that) {
case _IngredientTypes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngredientTypes value)?  $default,){
final _that = this;
switch (_that) {
case _IngredientTypes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  int color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngredientTypes() when $default != null:
return $default(_that.id,_that.name,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  int color)  $default,) {final _that = this;
switch (_that) {
case _IngredientTypes():
return $default(_that.id,_that.name,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  int color)?  $default,) {final _that = this;
switch (_that) {
case _IngredientTypes() when $default != null:
return $default(_that.id,_that.name,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IngredientTypes extends IngredientTypes {
  const _IngredientTypes({this.id, required this.name, required this.color}): super._();
  factory _IngredientTypes.fromJson(Map<String, dynamic> json) => _$IngredientTypesFromJson(json);

@override final  int? id;
@override final  String name;
@override final  int color;

/// Create a copy of IngredientTypes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientTypesCopyWith<_IngredientTypes> get copyWith => __$IngredientTypesCopyWithImpl<_IngredientTypes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientTypesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngredientTypes&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color);

@override
String toString() {
  return 'IngredientTypes(id: $id, name: $name, color: $color)';
}


}

/// @nodoc
abstract mixin class _$IngredientTypesCopyWith<$Res> implements $IngredientTypesCopyWith<$Res> {
  factory _$IngredientTypesCopyWith(_IngredientTypes value, $Res Function(_IngredientTypes) _then) = __$IngredientTypesCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, int color
});




}
/// @nodoc
class __$IngredientTypesCopyWithImpl<$Res>
    implements _$IngredientTypesCopyWith<$Res> {
  __$IngredientTypesCopyWithImpl(this._self, this._then);

  final _IngredientTypes _self;
  final $Res Function(_IngredientTypes) _then;

/// Create a copy of IngredientTypes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? color = null,}) {
  return _then(_IngredientTypes(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
