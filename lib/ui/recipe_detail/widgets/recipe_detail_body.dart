import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/recipe/recipe.dart';
import '../../../domain/models/ingredient/ingredient_with_quantity.dart';import '../view_model/recipe_detail_viewmodel.dart';

class RecipeDetailBody extends StatelessWidget {
  const RecipeDetailBody({super.key, required this.viewModel, required this.recipe});

  final RecipeDetailViewModel viewModel;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderRow(recipe: recipe, viewModel: viewModel),
        IngredientsCard(recipe: recipe, viewModel: viewModel),
        StepCard(recipe: recipe),
      ],
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key, required this.recipe, required this.viewModel});

  final Recipe recipe;
  final RecipeDetailViewModel viewModel;

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
                  child: HeaderTextFormField(
                    prefix: Text(' Prep:  '),
                    initialValue: recipe.preparationTime,
                    onSubmitted: (value) => viewModel.updateRecipePreparationTime(value),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: HeaderTextFormField(
                    prefix: Text(' Cuisson:  '),
                    initialValue: recipe.cookingTime,
                    onSubmitted: (value) => viewModel.updateRecipeCookingTime(value),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: HeaderTextFormField(
                    prefix: Text(' Personnes:  '),
                    initialValue: recipe.nbOfPeople.toString(),
                    keyBoardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (value) => viewModel.updateRecipeNbOfPeople(value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HeaderTextFormField extends StatelessWidget {
  const HeaderTextFormField({
    super.key,
    this.prefix,
    required this.initialValue,
    required this.onSubmitted,
    this.keyBoardType,
    this.inputFormatters,
  });
  final Widget? prefix;
  final String initialValue;
  final TextInputType? keyBoardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(border: InputBorder.none, prefix: prefix),
      keyboardType: keyBoardType,
      inputFormatters: inputFormatters,
      initialValue: initialValue,
      onFieldSubmitted: onSubmitted,
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
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return Text('$index: ${recipe.steps[index]}');
            },
          ),
        ),
      ],
    );
  }
}
