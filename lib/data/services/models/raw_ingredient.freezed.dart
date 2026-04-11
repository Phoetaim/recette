// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raw_ingredient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawIngredient {

 int? get id; String get name; int get type;
/// Create a copy of RawIngredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawIngredientCopyWith<RawIngredient> get copyWith => _$RawIngredientCopyWithImpl<RawIngredient>(this as RawIngredient, _$identity);

  /// Serializes this RawIngredient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawIngredient&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type);

@override
String toString() {
  return 'RawIngredient(id: $id, name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class $RawIngredientCopyWith<$Res>  {
  factory $RawIngredientCopyWith(RawIngredient value, $Res Function(RawIngredient) _then) = _$RawIngredientCopyWithImpl;
@useResult
$Res call({
 int? id, String name, int type
});




}
/// @nodoc
class _$RawIngredientCopyWithImpl<$Res>
    implements $RawIngredientCopyWith<$Res> {
  _$RawIngredientCopyWithImpl(this._self, this._then);

  final RawIngredient _self;
  final $Res Function(RawIngredient) _then;

/// Create a copy of RawIngredient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RawIngredient].
extension RawIngredientPatterns on RawIngredient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawIngredient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawIngredient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawIngredient value)  $default,){
final _that = this;
switch (_that) {
case _RawIngredient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawIngredient value)?  $default,){
final _that = this;
switch (_that) {
case _RawIngredient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  int type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawIngredient() when $default != null:
return $default(_that.id,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  int type)  $default,) {final _that = this;
switch (_that) {
case _RawIngredient():
return $default(_that.id,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  int type)?  $default,) {final _that = this;
switch (_that) {
case _RawIngredient() when $default != null:
return $default(_that.id,_that.name,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RawIngredient implements RawIngredient {
  const _RawIngredient({this.id, required this.name, this.type = 15});
  factory _RawIngredient.fromJson(Map<String, dynamic> json) => _$RawIngredientFromJson(json);

@override final  int? id;
@override final  String name;
@override@JsonKey() final  int type;

/// Create a copy of RawIngredient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawIngredientCopyWith<_RawIngredient> get copyWith => __$RawIngredientCopyWithImpl<_RawIngredient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawIngredientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawIngredient&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type);

@override
String toString() {
  return 'RawIngredient(id: $id, name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class _$RawIngredientCopyWith<$Res> implements $RawIngredientCopyWith<$Res> {
  factory _$RawIngredientCopyWith(_RawIngredient value, $Res Function(_RawIngredient) _then) = __$RawIngredientCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, int type
});




}
/// @nodoc
class __$RawIngredientCopyWithImpl<$Res>
    implements _$RawIngredientCopyWith<$Res> {
  __$RawIngredientCopyWithImpl(this._self, this._then);

  final _RawIngredient _self;
  final $Res Function(_RawIngredient) _then;

/// Create a copy of RawIngredient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? type = null,}) {
  return _then(_RawIngredient(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
