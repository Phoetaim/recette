import 'package:flutter/material.dart';
import 'package:link_text/link_text.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_controllers.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RecipeSourceWidget extends StatefulWidget {
  const RecipeSourceWidget({super.key, required this.recipeControllers});

  final RecipeControllers recipeControllers;

  @override
  State<RecipeSourceWidget> createState() => _RecipeSourceWidgetState();
}

class _RecipeSourceWidgetState extends State<RecipeSourceWidget> {
  bool isEditing = false;
  static const WidgetStateProperty<Icon> thumbIcon = WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.edit),
      WidgetState.any: Icon(Icons.close),
    },
  );

  @override
  Widget build(BuildContext context) {
    Widget child;
    final currentText = widget.recipeControllers.sourceController.text;
    if (isEditing) {
      child = TextFormField(
        readOnly: !isEditing,
        controller: widget.recipeControllers.sourceController,
        decoration: InputDecoration(hintText: 'IG bas p 154', border: InputBorder.none, labelText: 'Source'),
      );
    } else {
      child = LinkText(
        currentText,
        onLinkTap: (String value) {
          launchUrlString(currentText);
        },
      );
    }
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SwitchListTile(
            thumbIcon: thumbIcon,
            value: isEditing,
            onChanged: (bool value) => setState(() {
              isEditing = value;
            }),
          ),
        ),
        Expanded(flex: 3, child: child),
      ],
    );
  }
}
