import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/shopping_list/view_model/shopping_list_viewmodel.dart';
import 'package:recette/ui/ui_utils/styles.dart';
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
            context.goNamed(Routes.shoppingList);
          },
          child: Icon(Icons.home),
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
    final theme = Theme.of(context);
    return [
      MenuBar(
        style: MenuStyle(
          elevation: WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(theme.colorScheme.primaryContainer),
        ),
        children: [
          SubmenuButton(
            menuChildren: _getMenuItemButtons(),
            menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(theme.colorScheme.secondaryContainer)),
            child: Icon(Icons.more_vert, color: theme.colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    ];
  }

  List<MenuEntry> _getMenuItemButtons() {
    return [
      MenuEntry(
        child: MenuItemButton(
          style: getMenuButtonStyle(context),
          onPressed: () => context.pushNamed(Routes.ingredientList),
          child: Row(
            children: [
              Icon(Icons.food_bank),
              SizedBox(width: 8),
              Text('Ingrédients', style: getTextStyle(context)),
            ],
          ),
        ),
      ),
      MenuEntry(
        child: MenuItemButton(
          style: getMenuButtonStyle(context),
          onPressed: () => widget.viewModel.exportShoppingList(),
          child: Row(
            children: [
              Icon(exportIcon),
              SizedBox(width: 8),
              Text('Exporter', style: getTextStyle(context)),
            ],
          ),
        ),
      ),
      MenuEntry(
        child: MenuItemButton(
          style: getMenuButtonStyle(context),
          onPressed: () => widget.viewModel.importShoppingList.execute(),
          child: Row(
            children: [
              Icon(importIcon),
              SizedBox(width: 8),
              Text('Importer', style: getTextStyle(context)),
            ],
          ),
        ),
      ),
    ];
  }
}

class MenuEntry extends StatelessWidget {
  const MenuEntry({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
