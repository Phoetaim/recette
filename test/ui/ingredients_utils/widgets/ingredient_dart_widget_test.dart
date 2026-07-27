// test/ui/ingredients_utils/widgets/ingredient_type_widget_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/ui/ingredients_utils/view_model/ingredients_utils_viewmodel.dart';
import 'package:recette/ui/ingredients_utils/widgets/ingredient_type_widget.dart';
import 'package:recette/utils/result.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

const legumeType = IngredientTypes(id: 3, name: 'Légume', color: 0xFF4CAF50);
const fruitType = IngredientTypes(id: 4, name: 'Fruit', color: 0xFFFF9800);
const carotte = Ingredient(id: 1, name: 'carotte', type: legumeType);

void main() {
  late MockIngredientRepository mockIngredientRepository;
  late StreamController<Ingredient> newIngredientController;
  late StreamController<Ingredient> updateIngredientController;
  late StreamController<Ingredient> deleteIngredientController;

  setUpAll(() {
    registerFallbackValue(const Ingredient(name: 'fallback'));
  });

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
    newIngredientController = StreamController<Ingredient>.broadcast();
    updateIngredientController = StreamController<Ingredient>.broadcast();
    deleteIngredientController = StreamController<Ingredient>.broadcast();

    when(() => mockIngredientRepository.newIngredientStream).thenReturn(newIngredientController);
    when(
          () => mockIngredientRepository.updateIngredientStream,
    ).thenReturn(updateIngredientController);
    when(
          () => mockIngredientRepository.deleteIngredientStream,
    ).thenReturn(deleteIngredientController);
    when(
          () => mockIngredientRepository.getIngredients(),
    ).thenAnswer((_) async => const Result.ok([]));
    when(
          () => mockIngredientRepository.ingredientTypes,
    ).thenReturn({3: legumeType, 4: fruitType});
  });

  tearDown(() async {
    await newIngredientController.close();
    await updateIngredientController.close();
    await deleteIngredientController.close();
  });

  // No IngredientUnitsRepository needed: this widget only uses ingredientTypes
  // and updateIngredient, neither of which touches the search/unit machinery.
  IngredientsUtilsViewModel createViewModel() {
    return IngredientsUtilsViewModel(ingredientRepository: mockIngredientRepository);
  }

  Future<void> pumpWidgetUnderTest(WidgetTester tester, IngredientsUtilsViewModel viewModel) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: IngredientTypeWidget(ingredient: carotte, viewModel: viewModel)),
      ),
    );
  }

  testWidgets('shows a CircleAvatar with the ingredient type color', (tester) async {
    final viewModel = createViewModel();

    await pumpWidgetUnderTest(tester, viewModel);
    await tester.pump();

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, Color(legumeType.color));
  });

  testWidgets('long-pressing opens a menu listing every ingredient type', (tester) async {
    final viewModel = createViewModel();

    await pumpWidgetUnderTest(tester, viewModel);
    await tester.pump();

    await tester.longPress(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Légume'), findsOneWidget);
    expect(find.text('Fruit'), findsOneWidget);
  });

  testWidgets(
    'selecting a type in the menu calls updateIngredient with the ingredient copied '
        'to the new type',
        (tester) async {
      final viewModel = createViewModel();
      when(
            () => mockIngredientRepository.updateIngredient(carotte.copyWith(type: fruitType)),
      ).thenAnswer((_) async => const Result.ok(null));

      await pumpWidgetUnderTest(tester, viewModel);
      await tester.pump();

      await tester.longPress(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fruit'));
      await tester.pumpAndSettle();

      verify(
            () => mockIngredientRepository.updateIngredient(carotte.copyWith(type: fruitType)),
      ).called(1);
    },
  );

  testWidgets('does not call updateIngredient when the menu is dismissed without a choice', (
      tester,
      ) async {
    final viewModel = createViewModel();

    await pumpWidgetUnderTest(tester, viewModel);
    await tester.pump();

    await tester.longPress(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    // Tapping the scrim outside the menu dismisses it without returning a value.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    verifyNever(() => mockIngredientRepository.updateIngredient(any()));
  });
}