import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
import '../view_model/ingredient_list_viewmodel.dart';
import 'ingredient_list_body.dart';

class IngredientListScreen extends StatefulWidget {
  const IngredientListScreen({super.key, required this.viewModel});

  final IngredientListViewModel viewModel;

  @override
  State<IngredientListScreen> createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.deleteIngredient.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant IngredientListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.deleteIngredient.removeListener(_onResult);
    widget.viewModel.deleteIngredient.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.deleteIngredient.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            context.go(Routes.recipeList);
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text('Liste d\'ingrédients'),
        shadowColor: Colors.black,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.loadIngredientList,
        builder: (context, child) {
          if (widget.viewModel.loadIngredientList.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.loadIngredientList.error) {
            return TextButton(onPressed: () => context.go(Routes.recipeList), child: Text('Return to recipe list?'));
          }
          return IngredientListBody(viewModel: widget.viewModel);
        },
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.deleteIngredient.completed) {
      context.go(Routes.recipeList);
    }

    if (widget.viewModel.deleteIngredient.error) {
      widget.viewModel.deleteIngredient.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while loading')));
    }
  }
}
