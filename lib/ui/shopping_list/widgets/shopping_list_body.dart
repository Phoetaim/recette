import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recette/domain/models/shopping_list/shopping_ingredient.dart';
import 'package:recette/ui/ingredients_utils/view_model/ingredients_utils_viewmodel.dart';
import 'package:recette/ui/ingredients_utils/widgets/ingredient_search_widget.dart';
import 'package:recette/ui/shopping_list/view_model/shopping_list_viewmodel.dart';
import 'package:recette/ui/shopping_list/widgets/shopping_list_slivers.dart';

class ShoppingListBody extends StatelessWidget {
  const ShoppingListBody({super.key, required this.viewModel});

  final ShoppingListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IngredientSearch(
          viewModel: IngredientsUtilsViewModel(
            ingredientRepository: context.read(),
            ingredientUnitsRepository: context.read(),
          ),
          callbackForIngredient: viewModel.addToShoppingList,
        ),
        ListenableBuilder(
          listenable: Listenable.merge([viewModel.initShoppingList, viewModel]),
          builder: (context, value) {
            if (viewModel.initShoppingList.running) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.initShoppingList.error) {
              return Text('Failed to load recipe list');
            }

            ShoppingList shoppingList = viewModel.shoppingList;
            shoppingList.sort(compareShoppingIngredients);
            return Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ListTile(
                      title: Text('Ingrédients à acheter'),
                      trailing: TextButton(
                        onPressed: viewModel.clearShoppingList,
                        child: Icon(Icons.checklist),
                      ),
                    ),
                  ),
                  ShoppingListSlivers(viewModel: viewModel, shoppingList: shoppingList),
                  SliverToBoxAdapter(
                    child: ListTile(
                      title: Text('Ingrédients récemment achetés'),
                      trailing: TextButton(
                        onPressed: viewModel.deleteAllBoughtIngredients,
                        child: Icon(Icons.delete_forever_rounded),
                      ),
                    ),
                  ),
                  ShoppingListSlivers(
                    viewModel: viewModel,
                    shoppingList: viewModel.shoppingListBought.reversed.toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
