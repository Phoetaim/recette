CREATE TABLE shoppingIngredient(
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   ingredientWithQuantityId int NOT NULL,
   shoppingListId  int,
   bought BOOL,
   FOREIGN KEY (ingredientWithQuantityId) REFERENCES ingredientWithQuantity (id) ON DELETE CASCADE
);
