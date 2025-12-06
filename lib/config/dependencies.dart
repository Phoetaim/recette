import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:recette/data/repositories/shopping_list/shopping_list_repository.dart';

import '../data/repositories/ingredient/ingredient_repository.dart';
import '../data/repositories/recipe/recipe_repository.dart';
import '../data/services/local_service.dart';

List<SingleChildWidget> get providersLocal {
  return [
    Provider.value(value: LocalDataService()),
    Provider(create: (context) => RecipeRepository(localDataService: context.read())),
    Provider(create: (context) => IngredientRepository()),
    Provider(create: (context) => ShoppingListRepository()),
  ];
}
