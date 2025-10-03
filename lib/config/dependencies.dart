import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';

import '../data/repositories/recipe/recipe_repository.dart';

List<SingleChildWidget> get providersLocal {
  return [
    Provider(
      create: (context) =>
          RecipeRepository(),
    ),
    Provider(
      create: (context) =>
          IngredientRepository(),
    ),
  ];
}