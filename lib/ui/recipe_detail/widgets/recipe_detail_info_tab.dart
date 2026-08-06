import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/recipe/recipe.dart';
import '../view_model/recipe_detail_viewmodel.dart';
import 'recipe_steps_widget.dart';

class RecipeDetailInfoTab extends StatefulWidget {
  const RecipeDetailInfoTab({
    super.key,
    required this.viewModel,
    required this.recipeNameKey,
    required this.formKey,
  });

  final RecipeDetailViewModel viewModel;
  final GlobalKey<FormFieldState<String>> recipeNameKey;
  final GlobalKey<FormState> formKey;

  @override
  State<RecipeDetailInfoTab> createState() => _RecipeDetailInfoTabState();
}

class _RecipeDetailInfoTabState extends State<RecipeDetailInfoTab> {
  final GlobalKey<FormFieldState<String>> preparationKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> cookingKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<int>> peopleKey = GlobalKey<FormFieldState<int>>();
  final GlobalKey<FormFieldState<String>> stepsKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> linkKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    Recipe recipe = widget.viewModel.recipe.value;
    return Form(
      child: Column(
        mainAxisSize: .min,
        children: [
          Row(
            mainAxisSize: .min,
            children: [
              TextFormField(
                key: preparationKey,
                decoration: InputDecoration(border: InputBorder.none, prefix: Text(' Prep:  ')),
                initialValue: recipe.preparationTime,
              ),
              TextFormField(
                key: cookingKey,
                decoration: InputDecoration(border: InputBorder.none, prefix: Text(' Cuisson:  ')),
                initialValue: recipe.cookingTime,
              ),
              TextFormField(
                key: peopleKey,
                decoration: InputDecoration(border: InputBorder.none, prefix: Text(' Prep:  ')),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                initialValue: '${recipe.nbOfPeople}',
              ),
            ],
          ),
          RecipeStepsWidget(recipe: recipe),
        ],
      ),
    );
  }
}
