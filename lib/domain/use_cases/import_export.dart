import 'dart:convert';

import 'package:flutter/services.dart';

import '../../data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import '../../data/repositories/ingredient/ingredient_repository.dart';
import '../../data/repositories/ingredient/ingredient_units_repository.dart';
import '../../data/repositories/recipe/recipe_repository.dart';
import '../../data/repositories/shopping_list/shopping_list_repository.dart';
import '../../data/services/models/import_data.dart';
import '../../data/services/models/raw_ingredient.dart';
import '../../data/services/models/raw_ingredient_with_quantity.dart';
import '../../data/services/models/raw_recipe.dart';
import '../../utils/result.dart';
import '../models/ingredient/ingredient.dart';
import '../models/ingredient/ingredient_types.dart';
import '../models/ingredient/ingredient_units.dart';
import '../models/ingredient/ingredient_with_quantity.dart';
import 'ingredient_with_quantity.dart';

Codec<String, String> stringToBase64 = utf8.fuse(base64);

class ImportExportUseCase {
  ImportExportUseCase({
    required IngredientRepository ingredientRepository,
    required IngredientWithQuantityRepository ingredientWithQuantityRepository,
    required IngredientUnitsRepository ingredientUnitsRepository,
    required RecipeRepository recipeRepository,
    required IngredientWithQuantityUseCase ingredientWithQuantityUseCase,
    required ShoppingListRepository shoppingListRepository,
  }) : _ingredientRepository = ingredientRepository,
       _ingredientWithQuantityRepository = ingredientWithQuantityRepository,
       _ingredientUnitsRepository = ingredientUnitsRepository,
       _recipeRepository = recipeRepository,
       _ingredientWithQuantityUseCase = ingredientWithQuantityUseCase,
       _shoppingListRepository = shoppingListRepository;

  final IngredientRepository _ingredientRepository;
  final IngredientWithQuantityRepository _ingredientWithQuantityRepository;
  final IngredientUnitsRepository _ingredientUnitsRepository;
  final RecipeRepository _recipeRepository;
  final IngredientWithQuantityUseCase _ingredientWithQuantityUseCase;
  final ShoppingListRepository _shoppingListRepository;

  // Public
  Future<void> exportRecipes(List<RawRecipe> rawRecipes) async {
    List<int> ingredientWithQuantityIds = await _getIngredientWithQuantityIds(rawRecipes);
    ImportData export = await _getCommonImportData(ingredientWithQuantityIds);

    _copyToClipboard(export.copyWith(rawRecipes: rawRecipes));
  }

  Future<void> exportShoppingList(RawShoppingList rawShoppingList) async {
    List<int> ingredientWithQuantityIds = rawShoppingList
        .map((element) => element.ingredientWithQuantityId)
        .toList();

    ImportData export = await _getCommonImportData(ingredientWithQuantityIds);

    _copyToClipboard(export.copyWith(isShoppingList: true));
  }

  Future<void> importData(String encodedImportData) async {
    ImportData importData = await _loadImportData(encodedImportData);
    if (importData.version != 0) {
      throw ImportExportError('Invalid version');
    }

    Map<int, Ingredient> mappedIngredients = await _importIngredients(importData);
    Map<int, RawIngredientWithQuantity> mappedIngredientsWithQuantity =
        await _importIngredientsWithQuantity(importData, mappedIngredients);
    await _importRecipes(importData, mappedIngredientsWithQuantity);
    await _importRawShoppingList(importData, mappedIngredientsWithQuantity);
  }

  // Private
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

  Future<ImportData> _getCommonImportData(List<int> ingredientWithQuantityIds) async {
    List<RawIngredientWithQuantity> rawIngredientsWithQuantities =
        await _getRawIngredientsWithQuantities(ingredientWithQuantityIds);

    List<RawIngredient> rawIngredients = await _getRawIngredients(rawIngredientsWithQuantities);

    List<IngredientTypes> ingredientTypes = _getIngredientTypes(rawIngredients);
    List<IngredientUnit> ingredientUnits = _getIngredientUnits(rawIngredientsWithQuantities);

    return ImportData(
      rawIngredientsWithQuantity: rawIngredientsWithQuantities,
      rawIngredients: rawIngredients,
      ingredientTypes: ingredientTypes,
      ingredientUnits: ingredientUnits,
    );
  }

  void _copyToClipboard(ImportData data) {
    final encodedData = stringToBase64.encode(jsonEncode(data.toJson()));
    Clipboard.setData(ClipboardData(text: encodedData));
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
    Map<int, RawIngredientWithQuantity> rawIngredientsWithQuantity = {};

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
          rawIngredientsWithQuantity[rawIngredientWithQuantityToImport.id!] = result.value;
        case Error<RawIngredientWithQuantity>():
          throw ImportExportError('Could not add ingredientWithQuantity');
      }
    }
    return rawIngredientsWithQuantity;
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

  Future<void> _importRawShoppingList(
    ImportData importData,
    Map<int, RawIngredientWithQuantity> mappedIngredientsWithQuantity,
  ) async {
    if (!importData.isShoppingList) {
      return;
    }
    var result = await _ingredientWithQuantityUseCase.getIngredientWithQuantityByIds(
      mappedIngredientsWithQuantity.values.map((element) => element.id!).toList(),
    );
    switch (result) {
      case Ok<List<Map<Object, Object>>>():
        List<IngredientWithQuantity> ingredientWithQuantities = result.value
            .map((element) => IngredientWithQuantity.fromJson(Map<String, Object>.from(element)))
            .toList();
        _createShoppingIngredients(ingredientWithQuantities);
      case Error<List<Map<Object, Object>>>():
        throw ImportExportError('Could not get ingredients with quantity');
    }
  }

  Future<Ingredient> _getOrCreateIngredient(
    RawIngredient ingredientToImport,
    List<IngredientTypes> ingredientTypes,
  ) async {
    final result = await _ingredientRepository.getIngredientByName(ingredientToImport.name);
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

  Future<void> _createShoppingIngredients(
    List<IngredientWithQuantity> ingredientWithQuantities,
  ) async {
    for (var ingredientWithQuantity in ingredientWithQuantities) {
      await _shoppingListRepository.addShoppingIngredient(ingredientWithQuantity);
    }
  }
}

class ImportExportError implements Exception {
  String cause;

  ImportExportError(this.cause);
}
