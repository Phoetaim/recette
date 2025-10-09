import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/ingredient/ingredient_repository.dart';
import '../data/repositories/recipe/recipe_repository.dart';
import '../data/services/local_service.dart';

List<SingleChildWidget> get providersLocal {
  return [
    Provider.value(value: LocalDataService()),
    Provider(create: (context) => RecipeRepository(localDataService: context.read())),
    Provider(create: (context) => IngredientRepository()),
  ];
}
