// test/data/services/models/raw_recipe_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recette/data/services/models/raw_recipe.dart';

void main() {
  group('RawRecipe - valeurs par défaut', () {
    test('applique les valeurs par défaut quand rien n\'est fourni', () {
      const recipe = RawRecipe();

      expect(recipe.id, isNull);
      expect(recipe.name, 'Sans nom');
      expect(recipe.preparationTime, '-');
      expect(recipe.cookingTime, '-');
      expect(recipe.nbOfPeople, 4);
      expect(recipe.ingredientWithQuantityIds, isEmpty);
      expect(recipe.steps, '');
    });

    test('accepte des valeurs personnalisées', () {
      const recipe = RawRecipe(
        id: 1,
        name: 'Tarte à la tomate',
        preparationTime: '20min',
        cookingTime: '45min',
        nbOfPeople: 6,
        ingredientWithQuantityIds: [1, 2, 3],
        steps: 'Étape 1.\n Étape 2.',
      );

      expect(recipe.id, 1);
      expect(recipe.name, 'Tarte à la tomate');
      expect(recipe.nbOfPeople, 6);
      expect(recipe.ingredientWithQuantityIds, [1, 2, 3]);
      expect(recipe.steps, 'Étape 1.\n Étape 2.');
    });
  });

  group('RawRecipe - égalité et immutabilité (freezed)', () {
    test('deux instances avec les mêmes valeurs sont égales', () {
      const a = RawRecipe(id: 1, name: 'Soupe');
      const b = RawRecipe(id: 1, name: 'Soupe');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('deux instances avec des valeurs différentes ne sont pas égales', () {
      const a = RawRecipe(id: 1, name: 'Soupe');
      const b = RawRecipe(id: 2, name: 'Soupe');

      expect(a, isNot(equals(b)));
    });

    test('copyWith ne modifie que le champ ciblé et laisse l\'original intact', () {
      const original = RawRecipe(id: 1, name: 'Soupe', nbOfPeople: 2);

      final updated = original.copyWith(nbOfPeople: 4);

      expect(updated.name, 'Soupe');
      expect(updated.nbOfPeople, 4);
      expect(original.nbOfPeople, 2);
    });
  });

  group('RawRecipe - fromJson / toJson', () {
    test('fromJson parse correctement un JSON complet', () {
      final json = {
        'id': 3,
        'name': 'Ratatouille',
        'preparationTime': '15min',
        'cookingTime': '30min',
        'nbOfPeople': 4,
        'ingredientWithQuantityIds': [10, 20],
        'steps': 'Couper les légumes',
      };

      final recipe = RawRecipe.fromJson(json);

      expect(recipe.id, 3);
      expect(recipe.name, 'Ratatouille');
      expect(recipe.ingredientWithQuantityIds, [10, 20]);
      expect(recipe.steps, 'Couper les légumes');
    });

    test('fromJson applique les valeurs par défaut sur un JSON partiel', () {
      final recipe = RawRecipe.fromJson({'id': 5});

      expect(recipe.id, 5);
      expect(recipe.name, 'Sans nom');
      expect(recipe.nbOfPeople, 4);
      expect(recipe.ingredientWithQuantityIds, isEmpty);
    });

    test('toJson puis fromJson redonne un objet équivalent (round-trip)', () {
      const original = RawRecipe(
        id: 7,
        name: 'Quiche',
        preparationTime: '20min',
        cookingTime: '35min',
        nbOfPeople: 6,
        ingredientWithQuantityIds: [1, 2],
        steps: 'Préchauffer le four',
      );

      final json = original.toJson();
      final restored = RawRecipe.fromJson(json);

      expect(restored, equals(original));
    });
  });
}
