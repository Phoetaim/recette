// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_planning.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecipePlanning {

 int? get id; int get recipeId; int get nbOfPeople;
/// Create a copy of RecipePlanning
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipePlanningCopyWith<RecipePlanning> get copyWith => _$RecipePlanningCopyWithImpl<RecipePlanning>(this as RecipePlanning, _$identity);

  /// Serializes this RecipePlanning to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipePlanning&&(identical(other.id, id) || other.id == id)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.nbOfPeople, nbOfPeople) || other.nbOfPeople == nbOfPeople));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipeId,nbOfPeople);

@override
String toString() {
  return 'RecipePlanning(id: $id, recipeId: $recipeId, nbOfPeople: $nbOfPeople)';
}


}

/// @nodoc
abstract mixin class $RecipePlanningCopyWith<$Res>  {
  factory $RecipePlanningCopyWith(RecipePlanning value, $Res Function(RecipePlanning) _then) = _$RecipePlanningCopyWithImpl;
@useResult
$Res call({
 int? id, int recipeId, int nbOfPeople
});




}
/// @nodoc
class _$RecipePlanningCopyWithImpl<$Res>
    implements $RecipePlanningCopyWith<$Res> {
  _$RecipePlanningCopyWithImpl(this._self, this._then);

  final RecipePlanning _self;
  final $Res Function(RecipePlanning) _then;

/// Create a copy of RecipePlanning
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? recipeId = null,Object? nbOfPeople = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as int,nbOfPeople: null == nbOfPeople ? _self.nbOfPeople : nbOfPeople // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipePlanning].
extension RecipePlanningPatterns on RecipePlanning {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipePlanning value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipePlanning() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipePlanning value)  $default,){
final _that = this;
switch (_that) {
case _RecipePlanning():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipePlanning value)?  $default,){
final _that = this;
switch (_that) {
case _RecipePlanning() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int recipeId,  int nbOfPeople)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipePlanning() when $default != null:
return $default(_that.id,_that.recipeId,_that.nbOfPeople);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int recipeId,  int nbOfPeople)  $default,) {final _that = this;
switch (_that) {
case _RecipePlanning():
return $default(_that.id,_that.recipeId,_that.nbOfPeople);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int recipeId,  int nbOfPeople)?  $default,) {final _that = this;
switch (_that) {
case _RecipePlanning() when $default != null:
return $default(_that.id,_that.recipeId,_that.nbOfPeople);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipePlanning implements RecipePlanning {
  const _RecipePlanning({this.id, required this.recipeId, required this.nbOfPeople});
  factory _RecipePlanning.fromJson(Map<String, dynamic> json) => _$RecipePlanningFromJson(json);

@override final  int? id;
@override final  int recipeId;
@override final  int nbOfPeople;

/// Create a copy of RecipePlanning
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipePlanningCopyWith<_RecipePlanning> get copyWith => __$RecipePlanningCopyWithImpl<_RecipePlanning>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipePlanningToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipePlanning&&(identical(other.id, id) || other.id == id)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.nbOfPeople, nbOfPeople) || other.nbOfPeople == nbOfPeople));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipeId,nbOfPeople);

@override
String toString() {
  return 'RecipePlanning(id: $id, recipeId: $recipeId, nbOfPeople: $nbOfPeople)';
}


}

/// @nodoc
abstract mixin class _$RecipePlanningCopyWith<$Res> implements $RecipePlanningCopyWith<$Res> {
  factory _$RecipePlanningCopyWith(_RecipePlanning value, $Res Function(_RecipePlanning) _then) = __$RecipePlanningCopyWithImpl;
@override @useResult
$Res call({
 int? id, int recipeId, int nbOfPeople
});




}
/// @nodoc
class __$RecipePlanningCopyWithImpl<$Res>
    implements _$RecipePlanningCopyWith<$Res> {
  __$RecipePlanningCopyWithImpl(this._self, this._then);

  final _RecipePlanning _self;
  final $Res Function(_RecipePlanning) _then;

/// Create a copy of RecipePlanning
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? recipeId = null,Object? nbOfPeople = null,}) {
  return _then(_RecipePlanning(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as int,nbOfPeople: null == nbOfPeople ? _self.nbOfPeople : nbOfPeople // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
