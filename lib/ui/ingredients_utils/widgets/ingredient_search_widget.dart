import 'package:flutter/material.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import '../view_model/ingredients_utils_viewmodel.dart';
import 'ingredient_type_widget.dart';

class IngredientSearch extends StatelessWidget {
  const IngredientSearch({
    super.key,
    required this.viewModel,
    required this.callbackForIngredient,
  });

  final IngredientsUtilsViewModel viewModel;
  final void Function(IngredientWithQuantity) callbackForIngredient;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.loadIngredients,
      builder: (context, value) {
        SearchController searchController = SearchController();
        if (viewModel.loadIngredients.running) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.loadIngredients.error) {
          return Text('RIP');
        }
        return ListenableBuilder(
          listenable: viewModel.updateIngredient,
          builder: (context, value) {
            SearchAnchor searchAnchor = SearchAnchor.bar(
              searchController: searchController,
              barHintText: '3kg de patates, 2 navets,...',
              shrinkWrap: true,
              isFullScreen: false,
              suggestionsBuilder: _generateSuggestions,
            );
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: searchAnchor,
            );
          },
        );
      },
    );
  }

  List<ListTile> _generateSuggestions(
    BuildContext context,
    SearchController controller,
  ) {
    IngredientSearchResult searchResult = viewModel.handleSearch(
      controller.text.toLowerCase(),
    );
    String unit = searchResult.unit.id == defaultIngredientUnit.id
        ? ''
        : searchResult.unit.name;
    Widget quantityWidget = Text('${searchResult.quantity} $unit');

    return List<ListTile>.generate(searchResult.filteredIngredients.length, (
      int index,
    ) {
      return ListTile(
        title: Row(
          children: [
            ListenableBuilder(
              listenable: viewModel.updateIngredient,
              builder: (context, value) {
                return IngredientTypeWidget(
                  ingredient: searchResult.filteredIngredients[index],
                  viewModel: viewModel,
                );
              },
            ),
            SizedBox(width: 8),
            Expanded(child: Text(searchResult.filteredIngredients[index].name)),
            quantityWidget,
          ],
        ),
        onTap: () {
          IngredientWithQuantity ingredientWithQuantity =
              IngredientWithQuantity(
                ingredient: searchResult.filteredIngredients[index],
                quantity: searchResult.quantity,
                unit: searchResult.unit,
              );
          callbackForIngredient(ingredientWithQuantity);
          controller.clear();
          controller.closeView(null);
        },
      );
    });
  }
}
