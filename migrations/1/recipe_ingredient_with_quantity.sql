CREATE TABLE recipesIngredientsWithQuantity(
    recipeId INTEGER,
    ingredientWithQuantityId INTEGER,
    PRIMARY KEY (recipeId, ingredientWithQuantityId),
    FOREIGN KEY (recipeId) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredientWithQuantityId) REFERENCES ingredientWithQuantity(id) ON DELETE CASCADE
);