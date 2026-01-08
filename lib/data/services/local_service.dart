import 'dart:convert';

import 'package:flutter/services.dart';

import '../../config/assets.dart';
import 'models/raw_recipe.dart';

class LocalDataService {
  Future<List<RawRecipe>> getRecipes() async {
    final json = await _loadStringAsset(Assets.recipes);
    return json.map<RawRecipe>(RawRecipe.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> _loadStringAsset(String asset) async {
    final localData = await rootBundle.loadString(asset);
    return (jsonDecode(localData) as List).cast<Map<String, dynamic>>();
  }
}
