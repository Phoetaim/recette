import 'package:flutter/material.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_controllers.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';

import 'recipe_steps_widget.dart';

class RecipeDetailInfoTab extends StatefulWidget {
  const RecipeDetailInfoTab({super.key, required this.viewModel, required this.recipeControllers});

  final RecipeDetailViewModel viewModel;
  final RecipeControllers recipeControllers;

  @override
  State<RecipeDetailInfoTab> createState() => _RecipeDetailInfoTabState();
}

class _RecipeDetailInfoTabState extends State<RecipeDetailInfoTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const .directional(start: 30),
            child: Row(
              mainAxisSize: .min,
              mainAxisAlignment: .spaceEvenly,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.recipeControllers.preparationController,
                    decoration: InputDecoration(border: InputBorder.none, prefix: Text('Prep:  ')),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: widget.recipeControllers.cookingController,
                    decoration: InputDecoration(border: InputBorder.none, prefix: Text('Cuisson:  ')),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: widget.recipeControllers.peopleController,
                    decoration: InputDecoration(border: InputBorder.none, prefix: Text('Pers:  ')),
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null) {
                        return 'Entrez un nombre de personnes';
                      }
                      try {
                        int.parse(value);
                      } on FormatException {
                        return 'Entrez un nombre de personnes';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          RecipeStepsWidget(recipeControllers: widget.recipeControllers),
        ],
      ),
    );
  }
}
