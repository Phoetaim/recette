import 'package:flutter/material.dart';
import 'package:recette/data/services/models/raw_ingredient_with_quantity.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import '../view_model/ingredient_search_viewmodel.dart';

class IngredientSearch extends StatelessWidget {
  const IngredientSearch({super.key, required this.viewModel, required this.callbackForIngredient});

  final IngredientSearchViewModel viewModel;
  final void Function(IngredientWithQuantity) callbackForIngredient;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.loadIngredients,
      builder: (context, value) {
        if (viewModel.loadIngredients.running) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.loadIngredients.error) {
          return Text('RIP');
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor.bar(
            barHintText: '3kg de patates, 2 navets,...',
            shrinkWrap: true,
            isFullScreen: false,
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              IngredientSearchResult searchResult = viewModel.filterIngredients(
                controller.text.toLowerCase(),
              );
              String unit = searchResult.unit == IngredientUnit.unit ? '': searchResult.unit.name;
              Widget quantityWidget = Text('${searchResult.quantity} $unit');
              return List<ListTile>.generate(searchResult.filteredIngredients.length, (int index) {
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(searchResult.filteredIngredients[index].name)),
                      quantityWidget,
                    ],
                  ),
                  onTap: () {
                    IngredientWithQuantity ingredientWithQuantity = IngredientWithQuantity(
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
            },
          ),
        );
      },
    );
  }
}
