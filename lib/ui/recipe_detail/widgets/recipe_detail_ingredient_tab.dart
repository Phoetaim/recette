import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/ingredient/ingredient_with_quantity.dart';
import '../../ingredients_utils/view_model/ingredients_utils_viewmodel.dart';
import '../../ingredients_utils/widgets/ingredient_search_widget.dart';
import '../../ingredients_utils/widgets/quantity_tile.dart';
import '../view_model/recipe_detail_viewmodel.dart';

class RecipeDetailIngredientTab extends StatelessWidget {
  const RecipeDetailIngredientTab({super.key, required this.viewModel});

  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IngredientSearch(
          viewModel: IngredientsUtilsViewModel(ingredientRepository: context.read(), ingredientUnitsRepository: context.read()),
          callbackForIngredient: viewModel.addIngredientWithQuantity,
        ),
        IngredientsCard(viewModel: viewModel),
      ],
    );
  }
}

class IngredientsCard extends StatelessWidget {
  const IngredientsCard({super.key, required this.viewModel});

  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ValueListenableBuilder(
        valueListenable: viewModel.currentNumberOfPeople,
        builder: (context, value, child) {
          return ValueListenableBuilder(
            valueListenable: viewModel.recipe,
            builder: (context, value, child) {
              return ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: viewModel.recipe.value.ingredients.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  return IngredientCard(
                    viewModel: viewModel,
                    ingredientWithQuantity: viewModel.recipe.value.ingredients[index],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class IngredientCard extends StatelessWidget {
  const IngredientCard({super.key, required this.viewModel, required this.ingredientWithQuantity});
  final RecipeDetailViewModel viewModel;
  final IngredientWithQuantity ingredientWithQuantity;
  @override
  Widget build(BuildContext context) {
    double quantity =
        viewModel.currentNumberOfPeople.value *
        ingredientWithQuantity.quantity /
        viewModel.recipe.value.nbOfPeople;
    return Dismissible(
      key: Key(ingredientWithQuantity.id.toString()),
      onDismissed: (direction) {
        viewModel.removeIngredientWithQuantity(ingredientWithQuantity);
      },
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(ingredientWithQuantity.ingredient.name),
              ),
            ),
            QuantityTile(
              ingredientWithQuantity: ingredientWithQuantity.copyWith(quantity: quantity.toInt()),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNumberInput extends StatefulWidget {
  const CustomNumberInput({
    super.key,
    required this.viewModel,
    this.minValue = 1,
    this.maxValue = 50,
    this.step = 1,
  });

  final RecipeDetailViewModel viewModel;
  final int minValue;
  final int maxValue;
  final int step;

  @override
  State<CustomNumberInput> createState() => _CustomNumberInputState();
}

class _CustomNumberInputState extends State<CustomNumberInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.viewModel.currentNumberOfPeople.value.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    super.dispose();
  }

  // Update value when buttons are pressed
  void _updateValue(int delta) {
    final newValue = widget.viewModel.currentNumberOfPeople.value + delta;
    if (newValue >= widget.minValue && newValue <= widget.maxValue) {
      widget.viewModel.currentNumberOfPeople.value = newValue;
      _controller.text = newValue.toString(); // Sync controller
    }
  }

  // Handle manual input from the text field
  void _onTextChanged(String value) {
    if (value.isEmpty) return;
    final parsedValue = int.tryParse(value);
    if (parsedValue != null && parsedValue >= widget.minValue && parsedValue <= widget.maxValue) {
      setState(() => widget.viewModel.currentNumberOfPeople.value = parsedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 8),
          Icon(Icons.group),
          // Decrement Button
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: widget.viewModel.currentNumberOfPeople.value > widget.minValue
                ? () => _updateValue(-widget.step)
                : null, // Disable when at min
          ),

          // Numeric Input Field
          SizedBox(
            width: 60,
            child: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: _onTextChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a number';
                }
                final num = int.tryParse(value);
                if (num == null) {
                  return 'Invalid number';
                }
                if (num < widget.minValue || num > widget.maxValue) {
                  return 'Must be between ${widget.minValue} and ${widget.maxValue}';
                }
                return null;
              },
            ),
          ),

          // Increment Button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.viewModel.currentNumberOfPeople.value < widget.maxValue
                ? () => _updateValue(widget.step)
                : null, // Disable when at max
          ),
          Tooltip(
            message: 'Adding ingredients to shopping list will automatically save the recipe.',
            margin: EdgeInsets.symmetric(vertical: 5.0),
            showDuration: const Duration(seconds: 2),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  widget.viewModel.addRecipeToShoppingList.execute(), // Disable when at max
            ),
          ),
        ],
      ),
    );
  }
}
