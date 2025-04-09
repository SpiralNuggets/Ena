import 'package:accountable/presentation/pages/summary_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accountable/backend/app_state.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('BudgetSummaryScreen shows insights when data is available',
      (WidgetTester tester) async {
    // Create a fresh TransList instance
    final transList = TransList();

    // Wrap the screen with Provider and add transactions inside pumpWidget
    await tester.pumpWidget(
      ChangeNotifierProvider<TransList>.value(
        value: transList,
        child: const CupertinoApp(
          home: BudgetSummaryScreen(),
        ),
      ),
    );

    // Add transaction AFTER pumpWidget, but INSIDE the lifecycle
    transList.addTransaction(Trans(
      transName: '7-Eleven',
      transactionDate: DateTime.now(),
      amount: 50.0,
      transType: TransactionType.food,
    ));

    // Allow UI to rebuild
    await tester.pumpAndSettle();

    // Expect the Food category to be rendered with 50.0
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('50.00'), findsOneWidget);
  });
}
