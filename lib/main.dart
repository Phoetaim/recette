import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recette/recipe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var recipes = <Recipe>[];
  int id = 0;
  void resetRecipes() {
    recipes = [];
    id = 0;
    for (var i = 0; i < 3; i++) {
      addRecipe(Recipe(i));
    }
    notifyListeners();
  }

  void addRecipe(Recipe recipe) {
    id++;
    recipes.add(recipe);
    notifyListeners();
  }

  void deleteRecipe(Recipe recipe) {
    if (recipes.contains(recipe)) {
      recipes.remove(recipe);
      notifyListeners();
    }
    if (recipes.isEmpty) {
      id = 0;
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () {appState.resetRecipes();}, child: Icon(Icons.home)),
        title: const Text('Mes Recettes'),
        shadowColor: Colors.black,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: appState.recipes.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    RecipeFullCard(appState: appState, index: index),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.addRecipe(Recipe(appState.id));
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RecipeFullCard extends StatelessWidget {
  const RecipeFullCard({
    super.key,
    required this.appState,
    required this.index,
  });

  final MyAppState appState;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              print('view Recipe ${appState.recipes[index].id}');
            },
            child: RecipeCard(recipe: appState.recipes[index]),
          ),
        ),
        TextButton(
          onPressed: () {
            appState.deleteRecipe(appState.recipes[index]);
          },
          child: Icon(Icons.delete),
        ),
      ],
    );
  }
}
