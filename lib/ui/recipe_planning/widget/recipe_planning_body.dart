import 'package:flutter/material.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_viewmodel.dart';

import 'recipe_planning_card.dart';
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
            RecipePlanningForm(viewModel: viewModel),
            Expanded(
              child: ListView.builder(
                padding: .only(bottom: 70),
                scrollDirection: .vertical,
                itemCount: viewModel.plannings.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: RecipePlanningCard(viewModel: viewModel, planning: viewModel.plannings[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
