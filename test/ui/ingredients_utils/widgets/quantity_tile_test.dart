// test/ui/ingredients_utils/widgets/quantity_tile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/ui/ingredients_utils/widgets/quantity_tile.dart';

const _type = IngredientTypes(id: 3, name: 'Légume', color: 0xFF4CAF50);
const _carotte = Ingredient(id: 1, name: 'carotte', type: _type);

void main() {
  Future<void> pumpTile(WidgetTester tester, IngredientWithQuantity value) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: QuantityTile(ingredientWithQuantity: value))),
    );
  }

  String textOf(WidgetTester tester) {
    final richText = tester.widget<RichText>(
      find.descendant(of: find.byType(QuantityTile), matching: find.byType(RichText)),
    );
    return richText.text.toPlainText();
  }

  testWidgets('shows only the quantity when the unit is the default one', (tester) async {
    const value = IngredientWithQuantity(
      ingredient: _carotte,
      unit: IngredientUnit(id: 1, name: 'unit'), // same id as defaultIngredientUnit
      quantity: 3,
    );

    await pumpTile(tester, value);

    expect(textOf(tester), '3');
  });

  testWidgets(
    'shows the quantity followed by the unit name when it differs from the default',
        (tester) async {
      const value = IngredientWithQuantity(
        ingredient: _carotte,
        unit: IngredientUnit(id: 5, name: 'kg'),
        quantity: 2,
      );

      await pumpTile(tester, value);

      expect(textOf(tester), '2 kg');
    },
  );
}