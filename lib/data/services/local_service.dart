import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:recette/domain/recipe/recipe.dart';

import '../../config/assets.dart';

class LocalDataService {
  Future<List<Recipe>> getRecipes() async {
    final json = await _loadStringAsset(Assets.recipes);
    return json.map<Recipe>(Recipe.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> _loadStringAsset(String asset) async {
      final localData = await rootBundle.loadString(asset);
      return (jsonDecode(localData) as List).cast<Map<String, dynamic>>();
    }
}