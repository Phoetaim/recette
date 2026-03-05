import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
import '../view_model/shopping_list_viewmodel.dart';
import 'shopping_list_body.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key, required this.viewModel});

  final ShoppingListViewModel viewModel;

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            context.go(Routes.recipeList);
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text('Liste de courses'),
        shadowColor: Colors.black,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [TextButton(onPressed: () => widget.viewModel.clearShoppingList(), child: Icon(Icons.clear_all))],
      ),
      body: ShoppingListBody(viewModel: widget.viewModel),
    );
  }

}
