import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accountable/presentation/pages/file_upload_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:accountable/services/ocr_service.dart';
import 'package:provider/provider.dart';
import 'package:accountable/backend/app_state.dart';

import 'test_helper.dart';

class MockOcrService extends Mock implements OcrService {}

void main() {
   initTestDatabase();
  testWidgets('UI renders and manual button works', (WidgetTester tester) async {
    final transList = TransList();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: transList,
        child: const CupertinoApp(
          home: FileUploadScreen(),
        ),
      ),
    );

    // Verify key UI elements
    expect(find.text('Upload E-Slip'), findsOneWidget);
    expect(find.text('SELECT FILE'), findsOneWidget);
    expect(find.text('Add a transaction manually'), findsOneWidget);

    // Tap the manual button
    await tester.tap(find.text('Add a transaction manually'));
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);
  });
}
