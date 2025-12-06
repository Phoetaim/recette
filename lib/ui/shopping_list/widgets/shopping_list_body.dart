import 'package:flutter/material.dart';
import '../view_model/shopping_list_viewmodel.dart';

class ShoppingListBody extends StatelessWidget {
  const ShoppingListBody({super.key, required this.viewModel});

  final ShoppingListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: viewModel.getShoppingList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Text(viewModel.getShoppingList[index].ingredient.ingredientId.toString()),
                  Divider(),
                ],
              );
            },
          );
  }
}
