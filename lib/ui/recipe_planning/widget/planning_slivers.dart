import 'package:flutter/material.dart';
import 'package:recette/domain/models/recipe/recipe_planning.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_viewmodel.dart';

class RecipePlanningSlivers extends StatelessWidget {
  const RecipePlanningSlivers({super.key, required this.viewModel});

  final RecipePlanningViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: viewModel.plannings.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: PlanningCard(viewModel: viewModel, planning: viewModel.plannings[index]),
        );
      },
    );
  }
}

class PlanningCard extends StatelessWidget {
  const PlanningCard({super.key, required this.viewModel, required this.planning});

  final RecipePlanningViewModel viewModel;
  final RecipePlanning planning;

  @override
  Widget build(BuildContext context) {
    String recipeName = '';
    if (planning.recipeId != null) {
      recipeName = viewModel.getRecipe(planning.recipeId!).name;
    } else if (planning.textRecipe != null) {
      recipeName = planning.textRecipe!;
    }
    return Dismissible(
      key: Key(planning.id!.toString()),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red, child: Icon(Icons.delete)),
      onDismissed: (direction) => viewModel.deleteRecipePlanning.execute(planning.id!),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: planning.progress == RecipePlanningProgress.completed,
        onChanged: (bool? value) {
          viewModel.toggleRecipePlanningStatus(planning);
        },
        title: Text(recipeName),

        secondary: PlanningQuantityTile(viewModel: viewModel, planning: planning),
      ),
    );
  }
}

class PlanningQuantityTile extends StatelessWidget {
  const PlanningQuantityTile({super.key, required this.viewModel, required this.planning});

  final RecipePlanningViewModel viewModel;
  final RecipePlanning planning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group),
          const SizedBox(width: 10),
          Text('${planning.nbOfPeople}', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
