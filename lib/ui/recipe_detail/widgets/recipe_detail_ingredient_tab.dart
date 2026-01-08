import 'package:flutter/material.dart';
import '../../../domain/models/recipe/recipe.dart';
import '../../../domain/models/ingredient/ingredient_with_quantity.dart';import '../view_model/recipe_detail_viewmodel.dart';

class RecipeDetailIngredientTab extends StatelessWidget {
  const RecipeDetailIngredientTab({super.key, required this.viewModel, required this.recipe});

  final RecipeDetailViewModel viewModel;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IngredientsCard(recipe: recipe, viewModel: viewModel),
      ],
    );
  }
}


class IngredientsCard extends StatelessWidget {
  const IngredientsCard({super.key, required this.recipe, required this.viewModel});

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
              child: Icon(Icons.add_box),
            ),
          ],
        ),
        SizedBox(height: 4),

        Card(
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: recipe.ingredients.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              IngredientWithQuantity ingredientWithQuantity = viewModel.getRecipe.ingredients[index];
              return Row(
                children: [
                  Expanded(child: Text(ingredientWithQuantity.ingredient.name)),
                  Text('${ingredientWithQuantity.quantity.toString()} ${ingredientWithQuantity.unit.name}'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
