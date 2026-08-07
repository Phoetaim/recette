// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Recipe {

/// e.g. 0
 int? get id;/// e.g. 'Tarte à la tomate'
 String get name;/// e.g. '1h'
 String get preparationTime;/// e.g. '45''
 String get cookingTime;/// e.g. 4
 int get nbOfPeople;@JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson) List<IngredientWithQuantity> get ingredients;/// e.g. 'Prépare la tarte\nCuis la'
 String get steps;
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeCopyWith<Recipe> get copyWith => _$RecipeCopyWithImpl<Recipe>(this as Recipe, _$identity);

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.preparationTime, preparationTime) || other.preparationTime == preparationTime)&&(identical(other.cookingTime, cookingTime) || other.cookingTime == cookingTime)&&(identical(other.nbOfPeople, nbOfPeople) || other.nbOfPeople == nbOfPeople)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&(identical(other.steps, steps) || other.steps == steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,preparationTime,cookingTime,nbOfPeople,const DeepCollectionEquality().hash(ingredients),steps);

@override
String toString() {
  return 'Recipe(id: $id, name: $name, preparationTime: $preparationTime, cookingTime: $cookingTime, nbOfPeople: $nbOfPeople, ingredients: $ingredients, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $RecipeCopyWith<$Res>  {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) _then) = _$RecipeCopyWithImpl;
@useResult
$Res call({
 int? id, String name, String preparationTime, String cookingTime, int nbOfPeople,@JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson) List<IngredientWithQuantity> ingredients, String steps
});




}
/// @nodoc
class _$RecipeCopyWithImpl<$Res>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._self, this._then);

  final Recipe _self;
  final $Res Function(Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? preparationTime = null,Object? cookingTime = null,Object? nbOfPeople = null,Object? ingredients = null,Object? steps = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,preparationTime: null == preparationTime ? _self.preparationTime : preparationTime // ignore: cast_nullable_to_non_nullable
as String,cookingTime: null == cookingTime ? _self.cookingTime : cookingTime // ignore: cast_nullable_to_non_nullable
as String,nbOfPeople: null == nbOfPeople ? _self.nbOfPeople : nbOfPeople // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<IngredientWithQuantity>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Recipe].
extension RecipePatterns on Recipe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recipe value)  $default,){
final _that = this;
switch (_that) {
case _Recipe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recipe value)?  $default,){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  String preparationTime,  String cookingTime,  int nbOfPeople, @JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson)  List<IngredientWithQuantity> ingredients,  String steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.name,_that.preparationTime,_that.cookingTime,_that.nbOfPeople,_that.ingredients,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  String preparationTime,  String cookingTime,  int nbOfPeople, @JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson)  List<IngredientWithQuantity> ingredients,  String steps)  $default,) {final _that = this;
switch (_that) {
case _Recipe():
return $default(_that.id,_that.name,_that.preparationTime,_that.cookingTime,_that.nbOfPeople,_that.ingredients,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  String preparationTime,  String cookingTime,  int nbOfPeople, @JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson)  List<IngredientWithQuantity> ingredients,  String steps)?  $default,) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.name,_that.preparationTime,_that.cookingTime,_that.nbOfPeople,_that.ingredients,_that.steps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recipe implements Recipe {
  const _Recipe({this.id, this.name = 'Sans nom', this.preparationTime = '-', this.cookingTime = '-', this.nbOfPeople = 4, @JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson) final  List<IngredientWithQuantity> ingredients = const [], this.steps = ''}): _ingredients = ingredients;
  factory _Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

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
 final  List<IngredientWithQuantity> _ingredients;
@override@JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson) List<IngredientWithQuantity> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

/// e.g. 'Prépare la tarte\nCuis la'
@override@JsonKey() final  String steps;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeCopyWith<_Recipe> get copyWith => __$RecipeCopyWithImpl<_Recipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.preparationTime, preparationTime) || other.preparationTime == preparationTime)&&(identical(other.cookingTime, cookingTime) || other.cookingTime == cookingTime)&&(identical(other.nbOfPeople, nbOfPeople) || other.nbOfPeople == nbOfPeople)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&(identical(other.steps, steps) || other.steps == steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,preparationTime,cookingTime,nbOfPeople,const DeepCollectionEquality().hash(_ingredients),steps);

@override
String toString() {
  return 'Recipe(id: $id, name: $name, preparationTime: $preparationTime, cookingTime: $cookingTime, nbOfPeople: $nbOfPeople, ingredients: $ingredients, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$RecipeCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$RecipeCopyWith(_Recipe value, $Res Function(_Recipe) _then) = __$RecipeCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, String preparationTime, String cookingTime, int nbOfPeople,@JsonKey(toJson: ingredientWithQuantitiesToJson, fromJson: ingredientWithQuantitiesFromJson) List<IngredientWithQuantity> ingredients, String steps
});




}
/// @nodoc
class __$RecipeCopyWithImpl<$Res>
    implements _$RecipeCopyWith<$Res> {
  __$RecipeCopyWithImpl(this._self, this._then);

  final _Recipe _self;
  final $Res Function(_Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? preparationTime = null,Object? cookingTime = null,Object? nbOfPeople = null,Object? ingredients = null,Object? steps = null,}) {
  return _then(_Recipe(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,preparationTime: null == preparationTime ? _self.preparationTime : preparationTime // ignore: cast_nullable_to_non_nullable
as String,cookingTime: null == cookingTime ? _self.cookingTime : cookingTime // ignore: cast_nullable_to_non_nullable
as String,nbOfPeople: null == nbOfPeople ? _self.nbOfPeople : nbOfPeople // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<IngredientWithQuantity>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
