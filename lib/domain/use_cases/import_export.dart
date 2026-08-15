import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:recette/data/repositories/ingredient/ingredient_id_with_quantity_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';
import 'package:recette/data/repositories/recipe/recipe_repository.dart';
import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';
import 'package:recette/data/services/models/import_data.dart';
import 'package:recette/data/services/models/raw_ingredient.dart';
import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/ui/shopping_list/view_model/shopping_list_viewmodel.dart';
import 'package:recette/utils/result.dart';

Codec<String, String> stringToBase64 = utf8.fuse(base64);

class ImportExportUseCase {
  ImportExportUseCase({
    required IngredientRepository ingredientRepository,
    required IngredientWithQuantityRepository ingredientWithQuantityRepository,
    required IngredientUnitsRepository ingredientUnitsRepository,
    required RecipeRepository recipeRepository,
    required ShoppingListRepository shoppingListRepository,
  }) : _ingredientRepository = ingredientRepository,
       _ingredientWithQuantityRepository = ingredientWithQuantityRepository,
       _ingredientUnitsRepository = ingredientUnitsRepository,
       _recipeRepository = recipeRepository,
       _shoppingListRepository = shoppingListRepository;

  final IngredientRepository _ingredientRepository;
  final IngredientWithQuantityRepository _ingredientWithQuantityRepository;
  final IngredientUnitsRepository _ingredientUnitsRepository;
  final RecipeRepository _recipeRepository;
  final ShoppingListRepository _shoppingListRepository;

  // Public

  Future<void> exportRecipes(Set<int> recipesIds) async {
    List<RawRecipe> rawRecipes = await _getCompletedRawRecipes(recipesIds);
    List<int> ingredientWithQuantityIds = await _getIngredientWithQuantityIds(rawRecipes);
    ImportData export = await _getCommonImportData(ingredientWithQuantityIds);
    await _copyToClipboard(export.copyWith(rawRecipes: rawRecipes));
  }

  Future<void> exportShoppingList(ShoppingList shoppingList) async {
    List<int> ingredientWithQuantityIds = shoppingList
        .map((element) => element.ingredientWithQuantity.id!)
        .toList();

    ImportData export = await _getCommonImportData(ingredientWithQuantityIds);
    await _copyToClipboard(export.copyWith(isShoppingList: true));
  }

  Future<ImportData> loadImportData(String encodedImportData) async {
    final jsonAsString = stringToBase64.decode(encodedImportData);
    final json = await _loadStringRecipe(jsonAsString);
    final importData = ImportData.fromJson(json);
    if (importData.version != 0) {
      throw ImportExportError('Invalid version');
    }
    return importData;
  }

  Future<void> importRecipes(ImportData importData, Set<int> recipeIds) async {
    if (importData.version != 0) {
      throw ImportExportError('Invalid version');
    }
    ImportData filteredImportData = _filterRawRecipeImportData(importData, recipeIds);
    Map<int, Ingredient> mappedIngredients = await _importIngredients(filteredImportData);
    Map<int, IngredientUnit> mappedIngredientsUnits = await _importIngredientUnits(
      filteredImportData.ingredientUnits,
    );
    Map<int, RawIngredientWithQuantity> mappedIngredientsWithQuantity =
        await _importIngredientsWithQuantity(
          filteredImportData,
          mappedIngredients,
          mappedIngredientsUnits,
        );
    await _importRecipes(filteredImportData, mappedIngredientsWithQuantity);
  }

  Future<void> importShoppingList(String encodedImportData) async {
    ImportData importData = await loadImportData(encodedImportData);
    Map<int, Ingredient> mappedIngredients = await _importIngredients(importData);
    Map<int, IngredientUnit> mappedIngredientsUnits = await _importIngredientUnits(
      importData.ingredientUnits,
    );
    await _importShoppingList(importData, mappedIngredients, mappedIngredientsUnits);
  }

  // Export

  Future<List<RawRecipe>> _getCompletedRawRecipes(Set<int> recipeIds) async {
    List<RawRecipe> completedRawRecipes = <RawRecipe>[];
    for (var recipeId in recipeIds) {
      final result = await _recipeRepository.getRecipe(recipeId);
      switch (result) {
        case Ok<RawRecipe>():
          completedRawRecipes.add(result.value);
        case Error<RawRecipe>():
          throw ImportExportError('Could not retrieve at least one recipe');
      }
    }
    return completedRawRecipes;
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

  Future<void> _copyToClipboard(ImportData data) async {
    final encodedData = stringToBase64.encode(jsonEncode(data.toJson()));
    await Clipboard.setData(ClipboardData(text: encodedData));
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

  // Import

  Future<Map<String, dynamic>> _loadStringRecipe(String jsonAsString) async {
    return jsonDecode(jsonAsString) as Map<String, dynamic>;
  }

  ImportData _filterRawRecipeImportData(ImportData importData, Set<int> recipeIds) {
    List<RawRecipe> filteredRawRecipe = [];
    Set<int> ingredientWithQuantitiesIds = {};

    for (var rawRecipe in importData.rawRecipes) {
      if (recipeIds.contains(rawRecipe.id!)) {
        filteredRawRecipe.add(rawRecipe);
        ingredientWithQuantitiesIds.addAll(rawRecipe.ingredientWithQuantityIds);
      }
    }
    importData = _filterIngredientWithQuantity(importData, ingredientWithQuantitiesIds);
    return importData.copyWith(rawRecipes: filteredRawRecipe);
  }

  ImportData _filterIngredientWithQuantity(
    ImportData importData,
    Set<int> ingredientWithQuantitiesIds,
  ) {
    List<RawIngredientWithQuantity> filteredIngredientWithQuantities = [];
    Set<int> ingredientsIds = {};
    for (var ingredientWithQuantity in importData.rawIngredientsWithQuantity) {
      if (ingredientWithQuantitiesIds.contains(ingredientWithQuantity.id!)) {
        filteredIngredientWithQuantities.add(ingredientWithQuantity);
        ingredientsIds.add(ingredientWithQuantity.ingredientId);
      }
    }
    importData = _filterIngredients(importData, ingredientsIds);

    return importData.copyWith(rawIngredientsWithQuantity: filteredIngredientWithQuantities);
  }

  ImportData _filterIngredients(ImportData importData, Set<int> ingredientsIds) {
    List<RawIngredient> filteredIngredients = [];
    for (var ingredients in importData.rawIngredients) {
      if (ingredientsIds.contains(ingredients.id!)) {
        filteredIngredients.add(ingredients);
      }
    }
    return importData.copyWith(rawIngredients: filteredIngredients);
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

  Future<Map<int, IngredientUnit>> _importIngredientUnits(
    List<IngredientUnit> ingredientUnits,
  ) async {
    Map<int, IngredientUnit> mappedIngredientsUnits = {};
    for (var ingredientUnit in ingredientUnits) {
      try {
        mappedIngredientsUnits[ingredientUnit.id!] =
            _ingredientUnitsRepository.ingredientUnitsByName[ingredientUnit.name.toLowerCase()]!;
      } on TypeError {
        throw ImportExportError('Ingredients unit unknown');
      }
    }
    return mappedIngredientsUnits;
  }

  Future<Map<int, RawIngredientWithQuantity>> _importIngredientsWithQuantity(
    ImportData importData,
    Map<int, Ingredient> ingredients,
    Map<int, IngredientUnit> mappedIngredientsUnits,
  ) async {
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

  Future<void> _importShoppingList(
    ImportData importData,
    Map<int, Ingredient> mappedIngredients,
    Map<int, IngredientUnit> mappedUnits,
  ) async {
    if (!importData.isShoppingList) {
      return;
    }
    List<IngredientWithQuantity> ingredientWithQuantities = importData.rawIngredientsWithQuantity
        .map(
          (element) => IngredientWithQuantity(
            ingredient: mappedIngredients[element.ingredientId]!,
            quantity: element.quantity,
            unit: mappedUnits[element.unit]!,
          ),
        )
        .toList();
    bool hasError = false;
    for (var ingredientWithQuantity in ingredientWithQuantities) {
      var result = await _shoppingListRepository.addShoppingIngredient(ingredientWithQuantity);
      if (result is Error<void>) {
        hasError = true;
      }
    }
    if (hasError) {
      throw ImportExportError('Could not add at least one ingredient');
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
}

class ImportExportError implements Exception {
  String cause;

  ImportExportError(this.cause);
}
