// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raw_recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawRecipe {

/// e.g. 0
 int? get id;/// e.g. 'Tarte à la tomate'
 String get name;/// e.g. '1h'
 String get preparationTime;/// e.g. '45''
 String get cookingTime;/// e.g. 4
 int get nbOfPeople;/// e.g. [1, 323]
 List<int> get ingredientWithQuantityIds;/// e.g. ['Prépare la tarte', 'Cuis la']
 List<String> get steps;
/// Create a copy of RawRecipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawRecipeCopyWith<RawRecipe> get copyWith => _$RawRecipeCopyWithImpl<RawRecipe>(this as RawRecipe, _$identity);

  /// Serializes this RawRecipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawRecipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.preparationTime, preparationTime) || other.preparationTime == preparationTime)&&(identical(other.cookingTime, cookingTime) || other.cookingTime == cookingTime)&&(identical(other.nbOfPeople, nbOfPeople) || other.nbOfPeople == nbOfPeople)&&const DeepCollectionEquality().equals(other.ingredientWithQuantityIds, ingredientWithQuantityIds)&&const DeepCollectionEquality().equals(other.steps, steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,preparationTime,cookingTime,nbOfPeople,const DeepCollectionEquality().hash(ingredientWithQuantityIds),const DeepCollectionEquality().hash(steps));

@override
String toString() {
  return 'RawRecipe(id: $id, name: $name, preparationTime: $preparationTime, cookingTime: $cookingTime, nbOfPeople: $nbOfPeople, ingredientWithQuantityIds: $ingredientWithQuantityIds, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $RawRecipeCopyWith<$Res>  {
  factory $RawRecipeCopyWith(RawRecipe value, $Res Function(RawRecipe) _then) = _$RawRecipeCopyWithImpl;
@useResult
$Res call({
 int? id, String name, String preparationTime, String cookingTime, int nbOfPeople, List<int> ingredientWithQuantityIds, List<String> steps
});




}
/// @nodoc
class _$RawRecipeCopyWithImpl<$Res>
    implements $RawRecipeCopyWith<$Res> {
  _$RawRecipeCopyWithImpl(this._self, this._then);

  final RawRecipe _self;
  final $Res Function(RawRecipe) _then;

/// Create a copy of RawRecipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? preparationTime = null,Object? cookingTime = null,Object? nbOfPeople = null,Object? ingredientWithQuantityIds = null,Object? steps = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,preparationTime: null == preparationTime ? _self.preparationTime : preparationTime // ignore: cast_nullable_to_non_nullable
as String,cookingTime: null == cookingTime ? _self.cookingTime : cookingTime // ignore: cast_nullable_to_non_nullable
as String,nbOfPeople: null == nbOfPeople ? _self.nbOfPeople : nbOfPeople // ignore: cast_nullable_to_non_nullable
as int,ingredientWithQuantityIds: null == ingredientWithQuantityIds ? _self.ingredientWithQuantityIds : ingredientWithQuantityIds // ignore: cast_nullable_to_non_nullable
as List<int>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RawRecipe].
extension RawRecipePatterns on RawRecipe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawRecipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawRecipe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawRecipe value)  $default,){
final _that = this;
switch (_that) {
case _RawRecipe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawRecipe value)?  $default,){
final _that = this;
switch (_that) {
case _RawRecipe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  String preparationTime,  String cookingTime,  int nbOfPeople,  List<int> ingredientWithQuantityIds,  List<String> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawRecipe() when $default != null:
return $default(_that.id,_that.name,_that.preparationTime,_that.cookingTime,_that.nbOfPeople,_that.ingredientWithQuantityIds,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  String preparationTime,  String cookingTime,  int nbOfPeople,  List<int> ingredientWithQuantityIds,  List<String> steps)  $default,) {final _that = this;
switch (_that) {
case _RawRecipe():
return $default(_that.id,_that.name,_that.preparationTime,_that.cookingTime,_that.nbOfPeople,_that.ingredientWithQuantityIds,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  String preparationTime,  String cookingTime,  int nbOfPeople,  List<int> ingredientWithQuantityIds,  List<String> steps)?  $default,) {final _that = this;
switch (_that) {
case _RawRecipe() when $default != null:
return $default(_that.id,_that.name,_that.preparationTime,_that.cookingTime,_that.nbOfPeople,_that.ingredientWithQuantityIds,_that.steps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RawRecipe implements RawRecipe {
  const _RawRecipe({this.id, this.name = 'Sans nom', this.preparationTime = '-', this.cookingTime = '-', this.nbOfPeople = 4, final  List<int> ingredientWithQuantityIds = const [], final  List<String> steps = const []}): _ingredientWithQuantityIds = ingredientWithQuantityIds,_steps = steps;
  factory _RawRecipe.fromJson(Map<String, dynamic> json) => _$RawRecipeFromJson(json);

/// e.g. 0
@override final  int? id;
/// e.g. 'Tarte à la tomate'
@override@JsonKey() final  String name;
/// e.g. '1h'
@override@JsonKey() final  String preparationTime;
/// e.g. '45''
@override@JsonKey() final  String cookingTime;
/// e.g. 4
@override@JsonKey() final  int nbOfPeople;
/// e.g. [1, 323]
 final  List<int> _ingredientWithQuantityIds;
/// e.g. [1, 323]
@override@JsonKey() List<int> get ingredientWithQuantityIds {
  if (_ingredientWithQuantityIds is EqualUnmodifiableListView) return _ingredientWithQuantityIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredientWithQuantityIds);
}

/// e.g. ['Prépare la tarte', 'Cuis la']
 final  List<String> _steps;
/// e.g. ['Prépare la tarte', 'Cuis la']
@override@JsonKey() List<String> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of RawRecipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawRecipeCopyWith<_RawRecipe> get copyWith => __$RawRecipeCopyWithImpl<_RawRecipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawRecipeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawRecipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.preparationTime, preparationTime) || other.preparationTime == preparationTime)&&(identical(other.cookingTime, cookingTime) || other.cookingTime == cookingTime)&&(identical(other.nbOfPeople, nbOfPeople) || other.nbOfPeople == nbOfPeople)&&const DeepCollectionEquality().equals(other._ingredientWithQuantityIds, _ingredientWithQuantityIds)&&const DeepCollectionEquality().equals(other._steps, _steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,preparationTime,cookingTime,nbOfPeople,const DeepCollectionEquality().hash(_ingredientWithQuantityIds),const DeepCollectionEquality().hash(_steps));

@override
String toString() {
  return 'RawRecipe(id: $id, name: $name, preparationTime: $preparationTime, cookingTime: $cookingTime, nbOfPeople: $nbOfPeople, ingredientWithQuantityIds: $ingredientWithQuantityIds, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$RawRecipeCopyWith<$Res> implements $RawRecipeCopyWith<$Res> {
  factory _$RawRecipeCopyWith(_RawRecipe value, $Res Function(_RawRecipe) _then) = __$RawRecipeCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, String preparationTime, String cookingTime, int nbOfPeople, List<int> ingredientWithQuantityIds, List<String> steps
});




}
/// @nodoc
class __$RawRecipeCopyWithImpl<$Res>
    implements _$RawRecipeCopyWith<$Res> {
  __$RawRecipeCopyWithImpl(this._self, this._then);

  final _RawRecipe _self;
  final $Res Function(_RawRecipe) _then;

/// Create a copy of RawRecipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? preparationTime = null,Object? cookingTime = null,Object? nbOfPeople = null,Object? ingredientWithQuantityIds = null,Object? steps = null,}) {
  return _then(_RawRecipe(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,preparationTime: null == preparationTime ? _self.preparationTime : preparationTime // ignore: cast_nullable_to_non_nullable
as String,cookingTime: null == cookingTime ? _self.cookingTime : cookingTime // ignore: cast_nullable_to_non_nullable
as String,nbOfPeople: null == nbOfPeople ? _self.nbOfPeople : nbOfPeople // ignore: cast_nullable_to_non_nullable
as int,ingredientWithQuantityIds: null == ingredientWithQuantityIds ? _self._ingredientWithQuantityIds : ingredientWithQuantityIds // ignore: cast_nullable_to_non_nullable
as List<int>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
