import 'package:flutter/material.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_view_model.dart';

import 'planning_slivers.dart';
import 'recipe_planning_form.dart';

class RecipePlanningBody extends StatelessWidget {
  const RecipePlanningBody({super.key, required this.viewModel});

  final RecipePlanningViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.initViewModel,
      builder: (context, value) {
        if (viewModel.initViewModel.running) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.initViewModel.error) {
          return Text('Failed to load recipe list');
        }
        return Column(
          children: [
            RecipePlanningForm(viewModel: viewModel,),
            Expanded(
              child: CustomScrollView(slivers: [RecipePlanningSlivers(viewModel: viewModel)]),
            ),
          ],
        );
      },
    );
  }
}
