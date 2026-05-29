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
      child: GestureDetector(onLongPress: () => _showMenu(context), child: ingredient.type.getIcon())
    );
  }

  void _showMenu(BuildContext context) {
    showMenu(
        context: context,
        items: _buildEntries(),
        position: RelativeRect.fromLTRB(10, 50,50,50),
        initialValue: ingredient.type,
    ).then((
      IngredientTypes? ingredientType,
    ) {
      if (ingredientType != null) {
        viewModel.updateIngredient.execute(ingredient.copyWith(type: ingredientType));
      }
    });
  }

  List<PopupMenuEntry<IngredientTypes>> _buildEntries() {
    return viewModel.ingredientTypes
        .map(
          (element) => PopupMenuItem(
            value: element,
            child: Row(children: [element.getIcon(), SizedBox(width: 8), Text(element.name)]),
          ),
        )
        .toList();
  }
}
