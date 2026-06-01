import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';

import '../view_model/recipe_detail_viewmodel.dart';
import 'recipe_detail_info_tab.dart';
import 'recipe_detail_ingredient_tab.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.viewModel, required this.recipeId});

  final RecipeDetailViewModel viewModel;
  final String? recipeId;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.deleteRecipe.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant RecipeDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.deleteRecipe.removeListener(_onResult);
    widget.viewModel.deleteRecipe.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.deleteRecipe.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.viewModel.loadRecipeById.execute(widget.recipeId!);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel.loadRecipeById,
      builder: (context, child) {
        if (widget.viewModel.loadRecipeById.running) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.loadRecipeById.error) {
          return TextButton(
            onPressed: () => context.go(Routes.recipeList),
            child: Text('Return to recipe list?'),
          );
        }
        return child!;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info), text: 'Information'),
                Tab(icon: Icon(Icons.food_bank), text: 'Ingredients'),
              ],
            ),
            actions: [
              ListenableBuilder(
                listenable: widget.viewModel.saveRecipe,
                builder: (context, value) {
                  return ValueListenableBuilder(
                    valueListenable: widget.viewModel.recipe,
                    builder: (context, value, child) {
                      return TextButton(
                        key: Key('SaveButton'),
                        onPressed: !widget.viewModel.isRecipeUpdated()
                            ? null
                            : () {
                                widget.viewModel.saveRecipe.execute();
                              },
                        child: Icon(Icons.save),
                      );
                    },
                  );
                },
              ),
              MenuBar(
                style: MenuStyle(
                  elevation: WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(theme.colorScheme.primaryContainer),
                ),
                children: [
                  SubmenuButton(
                    menuChildren: _getMenuItemButtons(theme.colorScheme.onSecondaryContainer),
                    child: Icon(Icons.more_vert, color: theme.colorScheme.onPrimaryContainer),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStatePropertyAll(theme.colorScheme.secondaryContainer),
                    ),
                  ),
                ],
              ),
            ],

            leading: TextButton(
              onPressed: () {
                context.go(Routes.recipeList);
              },
              child: Icon(Icons.arrow_back),
            ),
            title: ValueListenableBuilder(
              valueListenable: widget.viewModel.recipe,
              builder: (context, value, child) {
                return HeaderTextFormField(
                  fieldKey: Key('RecipeName'),
                  initialValue: widget.viewModel.recipe.value.name,
                  callback: (value) => widget.viewModel.updateRecipeName(value),
                );
              },
            ),
            shadowColor: Colors.black,
            scrolledUnderElevation: 4,
            backgroundColor: theme.colorScheme.primaryContainer,
          ),
          body: TabBarView(
            children: [
              RecipeDetailInfoTab(viewModel: widget.viewModel),
              RecipeDetailIngredientTab(viewModel: widget.viewModel),
            ],
          ),
          floatingActionButton: ValueListenableBuilder(
            valueListenable: widget.viewModel.recipe,
            builder: (context, value, child) {
              return CustomNumberInput(viewModel: widget.viewModel);
            },
          ),
        ),
      ),
    );
  }

  List<MenuItemButton> _getMenuItemButtons(Color color) {
    final textStyle = TextStyle(color: color);
    return <MenuItemButton>[
      MenuItemButton(
        onPressed: null,
        child: Row(
          children: [
            Icon(Icons.share, color: color),
            SizedBox(width: 8),
            Text('Partager', style: textStyle),
          ],
        ),
      ),
      MenuItemButton(
        onPressed: null,
        child: Row(
          children: [
            Icon(Icons.arrow_upward, color: color),
            SizedBox(width: 8),
            Text('Exporter', style: textStyle),
          ],
        ),
      ),
      MenuItemButton(
        onPressed: () {
          widget.viewModel.deleteRecipe.execute(widget.viewModel.recipe.value.id!);
        },
        child: Row(
          children: [
            Icon(Icons.delete, color: color),
            SizedBox(width: 8),
            Text('Supprimer', style: textStyle),
          ],
        ),
      ),
    ];
  }

  void _onResult() {
    if (widget.viewModel.deleteRecipe.completed) {
      context.go(Routes.recipeList);
    }

    if (widget.viewModel.deleteRecipe.error) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while loading')));
    }
  }
}
