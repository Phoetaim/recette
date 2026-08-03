import 'package:flutter/material.dart';
import 'package:recette/domain/models/recipe/recipe_planning.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_view_model.dart';

import 'recipe_search_widget.dart';

class RecipePlanningForm extends StatefulWidget {
  const RecipePlanningForm({super.key, required this.viewModel});

  final RecipePlanningViewModel viewModel;

  @override
  State<RecipePlanningForm> createState() => _RecipePlanningFormState();
}

class _RecipePlanningFormState extends State<RecipePlanningForm> {
  bool isText = true;
  SearchController searchController = SearchController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Individual field keys
  final GlobalKey<FormFieldState<bool>> isTextKey = GlobalKey<FormFieldState<bool>>();
  final GlobalKey<FormFieldState<String>> recipeTextKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<int>> recipeIdKey = GlobalKey<FormFieldState<int>>();
  final GlobalKey<FormFieldState<String>> quantityKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: .start,
        children: <Widget>[
          TextFormField(
            key: quantityKey,
            keyboardType: TextInputType.number,
            initialValue: '2',
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Nb de personnes',
              hintText: '2',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Entrez le texte';
              }
              try {
                int.parse(value);
              } on FormatException {
                return 'Ce n\'est pas un nombre';
              }
              return null;
            },
          ),
          FormField<bool>(
            key: isTextKey,

            initialValue: isText,
            builder: (FormFieldState<bool> state) {
              return SwitchListTile(
                title: _getToggleLabel(),
                value: state.value ?? false,
                onChanged: (bool value) {
                  state.didChange(value);
                  setState(() => isText = value);
                },
              );
            },
          ),
          if (isText)
          TextFormField(
            key: recipeTextKey,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Nom du plat',
              hintText: 'Melon jambon cru, ...',
            ),
            validator: (String? value) {
              if (isTextKey.currentState != null && isTextKey.currentState!.value!) {
                if (value == null || value == '') {
                  return 'Entrez un intitulé de recette';
                }
              }
              return null;
            },
          ),
          if (!isText)
            FormField<int>(
              key: recipeIdKey,
              builder: (FormFieldState<int> state) {
                return RecipeSearchWidget(
                  viewModel: widget.viewModel,
                  controller: searchController,
                  callbackForRecipe: (int recipeId) {
                    state.didChange(recipeId);
                  },
                );
              },

            ),
          Padding(
            padding: const .symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  RecipePlanning planning;
                  if (isTextKey.currentState!.value!) {
                    planning = RecipePlanning(
                      textRecipe: recipeTextKey.currentState!.value,
                      nbOfPeople: int.parse(quantityKey.currentState!.value!),
                    );
                  } else {
                    planning = RecipePlanning(
                      recipeId: recipeIdKey.currentState!.value,
                      nbOfPeople: int.parse(quantityKey.currentState!.value!),
                    );
                  }
                  widget.viewModel.addTextRecipePlanning.execute(planning);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Text _getToggleLabel() {
    return Text(isText ? 'Mode texte' : 'Mode recette');
  }
}
