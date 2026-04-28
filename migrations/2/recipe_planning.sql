CREATE TABLE recipePlanning(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipeId int,
  nbOfPeople INTEGER,
  progress INTEGER,
  FOREIGN KEY (recipeId) REFERENCES recipes(id) ON DELETE CASCADE
);