import 'package:accountable/presentation/pages/summary_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:accountable/backend/app_state.dart';

import 'test_helper.dart';


void main() {
   initTestDatabase();
  testWidgets('BudgetSummaryScreen shows message when no data', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TransList(),
        child: const CupertinoApp(
          home: BudgetSummaryScreen(),
        ),
      ),
    );

    expect(find.text('Budget Summary'), findsOneWidget);
    expect(find.text('No transaction data available for summary.'), findsOneWidget);
  });

  testWidgets('BudgetSummaryScreen shows insights when data is available', (WidgetTester tester) async {
    final transList = TransList();

    transList.addTransaction(
      Trans(
        transName: 'Burger King',
        transactionDate: DateTime.now(),
        amount: 120.0,
        transType: TransactionType.food,
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: transList,
        child: const CupertinoApp(
          home: BudgetSummaryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('food'), findsOneWidget);
    expect(find.text('120.00'), findsOneWidget);
  });
}
