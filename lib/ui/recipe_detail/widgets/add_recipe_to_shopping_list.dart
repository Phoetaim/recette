import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';

class CustomNumberInput extends StatefulWidget {
  const CustomNumberInput({
    super.key,
    required this.viewModel,
    required this.callback,
    this.minValue = 1,
    this.maxValue = 50,
    this.step = 1,
  });

  final RecipeDetailViewModel viewModel;
  final VoidCallback callback;
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
            child: IconButton(icon: Icon(Icons.shopping_cart), onPressed: widget.callback),
          ),
        ],
      ),
    );
  }
}
