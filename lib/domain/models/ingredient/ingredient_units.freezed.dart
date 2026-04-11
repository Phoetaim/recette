// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_units.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngredientUnit {

 int? get id; String get name;
/// Create a copy of IngredientUnit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientUnitCopyWith<IngredientUnit> get copyWith => _$IngredientUnitCopyWithImpl<IngredientUnit>(this as IngredientUnit, _$identity);

  /// Serializes this IngredientUnit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngredientUnit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IngredientUnit(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $IngredientUnitCopyWith<$Res>  {
  factory $IngredientUnitCopyWith(IngredientUnit value, $Res Function(IngredientUnit) _then) = _$IngredientUnitCopyWithImpl;
@useResult
$Res call({
 int? id, String name
});




}
/// @nodoc
class _$IngredientUnitCopyWithImpl<$Res>
    implements $IngredientUnitCopyWith<$Res> {
  _$IngredientUnitCopyWithImpl(this._self, this._then);

  final IngredientUnit _self;
  final $Res Function(IngredientUnit) _then;

/// Create a copy of IngredientUnit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IngredientUnit].
extension IngredientUnitPatterns on IngredientUnit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngredientUnit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngredientUnit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngredientUnit value)  $default,){
final _that = this;
switch (_that) {
case _IngredientUnit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngredientUnit value)?  $default,){
final _that = this;
switch (_that) {
case _IngredientUnit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngredientUnit() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name)  $default,) {final _that = this;
switch (_that) {
case _IngredientUnit():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _IngredientUnit() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IngredientUnit implements IngredientUnit {
  const _IngredientUnit({this.id, this.name = 'unit'});
  factory _IngredientUnit.fromJson(Map<String, dynamic> json) => _$IngredientUnitFromJson(json);

@override final  int? id;
@override@JsonKey() final  String name;

/// Create a copy of IngredientUnit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientUnitCopyWith<_IngredientUnit> get copyWith => __$IngredientUnitCopyWithImpl<_IngredientUnit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientUnitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngredientUnit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IngredientUnit(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$IngredientUnitCopyWith<$Res> implements $IngredientUnitCopyWith<$Res> {
  factory _$IngredientUnitCopyWith(_IngredientUnit value, $Res Function(_IngredientUnit) _then) = __$IngredientUnitCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name
});




}
/// @nodoc
class __$IngredientUnitCopyWithImpl<$Res>
    implements _$IngredientUnitCopyWith<$Res> {
  __$IngredientUnitCopyWithImpl(this._self, this._then);

  final _IngredientUnit _self;
  final $Res Function(_IngredientUnit) _then;

/// Create a copy of IngredientUnit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,}) {
  return _then(_IngredientUnit(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
