import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recette/routing/routes.dart';
import '../view_model/recipe_list_viewmodel.dart';
import 'recipe_list_body.dart';


const String recipeBase64 = 'eyJyYXdSZWNpcGVzIjpbeyJpZCI6MTgsIm5hbWUiOiJUdSB2YXMgZXRyZSBpbXBvcnRlZSBiaXMiLCJwcmVwYXJhdGlvblRpbWUiOiI5OTk5aCIsImNvb2tpbmdUaW1lIjoiMTAnIiwibmJPZlBlb3BsZSI6NjY2LCJpbmdyZWRpZW50V2l0aFF1YW50aXR5SWRzIjpbMzIsMzMsMzQsMzVdLCJzdGVwcyI6IiJ9XSwicmF3U2hvcHBpbmdJbmdyZWRpZW50cyI6W10sInJhd0luZ3JlZGllbnRzV2l0aFF1YW50aXR5IjpbeyJpZCI6MzIsImluZ3JlZGllbnRJZCI6MTY3LCJ1bml0IjoxLCJxdWFudGl0eSI6MX0seyJpZCI6MzMsImluZ3JlZGllbnRJZCI6MTE4LCJ1bml0IjoyLCJxdWFudGl0eSI6M30seyJpZCI6MzQsImluZ3JlZGllbnRJZCI6Mzk5LCJ1bml0IjoxLCJxdWFudGl0eSI6MX0seyJpZCI6MzUsImluZ3JlZGllbnRJZCI6MTE4LCJ1bml0IjoxLCJxdWFudGl0eSI6MX1dLCJyYXdJbmdyZWRpZW50cyI6W3siaWQiOjE2NywibmFtZSI6InBhdGUgw6AgcGl6emEiLCJ0eXBlIjo1fSx7ImlkIjoxMTgsIm5hbWUiOiJjaG9yaXpvIiwidHlwZSI6M30seyJpZCI6Mzk5LCJuYW1lIjoieHpjenhjengiLCJ0eXBlIjoxNX1dLCJpbmdyZWRpZW50VW5pdHMiOlt7ImlkIjoxLCJuYW1lIjoidW5pdCJ9LHsiaWQiOjIsIm5hbWUiOiJrZyJ9XSwiaW5ncmVkaWVudFR5cGVzIjpbeyJpZCI6NSwibmFtZSI6ImZyZXNoIiwiY29sb3IiOjQyODY2OTg3NDZ9LHsiaWQiOjMsIm5hbWUiOiJjaGFyY3V0ZXJpZSIsImNvbG9yIjo0Mjk0OTI0MDY2fSx7ImlkIjoxNSwibmFtZSI6ImhvdXNlIiwiY29sb3IiOjQyODEzNDgxNDR9XX0=';
class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key, required this.viewModel});

  final RecipeListViewModel viewModel;

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.deleteRecipe.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant RecipeListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.deleteRecipe.removeListener(_onResult);
    widget.viewModel.deleteRecipe.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.deleteRecipe.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            context.go(Routes.shoppingList);
          },
          child: Icon(Icons.arrow_back),
        ),
        title: const Text('Mes Recettes'),
        actions: [
          TextButton(onPressed: () => widget.viewModel.importRecipes(recipeBase64), child: Icon(Icons.arrow_downward))
        ],
        shadowColor: Colors.black,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.loadRecipes,
        builder: (context, child) {
          if (widget.viewModel.loadRecipes.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.loadRecipes.error) {
            return TextButton(onPressed: widget.viewModel.loadRecipes.execute, child: Text('Retry?'));
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            return RecipeListBody(viewModel: widget.viewModel);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(Routes.recipeDetail, pathParameters: {'recipeId': (-1).toString()});
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.deleteRecipe.completed) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recette supprimée'), duration: Duration(microseconds: 1000)));
    }

    if (widget.viewModel.deleteRecipe.error) {
      widget.viewModel.deleteRecipe.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while loading')));
    }
  }
}
