import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/shopping_list/shopping_ingredient.dart';
import 'package:recette/ui/ingredient_search/view_model/ingredient_search_viewmodel.dart';
import 'package:recette/ui/ingredient_search/widgets/ingredient_search_widget.dart';
import '../../../data/services/models/raw_ingredient_with_quantity.dart';
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
                return ShoppingListToBuy(viewModel: viewModel);
              },
            );
          },
        ),
      ],
    );
  }
}

class ShoppingListToBuy extends StatelessWidget {
  const ShoppingListToBuy({super.key, required this.viewModel});

  final ShoppingListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: viewModel.shoppingList.length,
        itemBuilder: (BuildContext context, int index) {
          return ShoppingIngredientCard(
            viewModel: viewModel,
            shoppingIngredient: viewModel.shoppingList[index],
          );
        },
      ),
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
    return CheckboxListTile(
      contentPadding: const EdgeInsets.all(6.0),
      controlAffinity: ListTileControlAffinity.leading,
      value: shoppingIngredient.bought,
      onChanged: (bool? value) {
        viewModel.removeFromShoppingList(shoppingIngredient);
      },
      title: Text(ingredientWithQuantity.ingredient.name),

      secondary: Builder(
        builder: (context) {
          if (ingredientWithQuantity.unit == IngredientUnit.unit) {
            return Text(ingredientWithQuantity.quantity.toInt().toString());
          }
          return Text(
            '${ingredientWithQuantity.quantity.toInt().toString()} ${ingredientWithQuantity.unit.name}',
          );
        },
      ),
    );
  }
}
