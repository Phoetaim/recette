import 'package:flutter/material.dart';
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
              return List<ListTile>.generate(searchResult.filteredIngredients.length, (int index) {
                return ListTile(
                  title: Text(searchResult.filteredIngredients[index].name),
                  onTap: () {
                    IngredientWithQuantity ingredientWithQuantity = IngredientWithQuantity(
                      ingredient: searchResult.filteredIngredients[index],
                      quantity: searchResult.quantity,
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
