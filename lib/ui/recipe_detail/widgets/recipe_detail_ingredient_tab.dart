import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/ui/ingredients_utils/view_model/ingredients_utils_viewmodel.dart';
import 'package:recette/ui/ingredients_utils/widgets/ingredient_search_widget.dart';
import 'package:recette/ui/ingredients_utils/widgets/quantity_tile.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_controllers.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';

class RecipeDetailIngredientTab extends StatefulWidget {
  const RecipeDetailIngredientTab({
    super.key,
    required this.viewModel,
    required this.recipeControllers,
  });

  final RecipeDetailViewModel viewModel;
  final RecipeControllers recipeControllers;

  @override
  State<RecipeDetailIngredientTab> createState() => _RecipeDetailIngredientTabState();
}

class _RecipeDetailIngredientTabState extends State<RecipeDetailIngredientTab> {
  int tmpIngredientId = -1;

  @override
  Widget build(BuildContext context) {
    return FormField<List<IngredientWithQuantity>>(
      key: widget.recipeControllers.ingredientsKey,
      initialValue: widget.viewModel.recipe.value.ingredients,
      builder: (FormFieldState<List<IngredientWithQuantity>> state) {
        return Column(
          children: [
            IngredientSearch(
              viewModel: IngredientsUtilsViewModel(
                ingredientRepository: context.read(),
                ingredientUnitsRepository: context.read(),
              ),
              callbackForIngredient: (IngredientWithQuantity ingredient) {
                final List<IngredientWithQuantity> updatedIngredients = List.from(
                  widget.recipeControllers.recipeIngredients,
                );
                updatedIngredients.add(ingredient.copyWith(id:tmpIngredientId--));
                state.didChange(updatedIngredients);
                widget.recipeControllers.computeIfRecipeIsUpdated();
              },
            ),
            IngredientsCard(
              viewModel: widget.viewModel,
              recipeControllers: widget.recipeControllers,
              state: state,
            ),
          ],
        );
      },
    );
  }
}

class IngredientsCard extends StatelessWidget {
  const IngredientsCard({
    super.key,
    required this.viewModel,
    required this.recipeControllers,
    required this.state,
  });

  final RecipeDetailViewModel viewModel;
  final RecipeControllers recipeControllers;
  final FormFieldState<List<IngredientWithQuantity>> state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ValueListenableBuilder(
        valueListenable: viewModel.currentNumberOfPeople,
        builder: (context, value, child) {
          return ValueListenableBuilder(
            valueListenable: recipeControllers.isRecipeUpdated,
            builder: (context, value, child) {
              return ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: recipeControllers.recipeIngredients.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  return IngredientCard(
                    viewModel: viewModel,
                    recipeControllers: recipeControllers,
                    state: state,
                    ingredientWithQuantity: recipeControllers.recipeIngredients[index],
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
  const IngredientCard({
    super.key,
    required this.viewModel,
    required this.recipeControllers,
    required this.state,
    required this.ingredientWithQuantity,
  });

  final RecipeDetailViewModel viewModel;
  final RecipeControllers recipeControllers;
  final FormFieldState<List<IngredientWithQuantity>> state;
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
        List<IngredientWithQuantity> ingredients = List.from(recipeControllers.recipeIngredients);
        ingredients.remove(ingredientWithQuantity);
        state.didChange(ingredients);
        recipeControllers.computeIfRecipeIsUpdated();
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
