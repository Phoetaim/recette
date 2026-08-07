import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_controllers.dart';

import '../../ui_utils/import_alert_box.dart';
import '../view_model/recipe_detail_viewmodel.dart';
import 'add_recipe_to_shopping_list.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RecipeControllers recipeControllers = RecipeControllers();

  @override
  void initState() {
    super.initState();
    widget.viewModel.deleteRecipe.addListener(_onResult);
    widget.viewModel.loadRecipeById.execute(widget.recipeId!);
    recipeControllers.initControllers();
  }

  @override
  void didUpdateWidget(covariant RecipeDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.deleteRecipe.removeListener(_onResult);
    widget.viewModel.deleteRecipe.addListener(_onResult);

    // If recipe ID changed, reset initialization flag
    if (oldWidget.recipeId != widget.recipeId) {
      recipeControllers.resetInitialization();
    }
  }

  @override
  void dispose() {
    widget.viewModel.deleteRecipe.removeListener(_onResult);
    recipeControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel.loadRecipeById,
      builder: (context, child) {
        if (widget.viewModel.loadRecipeById.running) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.loadRecipeById.error) {
          return TextButton(
            onPressed: () => context.goNamed(Routes.recipeList),
            child: Text('Return to recipe list?'),
          );
        }
        if (mounted) {
          recipeControllers.initControllerValues(widget.viewModel.recipe.value);
        }
        return child!;
      },
      child: DefaultTabController(
        length: 2,
        child: Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.info), text: 'Information'),
                  Tab(icon: Icon(Icons.food_bank), text: 'Ingredients'),
                ],
              ),
              actions: _getAction(),

              leading: TextButton(
                onPressed: () {
                  context.pushNamed(Routes.recipePlanning);
                },
                child: Icon(Icons.home),
              ),
              title: ValueListenableBuilder(
                valueListenable: widget.viewModel.recipe,
                builder: (context, value, child) {
                  return TextFormField(controller: recipeControllers.recipeNameController);
                },
              ),
              shadowColor: Colors.black,
              scrolledUnderElevation: 4,
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
            body: TabBarView(
              children: [
                RecipeDetailInfoTab(
                  viewModel: widget.viewModel,
                  recipeControllers: recipeControllers,
                ),
                RecipeDetailIngredientTab(viewModel: widget.viewModel, recipeControllers: recipeControllers),
              ],
            ),
            floatingActionButton: ValueListenableBuilder(
              valueListenable: widget.viewModel.recipe,
              builder: (context, value, child) {
                return CustomNumberInput(viewModel: widget.viewModel, callback: _addToShoppingList);
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getAction(){
    final theme = Theme.of(context);
    return [
      ListenableBuilder(
        listenable: widget.viewModel.saveRecipe,
        builder: (context, value) {
          return ValueListenableBuilder(
            valueListenable: recipeControllers.isRecipeUpdated,
            builder: (context, value, child) {
              return TextButton(
                key: ValueKey('SaveButton'),
                onPressed: recipeControllers.isRecipeUpdated.value ? _saveForm : null,
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
            menuChildren: _getMenuItemButtons(theme.colorScheme),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(
                theme.colorScheme.secondaryContainer,
              ),
            ),
            child: Icon(Icons.more_vert, color: theme.colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    ];
  }

  List<MenuItemButton> _getMenuItemButtons(ColorScheme colorScheme) {
    final color = colorScheme.onSecondaryContainer;
    final textStyle = TextStyle(color: color);
    return <MenuItemButton>[
      MenuItemButton(
        onPressed: null,
        child: Row(children: [Icon(Icons.share), SizedBox(width: 8), Text('Partager')]),
      ),
      MenuItemButton(
        onPressed: () {
          _saveForm();
          widget.viewModel.exportRecipe();
        },
        child: Row(
          children: [
            Icon(exportIcon, color: color),
            SizedBox(width: 8),
            Text('Exporter', style: textStyle),
          ],
        ),
      ),
      MenuItemButton(
        onPressed: widget.viewModel.deleteRecipe.execute,
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

  void _addToShoppingList() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Recipe recipe = recipeControllers.buildRecipeFromForm();
    widget.viewModel.addToShoppingList.execute(recipe);
    recipeControllers.setOriginalRecipe(widget.viewModel.recipe.value);
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Recipe recipe = recipeControllers.buildRecipeFromForm();
    await widget.viewModel.saveRecipe.execute(recipe);
    recipeControllers.setOriginalRecipe(widget.viewModel.recipe.value);

  }

  void _onResult() {
    if (!mounted) return;

    if (widget.viewModel.deleteRecipe.completed) {
      context.pop();
    }

    if (widget.viewModel.deleteRecipe.error) {
      widget.viewModel.deleteRecipe.clearResult();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error while deleting recipe')));
      }
    }
  }
}
