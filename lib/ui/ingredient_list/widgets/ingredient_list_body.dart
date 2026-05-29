import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/ingredient/ingredient.dart';
import '../../ingredients_utils/view_model/ingredients_utils_viewmodel.dart';
import '../../ingredients_utils/widgets/ingredient_type_widget.dart';
import '../view_model/ingredient_list_viewmodel.dart';

class IngredientListBody extends StatelessWidget {
  const IngredientListBody({super.key, required this.viewModel});

  final IngredientListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel.setFilteredIngredients('');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchBar(
            leading: Icon(Icons.search),
            hintText: 'carottes, navet,...',
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            onChanged: (value) => viewModel.setFilteredIngredients(value),
          ),
        ),
        SizedBox(height: 10),
        ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            return Expanded(
              child: CustomScrollView(
                slivers: [
                  IngredientListSlivers(
                    viewModel: viewModel,
                    ingredients: viewModel.filteredIngredients,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class IngredientListSlivers extends StatelessWidget {
  const IngredientListSlivers({super.key, required this.viewModel, required this.ingredients});

  final IngredientListViewModel viewModel;
  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: ingredients.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: IngredientCard(viewModel: viewModel, ingredient: ingredients[index]),
        );
      },
    );
  }
}

class IngredientCard extends StatelessWidget {
  const IngredientCard({super.key, required this.viewModel, required this.ingredient});

  final IngredientListViewModel viewModel;
  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(ingredient.id!.toString()),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red, child: Icon(Icons.delete)),
      onDismissed: (direction) {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(
              'Voulez-vous vraiment supprimer l\'ingrédient ${ingredient.name} ? Il sera également supprimé des recettes et différentes listes',
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  viewModel.deleteIngredient.execute(ingredient);
                  Navigator.of(context, rootNavigator: true).pop();
                  },
                child: const Icon(Icons.check),
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
          IngredientTypeWidget(
            ingredient: ingredient,
            viewModel: IngredientsUtilsViewModel(ingredientRepository: context.read()),
          ),
          SizedBox(width: 8),
          Text(ingredient.name),
        ],
      ),
    );
  }
}
