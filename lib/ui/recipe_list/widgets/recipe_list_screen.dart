import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';

import '../../ui_utils/import_alert_box.dart';
import '../view_model/recipe_list_viewmodel.dart';
import 'recipe_list_body.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key, required this.viewModel});

  final RecipeListViewModel viewModel;

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.deleteRecipe.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant RecipeListScreen oldWidget) {
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            context.go(Routes.recipePlanning);
          },
          child: Icon(Icons.arrow_back),
        ),
        title: const Text('Mes Recettes'),
        actions: _getActionList(),
        shadowColor: Colors.black,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.loadRecipes,
        builder: (context, child) {
          if (widget.viewModel.loadRecipes.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.loadRecipes.error) {
            return TextButton(
              onPressed: widget.viewModel.loadRecipes.execute,
              child: Text('Retry?'),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            return RecipeListBody(viewModel: widget.viewModel);
          },
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: widget.viewModel.isSelecting,
        builder: (context, value, child) {
          return widget.viewModel.isSelecting.value
              ? SelectionFloatingActionButton(viewModel: widget.viewModel)
              : FloatingActionButton(
                  onPressed: () {
                    context.goNamed(
                      Routes.recipeDetail,
                      pathParameters: {'recipeId': (-1).toString()},
                    );
                  },
                  shape: CircleBorder(),
                  child: const Icon(Icons.add),
                );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _onResult() {
    if (widget.viewModel.deleteRecipe.completed) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recette supprimée'), duration: Duration(milliseconds: 500)),
      );
    }

    if (widget.viewModel.deleteRecipe.error) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while loading')));
    }
  }

  List<Widget> _getActionList() {
    return [ImportButton(callback: widget.viewModel.importRecipes)];
  }
}

class ExportButton extends StatelessWidget {
  const ExportButton({super.key, required this.viewModel});

  final RecipeListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () => viewModel.exportRecipes.execute(), child: Icon(exportIcon));
  }
}

class SelectionFloatingActionButton extends StatelessWidget {
  const SelectionFloatingActionButton({super.key, required this.viewModel});

  final RecipeListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, value) {
        return Stack(
          children: [
            if (viewModel.selectedRecipes.isNotEmpty)
              SmallActionButton(
                title: 'Exporter',
                icon: exportIcon,
                onPressed: viewModel.selectedRecipes.isNotEmpty
                    ? viewModel.exportRecipes.execute
                    : null,
                index: 2,
              ),
            SmallActionButton(
              title: 'Désélectionne tout',
              icon: Icons.check_box_outline_blank,
              onPressed: viewModel.clearSelection,
              index: 1,
            ),
            SmallActionButton(
              title: 'Sélectionne tout',
              icon: Icons.check_box_outlined,
              onPressed: viewModel.toggleSelectionAll,
              index: 0,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                onPressed: viewModel.quitSelection,
                shape: CircleBorder(),
                child: const Icon(Icons.clear),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SmallActionButton extends StatelessWidget {
  const SmallActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.index,
  });

  final String title;
  final IconData icon;
  final Function? onPressed;
  final double index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: 65 + 55 * index,
      right: 5,
      child: Row(
        children: [
          TextButton(
            onPressed: onPressed != null ? () => onPressed!() : null,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title, style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
              ),
            ),
          ),
          FloatingActionButton.small(
            elevation: 2,
            onPressed: onPressed != null ? () => onPressed!() : null,
            shape: CircleBorder(),
            child: Icon(icon),
          ),
        ],
      ),
    );
  }
}
