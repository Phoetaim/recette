import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recette/ui/ingredient_list/view_model/ingredient_list_viewmodel.dart';
import 'package:recette/ui/ingredient_list/widgets/ingredient_list_screen.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';
import 'package:recette/ui/recipe_detail/widgets/recipe_detail_screen.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';
import 'package:recette/ui/recipe_list/widgets/recipe_list_screen.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_viewmodel.dart';
import 'package:recette/ui/recipe_planning/widget/recipe_planning_screen.dart';
import 'package:recette/ui/shopping_list/view_model/shopping_list_viewmodel.dart';
import 'package:recette/ui/shopping_list/widgets/shopping_list_screen.dart';

import 'routes.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.shoppingList,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder:
          (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
            return ScaffoldBottomNavigationBar(navigationShell: navigationShell);
          },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: Routes.shoppingList,
              path: Routes.shoppingList,
              builder: (context, state) {
                return ShoppingListScreen(
                  viewModel: ShoppingListViewModel(
                    ingredientRepository: context.read(),
                    ingredientWithQuantityUseCase: context.read(),
                    shoppingListRepository: context.read(),
                    importExportUseCase: context.read(),
                  ),
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  name: Routes.ingredientList,
                  path: Routes.ingredientList,
                  builder: (context, state) {
                    return IngredientListScreen(
                      viewModel: IngredientListViewModel(ingredientRepository: context.read()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: Routes.recipePlanning,
              path: Routes.recipePlanning,
              builder: (context, state) {
                return RecipePlanningScreen(
                  viewModel: RecipePlanningViewModel(
                    recipeRepository: context.read(),
                    recipeUtilsUseCase: context.read(),
                    planningRepository: context.read(),
                  ),
                );
              },
              routes: [
                GoRoute(
                  name: Routes.recipeList,
                  path: Routes.recipeList,
                  builder: (context, state) {
                    return RecipeListScreen(
                      viewModel: RecipeListViewModel(
                        recipeRepository: context.read(),
                        importExportUseCase: context.read(),
                      ),
                    );
                  },
                ),
                GoRoute(
                  name: Routes.recipeDetail,
                  path: '${Routes.recipeDetail}/:recipeId',
                  builder: (context, state) {
                    return RecipeDetailScreen(
                      viewModel: RecipeDetailViewModel(
                        recipeRepository: context.read(),
                        ingredientWithQuantityUseCase: context.read(),
                        recipeUtilsUseCase: context.read(),
                        importExportUseCase: context.read(),
                      ),
                      recipeId: state.pathParameters['recipeId'],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldBottomNavigationBar extends StatelessWidget {
  const ScaffoldBottomNavigationBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldBottomNavigationBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book_fill), label: 'Planning'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int tappedIndex) {
          navigationShell.goBranch(tappedIndex);
        },
      ),
    );
  }
}
