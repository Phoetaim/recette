// test/ui/recipe_detail/widgets/custom_number_input_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recette/domain/models/recipe/recipe.dart';
import 'package:recette/ui/recipe_detail/view_model/recipe_detail_viewmodel.dart';
import 'package:recette/ui/recipe_detail/widgets/add_recipe_to_shopping_list_widget.dart';

class MockRecipeDetailViewModel extends Mock implements RecipeDetailViewModel {}

void main() {
  late MockRecipeDetailViewModel mockViewModel;

  setUpAll(() {
    registerFallbackValue(const Recipe());
  });

  setUp(() {
    mockViewModel = MockRecipeDetailViewModel();
    when(() => mockViewModel.currentNumberOfPeople).thenReturn(ValueNotifier<int>(4));
  });

  Future<void> pumpAddRecipeToShoppingListWidget(
      WidgetTester tester, {
        required RecipeDetailViewModel viewModel,
        VoidCallback? callback,
        int minValue = 1,
        int maxValue = 50,
        int step = 1,
      }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddRecipeToShoppingListWidget(
            viewModel: viewModel,
            callback: callback ?? () {},
            minValue: minValue,
            maxValue: maxValue,
            step: step,
          ),
        ),
      ),
    );
  }

  group('AddRecipeToShoppingListWidget', () {
    group('Initialization', () {
      testWidgets('displays initial value from viewModel', (tester) async {
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(ValueNotifier<int>(4));

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        expect(find.text('4'), findsOneWidget);
      });

      testWidgets('renders all required widgets', (tester) async {
        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.group), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('renders text input field', (tester) async {
        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Increment button', () {
      testWidgets('increments value when pressed', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(notifier.value, 5);
      });

      testWidgets('respects step value', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          step: 2,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(notifier.value, 6);
      });

      testWidgets('does not exceed maxValue', (tester) async {
        final notifier = ValueNotifier<int>(49);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          maxValue: 50,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(notifier.value, 50);
      });

      testWidgets('is disabled at maxValue', (tester) async {
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(ValueNotifier<int>(50));

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          maxValue: 50,
        );
        await tester.pumpAndSettle();

        final addButton = find.byKey(Key('addButton'));
        expect(tester.widget<IconButton>(addButton).onPressed, isNull);
      });

      testWidgets('syncs text field when value incremented', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        expect(find.text('4'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('5'), findsOneWidget);
      });
    });

    group('Decrement button', () {
      testWidgets('decrements value when pressed', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(notifier.value, 3);
      });

      testWidgets('respects step value', (tester) async {
        final notifier = ValueNotifier<int>(6);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          step: 2,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(notifier.value, 4);
      });

      testWidgets('does not go below minValue', (tester) async {
        final notifier = ValueNotifier<int>(2);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          minValue: 1,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(notifier.value, 1);
      });

      testWidgets('is disabled at minValue', (tester) async {
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(ValueNotifier<int>(1));

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          minValue: 1,
        );
        await tester.pumpAndSettle();

        final removeButton = find.byKey(Key('removeButton'));
        expect(tester.widget<IconButton>(removeButton).onPressed, isNull);
      });

      testWidgets('syncs text field when value decremented', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        expect(find.text('4'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(find.text('3'), findsOneWidget);
      });
    });

    group('Text input', () {
      testWidgets('accepts valid numeric input within bounds', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), '8');
        await tester.pumpAndSettle();

        expect(notifier.value, 8);
      });

      testWidgets('ignores input below minValue', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          minValue: 2,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), '1');
        await tester.pumpAndSettle();

        expect(notifier.value, 4); // Unchanged
      });

      testWidgets('ignores input above maxValue', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          maxValue: 20,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), '50');
        await tester.pumpAndSettle();

        expect(notifier.value, 4); // Unchanged
      });

      testWidgets('validator accepts value in range', (tester) async {
        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          minValue: 1,
          maxValue: 50,
        );
        await tester.pumpAndSettle();

        final formField = find.byType(TextFormField);
        final state = tester.state<FormFieldState>(formField);

        expect(state.validate(), isTrue);
        expect(state.errorText, isNull);
      });

      testWidgets('validator rejects empty input', (tester) async {
        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        final formField = find.byType(TextFormField);
        final state = tester.state<FormFieldState>(formField);

        state.didChange('');
        expect(state.validate(), isFalse);
        expect(state.errorText, 'Enter a number');
      });

      testWidgets('validator rejects non-numeric input', (tester) async {
        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        final formField = find.byType(TextFormField);
        final state = tester.state<FormFieldState>(formField);

        state.didChange('abc');
        expect(state.validate(), isFalse);
        expect(state.errorText, 'Invalid number');
      });

      testWidgets('validator rejects value below minValue', (tester) async {
        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          minValue: 5,
          maxValue: 50,
        );
        await tester.pumpAndSettle();

        final formField = find.byType(TextFormField);
        final state = tester.state<FormFieldState>(formField);

        state.didChange('2');
        expect(state.validate(), isFalse);
        expect(state.errorText, contains('5'));
      });

      testWidgets('validator rejects value above maxValue', (tester) async {
        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          minValue: 1,
          maxValue: 20,
        );
        await tester.pumpAndSettle();

        final formField = find.byType(TextFormField);
        final state = tester.state<FormFieldState>(formField);

        state.didChange('50');
        expect(state.validate(), isFalse);
        expect(state.errorText, contains('20'));
      });

      testWidgets('ignores empty input', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        final initialValue = notifier.value;

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), '');
        await tester.pumpAndSettle();

        expect(notifier.value, initialValue); // Unchanged
      });

      testWidgets('only accepts digits', (tester) async {
        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        // Try to enter non-numeric characters
        await tester.enterText(find.byType(TextFormField), 'a1b2c3');
        await tester.pumpAndSettle();

        // Should only contain digits
        final textField = find.byType(TextFormField);
        final widget = tester.widget<TextFormField>(textField);
        expect(widget.controller?.text, matches(RegExp(r'^\d*$')));
      });
    });

    group('Shopping cart button', () {
      testWidgets('invokes callback when pressed', (tester) async {
        bool callbackInvoked = false;

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          callback: () => callbackInvoked = true,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.shopping_cart));
        await tester.pumpAndSettle();

        expect(callbackInvoked, isTrue);
      });

      testWidgets('displays tooltip', (tester) async {
        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        await tester.longPress(find.byIcon(Icons.shopping_cart));
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.text(
            'Adding ingredients to shopping list will automatically save the recipe.',
          ),
          findsOneWidget,
        );
      });
    });

    group('Integration tests', () {
      testWidgets('multiple increments accumulate', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(notifier.value, 7);
        expect(find.text('7'), findsOneWidget);
      });

      testWidgets('mixed increments and decrements', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(notifier.value, 5);
      });

      testWidgets('manual input followed by button increment', (tester) async {
        final notifier = ValueNotifier<int>(4);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(tester, viewModel: mockViewModel);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), '10');
        await tester.pumpAndSettle();

        expect(notifier.value, 10);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(notifier.value, 11);
      });

      testWidgets('respects custom min/max/step constraints', (tester) async {
        final notifier = ValueNotifier<int>(10);
        when(() => mockViewModel.currentNumberOfPeople).thenReturn(notifier);

        await pumpAddRecipeToShoppingListWidget(
          tester,
          viewModel: mockViewModel,
          minValue: 5,
          maxValue: 15,
          step: 3,
        );
        await tester.pumpAndSettle();

        // Increment by 3
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(notifier.value, 13);

        // At max constraint
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(notifier.value, 15);

        // Max button disabled
        // final addButton = find.byKey(Key('addButton'));
        // expect(tester.widget<IconButton>(addButton).onPressed, isNull);

        // Decrement by 9
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();
        expect(notifier.value, 6);

        // At min constraint
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();
        expect(notifier.value, 5);
      });
    });
  });
}