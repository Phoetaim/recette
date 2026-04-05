import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
import '../../../data/services/models/raw_recipe.dart';
import '../view_model/recipe_list_viewmodel.dart';

class RecipeListBody extends StatelessWidget {
  const RecipeListBody({super.key, required this.viewModel});

  final RecipeListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: viewModel.recipes.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  RecipeFullCard(viewModel: viewModel, index: index),
                  Divider(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecipeFullCard extends StatelessWidget {
  const RecipeFullCard({super.key, required this.viewModel, required this.index});

  final RecipeListViewModel viewModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    RawRecipe rawRecipe = viewModel.getRecipeByIndex(index);
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              context.goNamed(Routes.recipeDetail, pathParameters: {'recipeId': rawRecipe.id.toString()});
            },
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
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final RawRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 5),
        Expanded(child: Text(recipe.name)),
        IconRow(icon: Icons.group, label: recipe.nbOfPeople.toString()),
        SizedBox(width: 20),
        Row(
          children: [
            Column(
              children: [
                IconRow(icon: Icons.timer_outlined, label: recipe.preparationTime),
                IconRow(icon: Icons.thermostat, label: recipe.cookingTime),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class IconRow extends StatelessWidget {
  const IconRow({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon), SizedBox(width: 3), Text(label)]);
  }
}
