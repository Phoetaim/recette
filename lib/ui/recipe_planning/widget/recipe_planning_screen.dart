import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_view_model.dart';
import 'package:recette/ui/ui_utils/styles.dart';

import 'recipe_planning_body.dart';

class RecipePlanningScreen extends StatefulWidget {
  const RecipePlanningScreen({super.key, required this.viewModel});

  final RecipePlanningViewModel viewModel;

  @override
  State<RecipePlanningScreen> createState() => _RecipePlanningScreenState();
}

class _RecipePlanningScreenState extends State<RecipePlanningScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            context.pushNamed(Routes.shoppingList);
          },
          child: Icon(Icons.arrow_back),
        ),
        title: const Text('Planning'),
        actions: _getActionList(),
        shadowColor: Colors.black,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.initViewModel,
        builder: (context, child) {
          if (widget.viewModel.initViewModel.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.initViewModel.error) {
            return TextButton(
              onPressed: widget.viewModel.initViewModel.execute,
              child: Text('Retry?'),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            return RecipePlanningBody(viewModel: widget.viewModel);
          },
        ),
      ),
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
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(theme.colorScheme.secondaryContainer),
            ),
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
          onPressed: () => context.pushNamed(Routes.recipeList),
          child: Row(
            children: [
              Icon(Icons.list),
              SizedBox(width: 8),
              Text('Recettes', style: getTextStyle(context)),
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
