import 'package:flutter/material.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_controllers.dart';

class RecipeStepsWidget extends StatelessWidget {
  const RecipeStepsWidget({super.key, required this.recipeControllers});

  final RecipeControllers recipeControllers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(height: 4),
        Padding(
          padding: const .directional(start: 16.0),
          child: Align(
            alignment: .centerLeft,
            child: Text(
              'Etapes:',
              style: TextStyle(fontSize: 15, color: theme.colorScheme.onTertiaryContainer),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const .symmetric(horizontal: 8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onChanged: (String value) {},
                  maxLines: recipeControllers.isEditing.value
                      ? 50
                      : recipeControllers.stepsController.text.split('\n').toList().length,
                  decoration: InputDecoration(border: InputBorder.none),
                  readOnly: !recipeControllers.isEditing.value,
                  controller: recipeControllers.stepsController,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
