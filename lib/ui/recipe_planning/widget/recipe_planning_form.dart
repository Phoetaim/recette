import 'package:flutter/material.dart';
import 'package:recette/domain/models/recipe/recipe_planning.dart';
import 'package:recette/ui/recipe_planning/view_model/recipe_planning_viewmodel.dart';

import 'recipe_search_widget.dart';

class RecipePlanningForm extends StatefulWidget {
  const RecipePlanningForm({super.key, required this.viewModel});

  final RecipePlanningViewModel viewModel;

  @override
  State<RecipePlanningForm> createState() => _RecipePlanningFormState();
}

class _RecipePlanningFormState extends State<RecipePlanningForm> {
  bool isRecipe = true;
  SearchController searchController = SearchController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Individual field keys
  final GlobalKey<FormFieldState<bool>> isRecipeKey = GlobalKey<FormFieldState<bool>>();
  final GlobalKey<FormFieldState<String>> recipeTextKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<int>> recipeIdKey = GlobalKey<FormFieldState<int>>();
  final GlobalKey<FormFieldState<String>> quantityKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: .start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 1,
                    child: TextFormField(
                      key: quantityKey,
                      keyboardType: TextInputType.number,
                      initialValue: '2',
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Personnes',
                        hintText: '2',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez un nombre de personne';
                        }
                        try {
                          int.parse(value);
                        } on FormatException {
                          return 'Ce n\'est pas un nombre';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    flex: 2,
                    child: Align(
                      child: FormField<bool>(
                        key: isRecipeKey,

                        initialValue: isRecipe,
                        builder: (FormFieldState<bool> state) {
                          return SwitchListTile(
                            title: _getToggleLabel(),
                            value: state.value ?? false,
                            onChanged: (bool value) {
                              state.didChange(value);
                              setState(() => isRecipe = value);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isRecipe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormField<int>(
                  key: recipeIdKey,
                  builder: (FormFieldState<int> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RecipeSearchWidget(
                          viewModel: widget.viewModel,
                          controller: searchController,
                          callbackForRecipe: (int recipeId) {
                            state.didChange(recipeId);
                          },
                        ),
                        if (state.hasError)
                          Padding(
                            padding: EdgeInsetsGeometry.directional(start: 55, top: 3),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
                            ),
                          ),
                      ],
                    );
                  },
                  validator: (int? value) {
                    if (isRecipeKey.currentState != null && isRecipeKey.currentState!.value!) {
                      if (value == null) {
                        return 'Entrez un intitulé de recette';
                      }
                    }
                    return null;
                  },
                ),
              ),
            if (!isRecipe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  key: recipeTextKey,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Nom du plat',
                    hintText: 'Melon jambon cru, ...',
                  ),
                  validator: (String? value) {
                    if (isRecipeKey.currentState != null && !isRecipeKey.currentState!.value!) {
                      if (value == null || value == '') {
                        return 'Entrez un intitulé de plat';
                      }
                    }
                    return null;
                  },
                ),
              ),
            Center(
              child: Row(
                mainAxisSize: .max,
                mainAxisAlignment: .spaceEvenly,
                children: [
                  Padding(
                    padding: const .all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState!.validate()) {
                          RecipePlanning planning;
                          if (isRecipeKey.currentState!.value!) {
                            planning = RecipePlanning(
                              recipeId: recipeIdKey.currentState!.value,
                              nbOfPeople: int.parse(quantityKey.currentState!.value!),
                            );
                          } else {
                            planning = RecipePlanning(
                              recipeText: recipeTextKey.currentState!.value,
                              nbOfPeople: int.parse(quantityKey.currentState!.value!),
                            );
                          }
                          widget.viewModel.addRecipePlanning.execute(planning);
                        }
                      },
                      child: const Text('Planifier'),
                    ),
                  ),
                  Padding(
                    padding: const .all(8.0),
                    child: ElevatedButton(
                      onPressed: widget.viewModel.deleteAllRecipePlannings,
                      child: const Text('Tout effacer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Text _getToggleLabel() {
    return Text(isRecipe ? 'Mode Recette' : 'Mode Texte');
  }
}
