CREATE TABLE recipes_new(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  preparationTime TEXT,
  cookingTime TEXT,
  nbOfPeople INTEGER,
  steps TEXT,
  source TEXT
);
 INSERT INTO recipes_new (id, name, preparationTime, cookingTime, nbOfPeople, steps)
    SELECT id, name, preparationTime, cookingTime, nbOfPeople, steps FROM recipes;
DROP TABLE recipes;
ALTER TABLE recipes_new RENAME TO recipes;