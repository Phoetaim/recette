// test/domain/models/ingredient/ingredient_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recette/data/services/models/raw_ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';

void main() {
  group('Ingredient - valeurs par défaut', () {
    test('applique le type par défaut "other" quand aucun type n\'est fourni', () {
      const ingredient = Ingredient(name: 'Mystère');

      expect(ingredient.id, isNull);
      expect(ingredient.name, 'Mystère');
      expect(ingredient.type, const IngredientTypes(id: 0, name: 'other', color: 4292269782));
    });

    test('accepte des valeurs personnalisées', () {
      const type = IngredientTypes(id: 3, name: 'Légume', color: 123);
      const ingredient = Ingredient(id: 1, name: 'Carotte', type: type);

      expect(ingredient.id, 1);
      expect(ingredient.name, 'Carotte');
      expect(ingredient.type, type);
    });
  });

  group('Ingredient - égalité et immutabilité (freezed)', () {
    test('deux instances avec les mêmes valeurs sont égales', () {
      const a = Ingredient(id: 1, name: 'Carotte');
      const b = Ingredient(id: 1, name: 'Carotte');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('deux instances avec des types différents ne sont pas égales', () {
      const a = Ingredient(
        id: 1,
        name: 'Carotte',
        type: IngredientTypes(id: 1, name: 'Légume', color: 1),
      );
      const b = Ingredient(
        id: 1,
        name: 'Carotte',
        type: IngredientTypes(id: 2, name: 'Fruit', color: 2),
      );

      expect(a, isNot(equals(b)));
    });

    test('copyWith ne modifie que le champ ciblé et laisse l\'original intact', () {
      const original = Ingredient(id: 1, name: 'Carotte');

      final updated = original.copyWith(name: 'Panais');

      expect(updated.name, 'Panais');
      expect(updated.id, 1);
      expect(original.name, 'Carotte');
    });
  });

  group('Ingredient - fromJson / toJson', () {
    test('fromJson parse correctement un JSON complet', () {
      final json = {
        'id': 5,
        'name': 'Tomate',
        'type': {'id': 3, 'name': 'Légume', 'color': 123},
      };

      final ingredient = Ingredient.fromJson(json);

      expect(ingredient.id, 5);
      expect(ingredient.name, 'Tomate');
      expect(ingredient.type, const IngredientTypes(id: 3, name: 'Légume', color: 123));
    });

    test('fromJson applique le type par défaut si absent du JSON', () {
      final ingredient = Ingredient.fromJson({'name': 'Sans type'});

      expect(ingredient.name, 'Sans type');
      expect(ingredient.type, const IngredientTypes(id: 0, name: 'other', color: 4292269782));
    });

    test('toJson puis fromJson redonne un objet équivalent (round-trip)', () {
      const original = Ingredient(
        id: 9,
        name: 'Poireau',
        type: IngredientTypes(id: 4, name: 'Légume', color: 456),
      );

      final json = original.toJson();
      final restored = Ingredient.fromJson(json);

      expect(restored, equals(original));
    });

    test(
      'sérialise le type imbriqué en Map (pas l\'objet IngredientTypes brut) — '
          'régression sur le @JsonKey(toJson: ...) de type',
          () {
        const ingredient = Ingredient(
          id: 1,
          name: 'Carotte',
          type: IngredientTypes(id: 3, name: 'Légume', color: 123),
        );

        final json = ingredient.toJson();

        expect(json['type'], isA<Map<String, dynamic>>());
        expect(json['type'], {'id': 3, 'name': 'Légume', 'color': 123});
      },
    );
  });

  group('compareIngredientType', () {
    test('trie par nom de type, ordre alphabétique', () {
      const legume = Ingredient(
        name: 'Carotte',
        type: IngredientTypes(id: 1, name: 'Légume', color: 1),
      );
      const fruit = Ingredient(
        name: 'Pomme',
        type: IngredientTypes(id: 2, name: 'Fruit', color: 2),
      );

      expect(compareIngredientType(fruit, legume), lessThan(0));
      expect(compareIngredientType(legume, fruit), greaterThan(0));
    });

    test('retourne 0 pour deux ingrédients de même type', () {
      const a = Ingredient(name: 'Carotte', type: IngredientTypes(id: 1, name: 'Légume', color: 1));
      const b = Ingredient(name: 'Panais', type: IngredientTypes(id: 2, name: 'Légume', color: 2));

      expect(compareIngredientType(a, b), 0);
    });
  });

  group('compareIngredientName', () {
    test('trie par nom d\'ingrédient, ordre alphabétique', () {
      const carotte = Ingredient(name: 'Carotte');
      const panais = Ingredient(name: 'Panais');

      expect(compareIngredientName(carotte, panais), lessThan(0));
      expect(compareIngredientName(panais, carotte), greaterThan(0));
    });

    test('retourne 0 pour deux ingrédients de même nom', () {
      const a = Ingredient(name: 'Carotte');
      const b = Ingredient(name: 'Carotte');

      expect(compareIngredientName(a, b), 0);
    });
  });

  group('compareIngredients (tri combiné : type puis nom)', () {
    test('trie d\'abord par type, puis par nom au sein d\'un même type', () {
      const legumeCarotte = Ingredient(
        name: 'Carotte',
        type: IngredientTypes(id: 1, name: 'Légume', color: 1),
      );
      const legumePanais = Ingredient(
        name: 'Panais',
        type: IngredientTypes(id: 1, name: 'Légume', color: 1),
      );
      const fruitPomme = Ingredient(
        name: 'Pomme',
        type: IngredientTypes(id: 2, name: 'Fruit', color: 2),
      );

      final sorted = [legumePanais, fruitPomme, legumeCarotte]..sort(compareIngredients);

      expect(sorted, [fruitPomme, legumeCarotte, legumePanais]);
    });
  });

  group('convertIngredientToRawIngredient', () {
    test('convertit un Ingredient en RawIngredient en reprenant l\'id de son type', () {
      const ingredient = Ingredient(
        id: 7,
        name: 'Tomate',
        type: IngredientTypes(id: 3, name: 'Légume', color: 123),
      );

      final raw = convertIngredientToRawIngredient(ingredient);

      expect(raw, const RawIngredient(id: 7, name: 'Tomate', type: 3));
    });

    test('conserve un id d\'ingrédient nul (nouvel ingrédient non encore persisté)', () {
      const ingredient = Ingredient(
        name: 'Nouveau',
        type: IngredientTypes(id: 1, name: 'Légume', color: 1),
      );

      final raw = convertIngredientToRawIngredient(ingredient);

      expect(raw.id, isNull);
      expect(raw.type, 1);
    });

    test(
      'lève une erreur si le type de l\'ingrédient n\'a pas d\'id '
          '(utilisation de l\'opérateur ! sur type.id)',
          () {
        const ingredient = Ingredient(
          name: 'Sans id de type',
          type: IngredientTypes(name: 'Inconnu', color: 0),
        );

        expect(() => convertIngredientToRawIngredient(ingredient), throwsA(isA<TypeError>()));
      },
    );
  });
}