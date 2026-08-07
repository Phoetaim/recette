import 'package:flutter/material.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_controllers.dart';

class RecipeStepsWidget extends StatefulWidget {
  const RecipeStepsWidget({super.key, required this.recipeControllers});

  final RecipeControllers recipeControllers;

  @override
  State<RecipeStepsWidget> createState() => _RecipeStepsWidgetState();
}

class _RecipeStepsWidgetState extends State<RecipeStepsWidget> {
  bool isEditing = false;
  static const WidgetStateProperty<Icon> thumbIcon = WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.edit),
      WidgetState.any: Icon(Icons.close),
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: .max,
            mainAxisAlignment: .spaceBetween,
            children: [
              Text('Etapes:', style: TextStyle(fontSize: 15, color: theme.colorScheme.onTertiaryContainer),),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SwitchListTile(
                    thumbIcon: thumbIcon,
                    value: isEditing,
                    onChanged: (bool value) => setState(() {
                      isEditing = value;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onChanged: (String value) {

                  },
                  maxLines: isEditing ? 50 : widget.recipeControllers.stepsController.text.split('\n').toList().length,
                  decoration: InputDecoration(border: InputBorder.none),
                  readOnly: !isEditing,
                  controller: widget.recipeControllers.stepsController,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
