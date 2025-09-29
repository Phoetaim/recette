import 'package:flutter/material.dart';
import '../../../data/repositories/recipe/recipe_repository.dart';
import '../view_model/recipe_list_viewmodel.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key, required this.viewModel});

  final RecipeListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            viewModel.resetRecipes();
          },
          child: Icon(Icons.home),
        ),
        title: const Text('Mes Recettes'),
        shadowColor: Colors.black,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          print('hello');
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: viewModel.recipeCount(),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('add');
          viewModel.addRecipe(Recipe(viewModel.id));
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RecipeFullCard extends StatelessWidget {
  const RecipeFullCard({
    super.key,
    required this.viewModel,
    required this.index,
  });

  final RecipeListViewModel viewModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    Recipe recipe = viewModel.getRecipeByIndex(index);
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              print('view Recipe ${recipe.id}');
            },
            child: RecipeCard(recipe: recipe),
          ),
        ),
        TextButton(
          onPressed: () {
            viewModel.deleteRecipe(recipe);
          },
          child: Icon(Icons.delete),
        ),
      ],
    );
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            SizedBox(width: 5),
            Text(recipe.id.toString()),
            Expanded(child: Center(child: Text(recipe.name))),
            IconRow(icon: Icons.group, label: recipe.nbOfPeople.toString()),
            SizedBox(width: 20),
            Row(
              children: [
                Column(
                  children: [
                    IconRow(
                      icon: Icons.timer_outlined,
                      label: recipe.preparationTime,
                    ),
                    IconRow(icon: Icons.thermostat, label: recipe.cookingTime),
                  ],
                ),
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
