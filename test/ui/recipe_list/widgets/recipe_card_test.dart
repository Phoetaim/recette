// test/ui/recipe_list/widgets/recipe_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/ui/recipe_list/widgets/recipe_card.dart';

void main() {
  group('RecipeCard', () {
    testWidgets('affiche le nom, le nombre de personnes, la préparation et la cuisson', (
      WidgetTester tester,
    ) async {
      const recipe = RawRecipe(
        name: 'Tarte aux pommes',
        preparationTime: '20min',
        cookingTime: '45min',
        nbOfPeople: 6,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );

      expect(find.text('Tarte aux pommes'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('20min'), findsOneWidget);
      expect(find.text('45min'), findsOneWidget);
    });

    testWidgets('affiche les bonnes icônes', (WidgetTester tester) async {
      const recipe = RawRecipe(name: 'Soupe');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );

      expect(find.byIcon(Icons.group), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.thermostat), findsOneWidget);
    });

    testWidgets('utilise les valeurs par défaut quand la recette est incomplète', (
      WidgetTester tester,
    ) async {
      const recipe = RawRecipe(); // toutes les valeurs par défaut

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );

      expect(find.text('Sans nom'), findsOneWidget);
      expect(find.text('4'), findsOneWidget); // nbOfPeople par défaut
      expect(find.text('-'), findsNWidgets(2)); // preparationTime et cookingTime
    });
  });

  group('IconRow', () {
    testWidgets('affiche une icône et un label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconRow(icon: Icons.timer_outlined, label: '30min'),
          ),
        ),
      );

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.text('30min'), findsOneWidget);
    });

    testWidgets('affiche un label vide sans planter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconRow(icon: Icons.group, label: ''),
          ),
        ),
      );

      expect(find.byIcon(Icons.group), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });
  });
}
