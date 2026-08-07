import 'package:flutter/material.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/shopping_list/shopping_ingredient.dart';
import 'package:recette/ui/ingredients_utils/widgets/quantity_tile.dart';
import 'package:recette/ui/shopping_list/view_model/shopping_list_viewmodel.dart';

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
        title: Row(
          children: [
            shoppingIngredient.ingredientWithQuantity.ingredient.type.getIcon(),
            SizedBox(width: 8),
            Text(ingredientWithQuantity.ingredient.name),
          ],
        ),

        secondary: Builder(
          builder: (context) {
            return QuantityTile(ingredientWithQuantity: shoppingIngredient.ingredientWithQuantity);
          },
        ),
      ),
    );
  }
}
