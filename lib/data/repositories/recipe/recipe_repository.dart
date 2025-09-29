
class Recipe {
  final int id;
  String name = 'Tarte à la tomate';
  String preparationTime = '1h';
  String cookingTime = '1h';
  int nbOfPeople = 4;

  Recipe(this.id);

}


class RecipeRepository {
  List<Recipe> _recipeList = [];

  void initDb(){
    print('Hi there');
    _recipeList = List.generate(20, (int index) => Recipe(index));
    print(_recipeList.length);
  }

  List<Recipe> get  getRecipeList => _recipeList;

  void addRecipe(Recipe recipe){
    print('yes');
    _recipeList.add(recipe);
  }

  void removeRecipe(Recipe recipe){
    _recipeList.remove(recipe);
  }

  void resetRecipes(){
    _recipeList.clear();
  }
}