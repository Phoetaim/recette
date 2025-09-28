import 'package:flutter/material.dart';

class Recipe {
  final int id;
  String name = 'Tarte à la tomate';
  String preparationTime = '1h';
  String cookingTime = '1h';
  int nbOfPeople = 4;

  Recipe(this.id);

}

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
});

  final Recipe recipe;

@override
  Widget build(BuildContext context){
 
    return Row(
      children: [
        SizedBox(width: 5),
        Text(recipe.id.toString()),
        Expanded(child: Center(child: Text(recipe.name))),
        IconRow(icon: Icons.group, label: recipe.nbOfPeople.toString()),
        SizedBox(width: 20),
        Row(
          children: [
            Column(
              children: [
                IconRow(icon: Icons.timer_outlined, label: recipe.preparationTime),
                IconRow(icon: Icons.thermostat, label: recipe.cookingTime),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class IconRow extends StatelessWidget {
  const IconRow({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon), SizedBox(width: 3), Text(label)]);
  }
}
