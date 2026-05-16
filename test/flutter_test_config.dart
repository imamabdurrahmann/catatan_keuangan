import 'dart:async';

/// Flutter test configuration — runs all test files serially to prevent
/// sqflite_ffi "database is locked" errors that occur when multiple test
/// files hold connections to the same singleton `.db` file simultaneously.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testMain();
}