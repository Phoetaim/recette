// test/ui/ingredients_utils/widgets/ingredient_search_widget_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/data/repositories/ingredient/ingredient_repository.dart';
import 'package:recette/data/repositories/ingredient/ingredient_units_repository.dart';
import 'package:recette/domain/models/ingredient/ingredient.dart';
import 'package:recette/domain/models/ingredient/ingredient_types.dart';
import 'package:recette/domain/models/ingredient/ingredient_units.dart';
import 'package:recette/domain/models/ingredient/ingredient_with_quantity.dart';
import 'package:recette/ui/ingredients_utils/view_model/ingredients_utils_viewmodel.dart';
import 'package:recette/ui/ingredients_utils/widgets/ingredient_search_widget.dart';
import 'package:recette/utils/result.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockIngredientUnitsRepository extends Mock implements IngredientUnitsRepository {}

const legumeType = IngredientTypes(id: 3, name: 'Légume', color: 0xFF4CAF50);
const carotte = Ingredient(id: 1, name: 'carotte', type: legumeType);
const panais = Ingredient(id: 2, name: 'panais', type: legumeType);
const dLUnit = IngredientUnit(id: 10, name: 'dL');

void main() {
  late MockIngredientRepository mockIngredientRepository;
  late MockIngredientUnitsRepository mockIngredientUnitsRepository;
  late StreamController<Ingredient> newIngredientController;
  late StreamController<Ingredient> updateIngredientController;
  late StreamController<Ingredient> deleteIngredientController;

  setUpAll(() {
    registerFallbackValue(const Ingredient(name: 'fallback'));
  });

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
    mockIngredientUnitsRepository = MockIngredientUnitsRepository();
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
  });

  tearDown(() async {
    await newIngredientController.close();
    await updateIngredientController.close();
    await deleteIngredientController.close();
  });

  IngredientsUtilsViewModel createViewModel() {
    return IngredientsUtilsViewModel(
      ingredientRepository: mockIngredientRepository,
      ingredientUnitsRepository: mockIngredientUnitsRepository,
    );
  }

  void stubSuccessfulLoad({
    List<Ingredient> ingredients = const [],
    Map<String, IngredientUnit> unitsByName = const {},
  }) {
    when(
      () => mockIngredientUnitsRepository.loadIngredientUnits(),
    ).thenAnswer((_) async => const Result.ok(null));
    when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn(unitsByName);
    when(
      () => mockIngredientRepository.getIngredients(),
    ).thenAnswer((_) async => Result.ok(ingredients));
  }

  Future<void> pumpSearch(
    WidgetTester tester,
    IngredientsUtilsViewModel viewModel, {
    void Function(IngredientWithQuantity)? callback,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IngredientSearch(viewModel: viewModel, callbackForIngredient: callback ?? (_) {}),
        ),
      ),
    );
  }

  testWidgets('shows a loading indicator while ingredients are loading', (tester) async {
    final completer = Completer<Result<List<Ingredient>>>();
    when(
      () => mockIngredientUnitsRepository.loadIngredientUnits(),
    ).thenAnswer((_) async => const Result.ok(null));
    when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({});
    when(() => mockIngredientRepository.getIngredients()).thenAnswer((_) => completer.future);

    final viewModel = createViewModel();

    await pumpSearch(tester, viewModel);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Result.ok([]));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows an error message when loading ingredients fails', (tester) async {
    when(
      () => mockIngredientUnitsRepository.loadIngredientUnits(),
    ).thenAnswer((_) async => const Result.ok(null));
    when(() => mockIngredientUnitsRepository.ingredientUnitsByName).thenReturn({});
    when(
      () => mockIngredientRepository.getIngredients(),
    ).thenAnswer((_) async => Result.error(IngredientRepositoryError('db error')));

    final viewModel = createViewModel();

    await pumpSearch(tester, viewModel);
    await tester.pump();

    expect(find.text('RIP'), findsOneWidget);
  });

  testWidgets('shows the search bar once ingredients are loaded', (tester) async {
    stubSuccessfulLoad(ingredients: [carotte, panais], unitsByName: {'kg': dLUnit});
    final viewModel = createViewModel();

    await pumpSearch(tester, viewModel);
    await tester.pumpAndSettle();

    expect(find.text('3kg de patates, 2 navets,...'), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);
  });
  //
  // testWidgets('typing a query shows a matching suggestion, and tapping it invokes the '
  //     'callback then clears the field', (tester) async {
  //   stubSuccessfulLoad(ingredients: [carotte, panais], unitsByName: {'kg': dLUnit});
  //
  //   IngredientWithQuantity? received;
  //   final viewModel = createViewModel();
  //
  //   await pumpSearch(tester, viewModel, callback: (value) => received = value);
  //   await tester.pump();
  //
  //   await tester.tap(find.byType(SearchBar));
  //   await tester.pumpAndSettle();
  //
  //   await tester.enterText(find.byType(SearchBar), '2 kg de carotte');
  //   await tester.pumpAndSettle();
  //
  //   expect(find.text('carotte'), findsOneWidget);
  //
  //   await tester.tap(find.text('carotte'));
  //   await tester.pumpAndSettle();
  //
  //   expect(received, isNotNull);
  //   expect(received!.ingredient.name, 'carotte');
  //   expect(received!.quantity, 2);
  //   expect(received!.unit, dLUnit);
  // });
}
