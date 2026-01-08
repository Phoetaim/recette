import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recette/ui/ingredient_list/view_model/ingredient_list_viewmodel.dart';
import 'package:recette/ui/ingredient_list/widgets/ingredient_list_screen.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';
import 'package:recette/ui/shopping_list/view_model/shopping_list_viewmodel.dart';
import 'package:recette/ui/shopping_list/widgets/shopping_list_screen.dart';
import '../ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';
import '../ui/recipe_detail/widgets/recipe_detail_screen.dart';
import '../ui/recipe_list/widgets/recipe_list_screen.dart';

import 'routes.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.recipeList,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
        return ScaffoldBottomNavigationBar(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.recipeList,
              builder: (context, state) {
                return RecipeListScreen(viewModel: RecipeListViewModel(recipeRepository: context.read()));
              },
              routes: [
                GoRoute(
                  name: Routes.recipeDetail,
                  path: '${Routes.recipeDetail}/:recipeId',
                  builder: (context, state) {
                    return RecipeDetailScreen(
                      viewModel: RecipeDetailViewModel(
                        recipeRepository: context.read(),
                        ingredientWithQuantityUseCase: context.read(),
                      ),
                      recipeId: state.pathParameters['recipeId'],
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
              path: Routes.ingredientList,
              builder: (context, state) {
                return IngredientListScreen(viewModel: IngredientListViewModel(ingredientRepository: context.read()));
              },
            ),
          ],
        ),

       StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.shoppingList,
              builder: (context, state) {
                return ShoppingListScreen(viewModel: ShoppingListViewModel(
                  ingredientRepository: context.read(),
                  shoppingListRepository: context.read(),
                ));
              },
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
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Recettes'),
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Ingrédients'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Liste'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int tappedIndex) {
          navigationShell.goBranch(tappedIndex);
        },
      ),
    );
  }
}
