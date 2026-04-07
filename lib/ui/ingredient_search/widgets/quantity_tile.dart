import 'package:flutter/material.dart';

import '../../../data/services/models/raw_ingredient_with_quantity.dart';
import '../../../domain/models/ingredient/ingredient_with_quantity.dart';

class QuantityTile extends StatelessWidget {
  const QuantityTile({
    super.key,
    required this.ingredientWithQuantity,
  });

  final IngredientWithQuantity ingredientWithQuantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15, color: Colors.blueGrey),
          children: <TextSpan>[
            TextSpan(text: ingredientWithQuantity.quantity.toInt().toString()),
            if (ingredientWithQuantity.unit != IngredientUnit.unit)
              TextSpan(text: ' ${ingredientWithQuantity.unit.name}'),
          ],
        ),
      ),
    );
  }
}
