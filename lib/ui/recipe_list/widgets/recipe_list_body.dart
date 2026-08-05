import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';

import 'recipe_card.dart';

class RecipeListBody extends StatelessWidget {
  const RecipeListBody({super.key, required this.viewModel});

  final RecipeListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [RecipeSlivers(viewModel: viewModel, rawRecipes: viewModel.recipes)],
          ),
        ),
      ],
    );
  }
}

class RecipeSlivers extends StatelessWidget {
  const RecipeSlivers({super.key, required this.viewModel, required this.rawRecipes});

  final RecipeListViewModel viewModel;
  final List<RawRecipe> rawRecipes;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: rawRecipes.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            RecipeFullCard(viewModel: viewModel, rawRecipe: viewModel.getRecipeByIndex(index)),
            Divider(),
          ],
        );
      },
    );
  }
}

class RecipeFullCard extends StatelessWidget {
  const RecipeFullCard({super.key, required this.viewModel, required this.rawRecipe});

  final RecipeListViewModel viewModel;
  final RawRecipe rawRecipe;

  @override
  Widget build(BuildContext context) {
    Widget childWidget = Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              context.pushNamed(
                Routes.recipeDetail,
                pathParameters: {'recipeId': rawRecipe.id.toString()},
              );
            },
            onLongPress: () => viewModel.enterSelection(rawRecipe.id!),
            child: RecipeCard(key: Key('recipe${rawRecipe.id!}'), recipe: rawRecipe),
          ),
        ),
        TextButton(
          onPressed: () {
            viewModel.deleteRecipe.execute(rawRecipe.id!);
          },
          child: Icon(Icons.delete),
        ),
      ],
    );

    return ValueListenableBuilder(
      valueListenable: viewModel.isSelecting,
      builder: (context, value, child) {
        if (viewModel.isSelecting.value) {
          return ListenableBuilder(
            listenable: viewModel,
            builder: (context, value) {
              return CheckboxListTile(
                value: viewModel.selectedRecipes.contains(rawRecipe.id),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) => viewModel.updateSelection(rawRecipe.id!),
                title: child,
              );
            },
          );
        } else {
          return child!;
        }
      },
      child: childWidget,
    );
  }
}
