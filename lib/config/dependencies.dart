import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/recipe/recipe_repository.dart';

List<SingleChildWidget> get providersLocal {
  return [
    Provider(
      create: (context) =>
          RecipeRepository(),
    ),
  ];
}