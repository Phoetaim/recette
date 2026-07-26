// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recette/config/dependencies.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/main.dart';
import 'package:recette/ui/recipe_list/widgets/recipe_card.dart';

const recipe = RawRecipe(
  name: 'Recette de test',
  preparationTime: '24h',
  cookingTime: '1h99',
  nbOfPeople: 666,
);

Future<void> addRecipe(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.list));
  await tester.pump();

  expect(find.text('Mes Recettes'), findsOneWidget);
  expect(find.byType(RecipeCard), findsNothing);

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.text('Mes Recettes'), findsNothing);

  await tester.enterText(find.byKey(Key('RecipeName')), recipe.name);
  await tester.enterText(find.byKey(Key('PrepTime')), recipe.preparationTime);
  await tester.enterText(find.byKey(Key('CookingTime')), recipe.cookingTime);
  await tester.enterText(find.byKey(Key('People')), recipe.nbOfPeople.toString());
  await tester.tap(find.byIcon(Icons.save));
}

void main() {
  testWidgets('Test recipe scenario', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MultiProvider(providers: providersLocal, child: const MainApp()));

    expect(find.text('Liste de courses'), findsOneWidget);

    await addRecipe(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(find.text('Mes Recettes'), findsOneWidget);

    expect(find.text(recipe.name), findsOneWidget);
    expect(find.text(recipe.preparationTime), findsOneWidget);
    expect(find.text(recipe.cookingTime), findsOneWidget);
    expect(find.text(recipe.nbOfPeople.toString()), findsOneWidget);

    await tester.tap(find.text(recipe.name));
    await tester.pump();
  });
}
