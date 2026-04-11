import 'package:flutter/material.dart';

import '../../../domain/models/ingredient/ingredient.dart';
import '../../../domain/models/ingredient/ingredient_types.dart';
import '../view_model/ingredients_utils_viewmodel.dart';

class IngredientTypeWidget extends StatelessWidget {
  const IngredientTypeWidget({super.key, required this.ingredient, required this.viewModel});

  final IngredientsUtilsViewModel viewModel;
  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: PopupMenuButton<IngredientTypes>(
        initialValue: ingredient.type,
        onSelected: (IngredientTypes ingredientType) {
          viewModel.updateIngredient.execute(ingredient.copyWith(type: ingredientType));
        },
        itemBuilder: (BuildContext context) => viewModel.ingredientTypes
            .map((element) => PopupMenuItem(value: element, child: Row(
              children: [
                element.getIcon(),
                SizedBox(width: 8),
                Text(element.name),
              ],
            )))
            .toList(),
        child: ingredient.type.getIcon(),
      ),
    );
  }
}
