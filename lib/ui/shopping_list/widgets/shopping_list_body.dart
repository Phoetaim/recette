import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/shopping_list/shopping_ingredient.dart';
import 'package:recette/ui/ingredient_search/view_model/ingredient_search_viewmodel.dart';
import 'package:recette/ui/ingredient_search/widgets/ingredient_search_widget.dart';
import '../../ingredient_search/widgets/quantity_tile.dart';
import '../view_model/shopping_list_viewmodel.dart';

class ShoppingListBody extends StatelessWidget {
  const ShoppingListBody({super.key, required this.viewModel});

  final ShoppingListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IngredientSearch(
          viewModel: IngredientSearchViewModel(ingredientRepository: context.read()),
          callbackForIngredient: viewModel.addToShoppingList,
        ),
        ListenableBuilder(
          listenable: viewModel.initShoppingList,
          builder: (context, value) {
            if (viewModel.initShoppingList.running) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.initShoppingList.error) {
              return Text('Failed to load recipe list');
            }
            return ListenableBuilder(
              listenable: viewModel,
              builder: (context, value) {
                ShoppingList shoppingList = viewModel.shoppingList;
                shoppingList.sort(sortShoppingList);
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
                      ShoppingListSlivers(
                        viewModel: viewModel,
                        shoppingList: shoppingList,
                      ),
                      SliverToBoxAdapter(
                        child: ListTile(
                          title: Text('Ingrédients récemment achetés'),
                          trailing: TextButton(
                            onPressed: viewModel.deleteAllBoughtIngredients,
                            child: Icon(Icons.remove_shopping_cart),
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
            );
          },
        ),
      ],
    );
  }
}

class ShoppingListSlivers extends StatelessWidget {
  const ShoppingListSlivers({super.key, required this.viewModel, required this.shoppingList});

  final ShoppingListViewModel viewModel;
  final ShoppingList shoppingList;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: shoppingList.length,
      itemBuilder: (BuildContext context, int index) {
        return ShoppingIngredientCard(
          viewModel: viewModel,
          shoppingIngredient: shoppingList[index],
        );
      },
    );
  }
}

class ShoppingIngredientCard extends StatelessWidget {
  const ShoppingIngredientCard({
    super.key,
    required this.viewModel,
    required this.shoppingIngredient,
  });

  final ShoppingListViewModel viewModel;
  final ShoppingIngredient shoppingIngredient;

  @override
  Widget build(BuildContext context) {
    IngredientWithQuantity ingredientWithQuantity = shoppingIngredient.ingredientWithQuantity;
    return Dismissible(
      key: Key(shoppingIngredient.id!.toString()),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red, child: Icon(Icons.delete)),
      onDismissed: (direction) {
        viewModel.deleteShoppingIngredient(shoppingIngredient);
      },
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: shoppingIngredient.bought,
        onChanged: (bool? value) {
          viewModel.toggleShoppingIngredientStatus(shoppingIngredient);
        },
        title: Text(ingredientWithQuantity.ingredient.name),

        secondary: Builder(
          builder: (context) {
            return QuantityTile(ingredientWithQuantity: shoppingIngredient.ingredientWithQuantity,);
          },
        ),
      ),
    );
  }
}
