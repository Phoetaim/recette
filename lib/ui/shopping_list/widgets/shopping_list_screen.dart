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
  void initState() {
    super.initState();
    widget.viewModel.removeFromShoppingList.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant ShoppingListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.removeFromShoppingList.removeListener(_onResult);
    widget.viewModel.removeFromShoppingList.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.removeFromShoppingList.removeListener(_onResult);
    super.dispose();
  }

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
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.loadShoppingList,
        builder: (context, child) {
          if (widget.viewModel.loadShoppingList.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.loadShoppingList.error) {
            return TextButton(onPressed: () => context.go(Routes.recipeList), child: Text('Return to recipe list?'));
          }
          return ShoppingListBody(viewModel: widget.viewModel);
        },
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.removeFromShoppingList.completed) {
      context.go(Routes.recipeList);
    }

    if (widget.viewModel.removeFromShoppingList.error) {
      widget.viewModel.removeFromShoppingList.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while loading')));
    }
  }
}
