CREATE TABLE ingredientWithQuantity(
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   ingredientId INTEGER NOT NULL,
   unit INTEGER,
   quantity INTEGER,
   FOREIGN KEY (ingredientId) REFERENCES ingredients(id) ON DELETE CASCADE,
   FOREIGN KEY (unit) REFERENCES ingredientUnits(id) ON DELETE CASCADE
);
