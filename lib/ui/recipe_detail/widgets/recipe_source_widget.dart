import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_text/link_text.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_controllers.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RecipeSourceWidget extends StatelessWidget {
  const RecipeSourceWidget({super.key, required this.recipeControllers});

  final RecipeControllers recipeControllers;

  @override
  Widget build(BuildContext context) {
    if (recipeControllers.isEditing.value) {
      return TextFormField(
        controller: recipeControllers.sourceController,
        decoration: InputDecoration(
          hintText: 'IG bas p 154',
          border: InputBorder.none,
          labelText: 'Source',
        ),
      );
    } else {
      final currentText = recipeControllers.sourceController.text;
      final iconData = currentText.startsWith('http')? CupertinoIcons.globe: CupertinoIcons.book;
      return Wrap(

        children: [
          Icon(iconData),
          SizedBox(width: 4),
          LinkText(
            currentText,
            onLinkTap: (String value) {
              launchUrlString(currentText);
            },
          ),
        ],
      );
    }
  }
}
