import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/recipe/recipe.dart';
import '../view_model/recipe_detail_viewmodel.dart';

class RecipeDetailInfoTab extends StatelessWidget {
  const RecipeDetailInfoTab({super.key, required this.viewModel});

  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    Recipe recipe = viewModel.recipe.value;
    return Column(
      children: [
        HeaderRow(recipe: recipe, viewModel: viewModel),
        StepCard(recipe: recipe),
      ],
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key, required this.recipe, required this.viewModel});

  final Recipe recipe;
  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4),
        Card(
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: HeaderTextFormField(
                    fieldKey: Key('PrepTime'),
                    prefix: Text(' Prep:  '),
                    initialValue: recipe.preparationTime,
                    callback: (value) => viewModel.updateRecipePreparationTime(value),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: HeaderTextFormField(
                    fieldKey: Key('CookingTime'),
                    prefix: Text(' Cuisson:  '),
                    initialValue: recipe.cookingTime,
                    callback: (value) => viewModel.updateRecipeCookingTime(value),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: HeaderTextFormField(
                    fieldKey: Key('People'),
                    prefix: Text(' Personnes:  '),
                    initialValue: recipe.nbOfPeople.toString(),
                    keyBoardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    callback: (value) => viewModel.updateRecipeNbOfPeople(value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HeaderTextFormField extends StatefulWidget {
  const HeaderTextFormField({
    super.key,
    required this.fieldKey,
    this.prefix,
    required this.initialValue,
    required this.callback,
    this.keyBoardType,
    this.inputFormatters,
  });
  final Key fieldKey;
  final Widget? prefix;
  final String initialValue;
  final TextInputType? keyBoardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String) callback;

  @override
  State<HeaderTextFormField> createState() => _HeaderTextFormFieldState();
}

class _HeaderTextFormFieldState extends State<HeaderTextFormField> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      decoration: InputDecoration(border: InputBorder.none, prefix: widget.prefix),
      keyboardType: widget.keyBoardType,
      inputFormatters: widget.inputFormatters,
      initialValue: widget.initialValue,
      onFieldSubmitted: widget.callback,
      onChanged: (value) {
        setState(() {
          _currentValue = value;
        });
        widget.callback(_currentValue);
      },
      onTapOutside: (PointerDownEvent event) {
        FocusScope.of(context).unfocus();
      },
    );
  }
}

class StepCard extends StatelessWidget {
  const StepCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4),
        Row(
          children: [
            Text('Etapes:'),
            TextButton(
              onPressed: () {
                print('modify steps');
              },
              child: Icon(Icons.edit),
            ),
          ],
        ),
        SizedBox(height: 4),
        Card(
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: recipe.steps.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('\u2022 ${recipe.steps[index]}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
