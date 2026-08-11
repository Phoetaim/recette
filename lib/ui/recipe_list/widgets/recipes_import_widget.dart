import 'package:flutter/material.dart';
import 'package:recette/data/services/models/raw_recipe.dart';
import 'package:recette/ui/recipe_list/view_model/recipe_list_viewmodel.dart';

class RecipesImportWidget extends StatefulWidget {
  const RecipesImportWidget({super.key, required this.viewModel});

  final RecipeListViewModel viewModel;

  @override
  State<RecipesImportWidget> createState() => _RecipesImportWidgetState();
}

class _RecipesImportWidgetState extends State<RecipesImportWidget> {
  Set<int> selectedRecipesToImport = {};

  @override
  void initState() {
    selectedRecipesToImport = widget.viewModel.recipesToImport.map((rawRecipe) => rawRecipe.id!).toSet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Recettes à importer : '),
      content: SizedBox(
        width: .maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: .vertical,
          itemCount: widget.viewModel.recipesToImport.length,

          itemBuilder: (BuildContext context, int index) {
            final rawRecipe = widget.viewModel.recipesToImport[index];
            return RawRecipeTile(
              viewModel: widget.viewModel,
              rawRecipe: rawRecipe,
              isSelected: _isRecipeSelected(rawRecipe.id!),
              toggleSelection: _toggleSelection,
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: _clearSelection,
          label: const Text('Désélectionne tout'),
          icon: const Icon(Icons.check_box_outline_blank),
        ),
        TextButton.icon(
          onPressed: _selectAll,
          label: const Text('Sélectionne tout'),
          icon: const Icon(Icons.check_box_outlined),
        ),TextButton.icon(
          onPressed: () {
            widget.viewModel.importRecipes.execute(selectedRecipesToImport);
            Navigator.of(context).pop();
          },
          label: const Text('Importer'),
          icon: const Icon(Icons.check),
        ),
      ],
    );
  }

  bool _isRecipeSelected(int recipeId) {
    return selectedRecipesToImport.contains(recipeId);
  }

  void _toggleSelection(int recipeId) {
    setState(() {
      if (!selectedRecipesToImport.add(recipeId)) {
        selectedRecipesToImport.remove(recipeId);
      }
    });
  }
  void _clearSelection() {
    setState(() {
      selectedRecipesToImport.clear();
    });
  }
  void _selectAll() {
    setState(() {
      selectedRecipesToImport = widget.viewModel.recipesToImport.map((rawRecipe) => rawRecipe.id!).toSet();
    });
  }
}

class RawRecipeTile extends StatelessWidget {
  const RawRecipeTile({
    super.key,
    required this.viewModel,
    required this.rawRecipe,
    required this.isSelected,
    required this.toggleSelection,
  });

  final RecipeListViewModel viewModel;
  final RawRecipe rawRecipe;
  final bool isSelected;
  final void Function(int) toggleSelection;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      value: isSelected,
      onChanged: (bool? value) => toggleSelection(rawRecipe.id!),
      title: Text(rawRecipe.name),
    );
  }
}
