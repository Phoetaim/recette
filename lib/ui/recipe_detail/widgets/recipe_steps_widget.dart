import 'package:flutter/material.dart';
import 'package:recette/domain/models/recipe/recipe.dart';

class RecipeStepsWidget extends StatefulWidget {
  const RecipeStepsWidget({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeStepsWidget> createState() => _RecipeStepsWidgetState();
}

class _RecipeStepsWidgetState extends State<RecipeStepsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4),
        Row(
          children: [
            Text('Etapes:'),
            TextButton(onPressed: null, child: Icon(Icons.edit)),
          ],
        ),
        SizedBox(height: 4),
        Card(
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.recipe.steps.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('\u2022 ${widget.recipe.steps[index]}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
