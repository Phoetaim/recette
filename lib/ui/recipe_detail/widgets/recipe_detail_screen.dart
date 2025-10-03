import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../view_model/recipe_detail_viewmodel.dart';

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
    widget.viewModel.getRecipeById.execute(widget.recipeId!);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel.getRecipeById,
      builder: (context, child) {
        if (widget.viewModel.getRecipeById.running) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.getRecipeById.error) {
          return TextButton(
            onPressed: () => context.go(Routes.recipeList),
            child: Text('Retry?'),
          );
        }
        return child!;
      },
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          Recipe recipe = widget.viewModel.getRecipe;
          return Scaffold(
            appBar: AppBar(
              leading: TextButton(
                onPressed: () {
                  context.go(Routes.recipeList);
                },
                child: Icon(Icons.arrow_back),
              ),
              title: Text(recipe.name),
              shadowColor: Colors.black,
              scrolledUnderElevation: 4,
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
            body: TextButton(
              onPressed: () => context.go(Routes.recipeList),
              child: Text('GO BACK'),
            ),
          );
        },
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.deleteRecipe.completed) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe deleted'),
          duration: Duration(microseconds: 200),
        ),
      );
    }

    if (widget.viewModel.deleteRecipe.error) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error while loading')));
    }
  }
}
