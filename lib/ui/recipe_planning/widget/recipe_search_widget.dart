import 'package:flutter/material.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_view_model.dart';

class RecipeSearchWidget extends StatelessWidget {
  const RecipeSearchWidget({super.key, required this.viewModel, required this.controller, required this.callbackForRecipe});

  final RecipePlanningViewModel viewModel;
  final SearchController controller;
  final void Function(int id) callbackForRecipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor.bar(

        barShape: WidgetStatePropertyAll(BeveledRectangleBorder()),
        searchController: controller,
        barElevation: WidgetStatePropertyAll(0),
        barLeading: null,
        barHintText: 'Chakchouka,...',
        shrinkWrap: true,
        isFullScreen: false,
        suggestionsBuilder: _generateSuggestions,
      ),
    );
  }

  List<ListTile> _generateSuggestions(BuildContext context, SearchController controller) {
    List<RawRecipe> filteredRecipes = viewModel.filterIngredients(controller.text.toLowerCase());

    return List<ListTile>.generate(filteredRecipes.length, (int index) {
      return ListTile(
        title: Row(
          children: [
            SizedBox(width: 8),
            Expanded(child: Text(filteredRecipes[index].name)),
          ],
        ),
        onTap: () {
          callbackForRecipe(filteredRecipes[index].id!);
          controller.closeView(filteredRecipes[index].name);
        },
      );
    });
  }
}
