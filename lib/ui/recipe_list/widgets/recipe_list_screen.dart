import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
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
            widget.viewModel.resetRecipes();
          },
          child: Icon(Icons.home),
        ),
        title: const Text('Mes Recettes'),
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
            return TextButton(onPressed: widget.viewModel.loadRecipes.execute, child: Text('Retry?'));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(Routes.recipeDetail, pathParameters: {'recipeId': (-1).toString()});
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.deleteRecipe.completed) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recette supprimée'), duration: Duration(microseconds: 500)));
    }

    if (widget.viewModel.deleteRecipe.error) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while loading')));
    }
  }
}
