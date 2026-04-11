
CREATE TABLE ingredientUnits(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  UNIQUE(name)
);


INSERT INTO ingredientUnits VALUES(1,'unit');
INSERT INTO ingredientUnits VALUES(2,'kg');
INSERT INTO ingredientUnits VALUES(3,'g');
INSERT INTO ingredientUnits VALUES(4,'L');
INSERT INTO ingredientUnits VALUES(5,'dL');
INSERT INTO ingredientUnits VALUES(6,'cL');
INSERT INTO ingredientUnits VALUES(7,'mL');
INSERT INTO ingredientUnits VALUES(8,'cm');
INSERT INTO ingredientUnits VALUES(9,'tranche');
INSERT INTO ingredientUnits VALUES(10,'boite');
INSERT INTO ingredientUnits VALUES(11,'cac');
INSERT INTO ingredientUnits VALUES(12,'cas');