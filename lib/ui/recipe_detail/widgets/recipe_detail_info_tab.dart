import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';

import 'recipe_steps_widget.dart';

class RecipeDetailInfoTab extends StatefulWidget {
  const RecipeDetailInfoTab({
    super.key,
    required this.viewModel,
    required this.preparationController,
    required this.cookingController,
    required this.peopleController,
    required this.stepsController,
  });

  final RecipeDetailViewModel viewModel;
  final TextEditingController preparationController;
  final TextEditingController cookingController;
  final TextEditingController peopleController;
  final TextEditingController stepsController;

  @override
  State<RecipeDetailInfoTab> createState() => _RecipeDetailInfoTabState();
}

class _RecipeDetailInfoTabState extends State<RecipeDetailInfoTab> {
  @override
  Widget build(BuildContext context) {
    Recipe recipe = widget.viewModel.recipe.value;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: .min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.preparationController,
                  decoration: InputDecoration(border: InputBorder.none, prefix: Text('Prep:  ')),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.cookingController,
                  decoration: InputDecoration(border: InputBorder.none, prefix: Text('Cuisson:  ')),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.preparationController,
                  decoration: InputDecoration(border: InputBorder.none, prefix: Text('Pers:  ')),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          RecipeStepsWidget(recipe: recipe),
        ],
      ),
    );
  }
}
