CREATE TABLE ingredientTypes(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT NOT NULL,
                  color INTEGER,
                  UNIQUE(name)
                 );

INSERT INTO ingredientTypes VALUES(0,'other', 4292269782);
INSERT INTO ingredientTypes VALUES(1,'fruit', 4279983648);
INSERT INTO ingredientTypes VALUES(2,'meat', 4290190364);
INSERT INTO ingredientTypes VALUES(3,'charcuterie', 4294924066);
INSERT INTO ingredientTypes VALUES(4,'fish', 4280391411);
INSERT INTO ingredientTypes VALUES(5,'fresh', 4286698746);
INSERT INTO ingredientTypes VALUES(6,'frozen', 4292998654);
INSERT INTO ingredientTypes VALUES(7,'cheese', 4294961979);
INSERT INTO ingredientTypes VALUES(8,'can', 4286695300);
INSERT INTO ingredientTypes VALUES(9,'starches', 4294964637);
INSERT INTO ingredientTypes VALUES(10,'bread', 4294962776);
INSERT INTO ingredientTypes VALUES(11,'salty', 4294217649);
INSERT INTO ingredientTypes VALUES(12,'seasonings', 4286141768);
INSERT INTO ingredientTypes VALUES(13,'sweet', 4293467747);
INSERT INTO ingredientTypes VALUES(14,'drinks', 4288776319);
INSERT INTO ingredientTypes VALUES(15,'house', 4281348144);

