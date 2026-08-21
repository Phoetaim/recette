import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/domain/models/recipe/recipe_planning.dart';
import 'package:recette/routing/routes.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_viewmodel.dart';


class RecipePlanningCard extends StatelessWidget {
  const RecipePlanningCard({super.key, required this.viewModel, required this.planning});

  final RecipePlanningViewModel viewModel;
  final RecipePlanning planning;

  @override
  Widget build(BuildContext context) {
    String recipeName = '';
    if (planning.recipeId != null) {
      recipeName = viewModel.getRecipe(planning.recipeId!).name;
    } else if (planning.recipeText != null) {
      recipeName = planning.recipeText!;
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

        secondary: SizedBox(
          width: 110,
          child: Row(
            mainAxisAlignment: .end,
            children: [
              if (planning.recipeId != null)
                SizedBox(
                  width: 50,
                  child: TextButton.icon(
                      onPressed: () => context.pushNamed(
                        Routes.recipeDetail,
                        pathParameters: {'recipeId': planning.recipeId!.toString()},
                      ),
                      label: Icon(CupertinoIcons.arrowshape_turn_up_right_fill),
                    ),
                ),
              SizedBox(width:60, child: PlanningQuantityTile(viewModel: viewModel, planning: planning)),
            ],
          ),
        ),
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
    return Row(
      mainAxisAlignment: .end,
      children: [
        Text('${planning.nbOfPeople}', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Icon(Icons.group),
      ],
    );
  }
}
