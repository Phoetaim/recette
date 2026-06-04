import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/services/models/import_data.dart';
import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';

import '../../data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import '../../data/repositories/ingredient/ingredient_repository.dart';
import '../../data/repositories/ingredient/ingredient_units_repository.dart';
import '../../data/services/models/raw_ingredient.dart';
import '../../data/services/models/raw_recipe.dart';
import '../../utils/result.dart';

Codec<String, String> stringToBase64 = utf8.fuse(base64);

class ImportExportUseCase {
  ImportExportUseCase({
    required IngredientRepository ingredientRepository,
    required IngredientWithQuantityRepository ingredientWithQuantityRepository,
    required IngredientUnitsRepository ingredientUnitsRepository,
    required RecipeRepository recipeRepository,
  }) : _ingredientRepository = ingredientRepository,
       _ingredientWithQuantityRepository = ingredientWithQuantityRepository,
       _ingredientUnitsRepository = ingredientUnitsRepository,
       _recipeRepository = recipeRepository;

  final IngredientRepository _ingredientRepository;
  final IngredientWithQuantityRepository _ingredientWithQuantityRepository;
  final IngredientUnitsRepository _ingredientUnitsRepository;
  final RecipeRepository _recipeRepository;

  Future<void> exportRecipes(List<RawRecipe> rawRecipes) async {
    List<int> ingredientWithQuantityIds = await _getIngredientWithQuantityIds(rawRecipes);

    List<RawIngredientWithQuantity> rawIngredientsWithQuantities =
        await _getRawIngredientsWithQuantities(ingredientWithQuantityIds);

    List<RawIngredient> rawIngredients = await _getRawIngredients(rawIngredientsWithQuantities);

    List<IngredientTypes> ingredientTypes = _getIngredientTypes(rawIngredients);
    List<IngredientUnit> ingredientUnits = _getIngredientUnits(rawIngredientsWithQuantities);

    final ImportData export = ImportData(
      rawRecipes: rawRecipes,
      rawIngredientsWithQuantity: rawIngredientsWithQuantities,
      rawIngredients: rawIngredients,
      ingredientTypes: ingredientTypes,
      ingredientUnits: ingredientUnits,
    );

    final exportedRecipe = stringToBase64.encode(jsonEncode(export.toJson()));
    Clipboard.setData(ClipboardData(text: exportedRecipe));
  }

  Future<List<int>> _getIngredientWithQuantityIds(List<RawRecipe> rawRecipes) async {
    Set<int> ingredientWithQuantityIds = <int>{};
    for (var rawRecipe in rawRecipes) {
      ingredientWithQuantityIds.addAll(rawRecipe.ingredientWithQuantityIds);
    }
    return ingredientWithQuantityIds.toList();
  }

  Future<List<RawIngredientWithQuantity>> _getRawIngredientsWithQuantities(
    List<int> ingredientWithQuantityIds,
  ) async {
    List<RawIngredientWithQuantity> rawIngredientsWithQuantities = <RawIngredientWithQuantity>[];
    final result = await _ingredientWithQuantityRepository.getRawIngredientWithQuantityByIds(
      ingredientWithQuantityIds,
    );
    switch (result) {
      case Ok<List<RawIngredientWithQuantity>>():
        rawIngredientsWithQuantities = result.value;
      case Error<List<RawIngredientWithQuantity>>():
      // pass
    }
    return rawIngredientsWithQuantities;
  }

  Future<List<RawIngredient>> _getRawIngredients(
    List<RawIngredientWithQuantity> rawIngredientsWithQuantities,
  ) async {
    Set<int> ingredientsIds = {};
    for (var rawIngredientsWithQuantities in rawIngredientsWithQuantities) {
      ingredientsIds.add(rawIngredientsWithQuantities.ingredientId);
    }

    List<RawIngredient> rawIngredients = [];
    for (var ingredientId in ingredientsIds) {
      final result = await _ingredientRepository.getIngredientById(ingredientId);
      switch (result) {
        case Ok<Ingredient>():
          rawIngredients.add(convertIngredientToRawIngredient(result.value));
        case Error<Ingredient>():
          throw ImportExportError('At least 1 ingredient does not exists');
      }
    }
    return rawIngredients.toList();
  }

  List<IngredientTypes> _getIngredientTypes(List<RawIngredient> rawIngredients) {
    Set<IngredientTypes> ingredientTypes = <IngredientTypes>{};
    Map<int, IngredientTypes> allIngredientTypes = _ingredientRepository.ingredientTypes;
    try {
      for (var rawIngredient in rawIngredients) {
        ingredientTypes.add(allIngredientTypes[rawIngredient.type]!);
      }
    } on Exception {
      throw ImportExportError('At least 1 ingredient does not have a type');
    }
    return ingredientTypes.toList();
  }

  List<IngredientUnit> _getIngredientUnits(
    List<RawIngredientWithQuantity> rawIngredientWithQuantities,
  ) {
    Set<int> ingredientUnitsIds = <int>{};
    for (var rawIngredientWithQuantity in rawIngredientWithQuantities) {
      ingredientUnitsIds.add(rawIngredientWithQuantity.unit);
    }

    return ingredientUnitsIds
        .map((id) => _ingredientUnitsRepository.ingredientUnitsById[id]!)
        .toList();
  }

  Future<void> importData(String encodedImportData) async {
    ImportData importData = await _loadImportData(encodedImportData);
    if (importData.version != 1) {
      throw ImportExportError('Invalid version');
    }

    Map<int, Ingredient> mappedIngredients = await _importIngredients(importData);
    Map<int, RawIngredientWithQuantity> mappedIngredientsWithQuantity =
        await _importIngredientsWithQuantity(importData, mappedIngredients);
    await _importRecipes(importData, mappedIngredientsWithQuantity);
  }

  Future<ImportData> _loadImportData(String encodedImportData) async {
    final recipesAsString = stringToBase64.decode(encodedImportData);
    final json = await _loadStringRecipe(recipesAsString);
    return ImportData.fromJson(json);
  }

  Future<Map<String, dynamic>> _loadStringRecipe(String recipesAsString) async {
    return jsonDecode(recipesAsString) as Map<String, dynamic>;
  }

  Future<Map<int, Ingredient>> _importIngredients(ImportData importData) async {
    Map<int, Ingredient> ingredientsUsedInImports = {};
    for (var ingredientToImport in importData.rawIngredients) {
      Ingredient ingredient = await _getOrCreateIngredient(
        ingredientToImport,
        importData.ingredientTypes,
      );
      print(importData);
      ingredientsUsedInImports[ingredientToImport.id!] = ingredient;
    }
    return ingredientsUsedInImports;
  }

  Future<Map<int, RawIngredientWithQuantity>> _importIngredientsWithQuantity(
    ImportData importData,
    Map<int, Ingredient> ingredients,
  ) async {
    Map<int, IngredientUnit> mappedIngredientsUnits = await _importIngredientUnits(
      importData.ingredientUnits,
    );
    Map<int, RawIngredientWithQuantity> ingredientsWithQuantity = {};

    for (var rawIngredientWithQuantityToImport in importData.rawIngredientsWithQuantity) {
      final RawIngredientWithQuantity rawIngredientWithQuantity = rawIngredientWithQuantityToImport
          .copyWith(
            ingredientId: ingredients[rawIngredientWithQuantityToImport.ingredientId]!.id!,
            unit: mappedIngredientsUnits[rawIngredientWithQuantityToImport.unit]!.id!,
          );
      final result = await _ingredientWithQuantityRepository.addRawIngredientWithQuantity(
        rawIngredientWithQuantity,
      );
      switch (result) {
        case Ok<RawIngredientWithQuantity>():
          ingredientsWithQuantity[rawIngredientWithQuantityToImport.id!] = result.value;
        case Error<RawIngredientWithQuantity>():
          throw ImportExportError('Could not add ingredientWithQuantity');
      }
    }
    return ingredientsWithQuantity;
  }

  Future<void> _importRecipes(
    ImportData importData,
    Map<int, RawIngredientWithQuantity> mappedIngredientsWithQuantity,
  ) async {
    for (var rawRecipeToImport in importData.rawRecipes) {
      List<int> ingredientsWithQuantity = rawRecipeToImport.ingredientWithQuantityIds
          .map((id) => mappedIngredientsWithQuantity[id]!.id!)
          .toList();
      var rawRecipe = rawRecipeToImport.copyWith(
        ingredientWithQuantityIds: ingredientsWithQuantity,
      );
      await _recipeRepository.addRecipe(rawRecipe);
    }
  }

  Future<Ingredient> _getOrCreateIngredient(
    RawIngredient ingredientToImport,
    List<IngredientTypes> ingredientTypes,
  ) async {
    final result = await _ingredientRepository.getIngredientByName(ingredientToImport.name);
    print(result);
    switch (result) {
      case Ok<Ingredient>():
        return result.value;
      case Error<Ingredient>():
        return await _createIngredient(ingredientToImport, ingredientTypes);
    }
  }

  Future<Ingredient> _createIngredient(
    RawIngredient ingredientToImport,
    List<IngredientTypes> ingredientTypes,
  ) async {
    IngredientTypes importedIngredientType = ingredientTypes
        .where((element) => element.id == ingredientToImport.type)
        .first;
    List<IngredientTypes> possibleIngredientType = _ingredientRepository.ingredientTypes.values
        .toList()
        .where((element) => element.name == importedIngredientType.name)
        .toList();
    Ingredient ingredient = Ingredient(
      name: ingredientToImport.name,
      type: possibleIngredientType.isEmpty ? importedIngredientType : possibleIngredientType.first,
    );
    final result = await _ingredientRepository.addIngredient(ingredient);
    switch (result) {
      case Ok<Ingredient>():
        return result.value;
      case Error<Ingredient>():
        throw ImportExportError('Could not create ingredient');
    }
  }

  Future<Map<int, IngredientUnit>> _importIngredientUnits(
    List<IngredientUnit> ingredientUnits,
  ) async {
    Map<int, IngredientUnit> mappedIngredientsUnits = {};
    for (var ingredientUnit in ingredientUnits) {
      try {
        mappedIngredientsUnits[ingredientUnit.id!] =
            _ingredientUnitsRepository.ingredientUnitsByName[ingredientUnit.name]!;
      } on Exception {
        throw ImportExportError('Ingredients unit unkown');
      }
    }
    return mappedIngredientsUnits;
  }
}

class ImportExportError implements Exception {
  String cause;

  ImportExportError(this.cause);
}
