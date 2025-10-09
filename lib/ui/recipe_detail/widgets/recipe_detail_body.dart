import 'package:flutter/material.dart';
import '../../../domain/recipe/recipe.dart';
import '../../../domain/ingredient/ingredient_with_quantity.dart';
import '../view_model/recipe_detail_viewmodel.dart';

class RecipeDetailBody extends StatelessWidget {
  const RecipeDetailBody({
    super.key,
    required this.viewModel,
    required this.recipe,
  });

  final RecipeDetailViewModel viewModel;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderRow(recipe: recipe),
        IngredientsCard(recipe: recipe, viewModel: viewModel),
        StepCard(recipe: recipe),
      ],
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4),
        Card(
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text('Préparation: ${recipe.preparationTime}'),
                ),
              ),
              Expanded(
                child: Center(child: Text('Cuisson: ${recipe.cookingTime}')),
              ),
              Expanded(
                child: Center(child: Text('Personnes: ${recipe.nbOfPeople}')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IngredientsCard extends StatelessWidget {
  const IngredientsCard({
    super.key,
    required this.recipe,
    required this.viewModel,
  });

  final Recipe recipe;
  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4),
        Row(
          children: [
            Text('Ingredients:'),
            TextButton(
              onPressed: () {
                print('modify Ingredients');
              },
              child: Icon(Icons.edit),
            ),
          ],
        ),
        SizedBox(height: 4),

        Card(
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: recipe.ingredients.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (BuildContext context, int index) {
              IngredientWithQuantity ingredient =
                  viewModel.getRecipe.ingredients[index];
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      viewModel.getIngredientName(ingredient.ingredientId),
                    ),
                  ),
                  Text(
                    '${ingredient.quantity.toString()} ${ingredient.unit.name}',
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class StepCard extends StatelessWidget {
  const StepCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4),
        Row(
          children: [
            Text('Etapes:'),
            TextButton(
              onPressed: () {
                print('modify steps');
              },
              child: Icon(Icons.edit),
            ),
          ],
        ),
        SizedBox(height: 4),
        Card(
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: recipe.steps.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return Text('$index: ${recipe.steps[index]}');
            },
          ),
        ),
      ],
    );
  }
}
