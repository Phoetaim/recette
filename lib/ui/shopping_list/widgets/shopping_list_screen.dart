import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/ui_utils/import_alert_box.dart';
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
        actions: _getActionList(),
        shadowColor: Colors.black,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ShoppingListBody(viewModel: widget.viewModel),
    );
  }

  List<Widget> _getActionList() {
    return [
      TextButton.icon(
        onPressed: () => widget.viewModel.exportShoppingList(),
        label: Icon(Icons.arrow_upward),
      ),
      ImportButton(callback: widget.viewModel.importShoppingList),
    ];
  }
}
