import 'package:accountable/backend/app_state.dart';
import 'package:accountable/presentation/pages/transaction_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TransactionDetailScreen shows data and delete dialog',
      (WidgetTester tester) async {
    // Create a sample transaction
    final trans = Trans(
      transName: '7-Eleven',
      transactionDate: DateTime(2024, 4, 9, 13, 45),
      amount: 42.0,
      transType: TransactionType.food,
    );

    // Build the widget
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Placeholder(), // We'll replace this below
        ),
      ),
    );

    // Push the actual screen into the Navigator
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      CupertinoApp(
        navigatorKey: navKey,
        home: TransactionDetailScreen(transaction: trans),
      ),
    );

    // Wait for rendering
    await tester.pumpAndSettle();

    // ✅ Check if the amount and category are displayed
    expect(find.text('42.00'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
    expect(find.text('7-Eleven'), findsOneWidget);

    // ✅ Tap the delete button
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // ✅ Expect the confirmation dialog
    expect(find.text('Delete Transaction'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this transaction?'),
        findsOneWidget);

    // ✅ Tap cancel to close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // ✅ Dialog should be gone
    expect(find.text('Delete Transaction'), findsNothing);
  });
}
