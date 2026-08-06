import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/routing/routes.dart';

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
  late final TextEditingController recipeNameController;
  late final TextEditingController preparationController;
  late final TextEditingController cookingController;
  late final TextEditingController peopleController;
  late final TextEditingController stepsController;

  @override
  void initState() {
    super.initState();
    widget.viewModel.deleteRecipe.addListener(_onResult);
    widget.viewModel.loadRecipeById.execute(widget.recipeId!);
    recipeNameController = TextEditingController();
    preparationController = TextEditingController();
    cookingController = TextEditingController();
    peopleController = TextEditingController();
    stepsController = TextEditingController();
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
    recipeNameController.dispose();
    preparationController.dispose();
    cookingController.dispose();
    peopleController.dispose();
    stepsController.dispose();
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
        _initControllerValues();
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
              actions: [
                ListenableBuilder(
                  listenable: widget.viewModel.saveRecipe,
                  builder: (context, value) {
                    return ValueListenableBuilder(
                      valueListenable: widget.viewModel.recipe,
                      builder: (context, value, child) {
                        return TextButton(
                          key: ValueKey('SaveButton'),
                          onPressed: !_isRecipeUpdated() ? null : _saveForm,
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
              ],

              leading: TextButton(
                onPressed: () {
                  context.pushNamed(Routes.recipePlanning);
                },
                child: Icon(Icons.home),
              ),
              title: ValueListenableBuilder(
                valueListenable: widget.viewModel.recipe,
                builder: (context, value, child) {
                  return TextFormField(controller: recipeNameController);
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
                  preparationController: preparationController,
                  cookingController: cookingController,
                  peopleController: preparationController,
                  stepsController: stepsController,
                ),
                RecipeDetailIngredientTab(viewModel: widget.viewModel),
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

  void _initControllerValues() {
    Recipe recipe = widget.viewModel.recipe.value;
    recipeNameController.text = recipe.name;
    preparationController.text = recipe.preparationTime;
    cookingController.text = recipe.cookingTime;
    peopleController.text = '${recipe.nbOfPeople}';
    stepsController.text = recipe.steps.join('\n');
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

  bool _isRecipeUpdated() {
    final rawRecipe = _buildRawRecipeFromForm();
    return rawRecipe != widget.viewModel.originalRecipe ||
        rawRecipe.ingredientWithQuantityIds.length != widget.viewModel.recipe.value.ingredients.length;
  }

  void _addToShoppingList() {
    _saveForm();
    widget.viewModel.addToShoppingList.execute();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    RawRecipe rawRecipe = _buildRawRecipeFromForm();

    await widget.viewModel.saveRecipe.execute(rawRecipe);
  }

  RawRecipe _buildRawRecipeFromForm() {
    return RawRecipe(
      id: widget.viewModel.recipe.value.id,
      name: recipeNameController.text,
      preparationTime: preparationController.text,
      cookingTime: cookingController.text,
      nbOfPeople: int.parse(peopleController.text),
      steps: stepsController.text,
    );
  }

  void _onResult() {
    if (widget.viewModel.deleteRecipe.completed) {
      context.pop();
    }

    if (widget.viewModel.deleteRecipe.error) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while loading')));
    }
  }
}
