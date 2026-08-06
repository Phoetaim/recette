import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/ingredient/ingredient_with_quantity.dart';
import '../../ingredients_utils/view_model/ingredients_utils_viewmodel.dart';
import '../../ingredients_utils/widgets/ingredient_search_widget.dart';
import '../../ingredients_utils/widgets/quantity_tile.dart';
import '../view_model/recipe_detail_viewmodel.dart';

class RecipeDetailIngredientTab extends StatelessWidget {
  const RecipeDetailIngredientTab({super.key, required this.viewModel});

  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IngredientSearch(
          viewModel: IngredientsUtilsViewModel(ingredientRepository: context.read(), ingredientUnitsRepository: context.read()),
          callbackForIngredient: viewModel.addIngredientWithQuantity,
        ),
        IngredientsCard(viewModel: viewModel),
      ],
    );
  }
}

class IngredientsCard extends StatelessWidget {
  const IngredientsCard({super.key, required this.viewModel});

  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ValueListenableBuilder(
        valueListenable: viewModel.currentNumberOfPeople,
        builder: (context, value, child) {
          return ValueListenableBuilder(
            valueListenable: viewModel.recipe,
            builder: (context, value, child) {
              return ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: viewModel.recipe.value.ingredients.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  return IngredientCard(
                    viewModel: viewModel,
                    ingredientWithQuantity: viewModel.recipe.value.ingredients[index],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class IngredientCard extends StatelessWidget {
  const IngredientCard({super.key, required this.viewModel, required this.ingredientWithQuantity});
  final RecipeDetailViewModel viewModel;
  final IngredientWithQuantity ingredientWithQuantity;
  @override
  Widget build(BuildContext context) {
    double quantity =
        viewModel.currentNumberOfPeople.value *
        ingredientWithQuantity.quantity /
        viewModel.recipe.value.nbOfPeople;
    return Dismissible(
      key: Key(ingredientWithQuantity.id.toString()),
      onDismissed: (direction) {
        viewModel.removeIngredientWithQuantity(ingredientWithQuantity);
      },
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(ingredientWithQuantity.ingredient.name),
              ),
            ),
            QuantityTile(
              ingredientWithQuantity: ingredientWithQuantity.copyWith(quantity: quantity.toInt()),
            ),
          ],
        ),
      ),
    );
  }
}
