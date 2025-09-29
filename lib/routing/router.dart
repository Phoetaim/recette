import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';
import '../ui/recipe_list/widgets/recipe_list_screen.dart';

import 'routes.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.recipeList,
  routes: [
    GoRoute(path: Routes.recipeList,
    builder: (context, state){
      return RecipeListScreen(
        viewModel: RecipeListViewModel(recipeRepository: context.read()),
          );
    }),
  ]
);