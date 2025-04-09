import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:accountable/backend/app_state.dart';
import 'package:accountable/presentation/pages/addTransaction.dart';

import 'test_helper.dart';

void main() {
   initTestDatabase();
  testWidgets('AddTransaction saves transaction with valid input',
      (WidgetTester tester) async {
    // Set up a mock provider
    final transList = TransList();

    await tester.pumpWidget(
      ChangeNotifierProvider<TransList>.value(
        value: transList,
        child: const CupertinoApp(
          home: AddTransaction(
            initialAmount: '100',
            initialNotes: 'Dinner',
          ),
        ),
      ),
    );

    // Tap to open category picker and select one
    await tester.tap(find.text('Select Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('food').first);
    await tester.pumpAndSettle();

    // Tap the save button
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    // Check if transaction was added
    expect(transList.transactions.length, 1);
    expect(transList.transactions.first.amount, 100);
    expect(transList.transactions.first.transName, 'Dinner');
  });
}
