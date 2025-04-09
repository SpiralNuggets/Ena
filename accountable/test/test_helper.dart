// test/test_helper.dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initTestDatabase() {
  // Initializes the ffi database for unit testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
