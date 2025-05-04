// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility in the
// flutter_test package.

// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodfit/app.dart';

void main() {
  testWidgets('MoodFit app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoodFitApp());

    // Verify that the app starts successfully
    expect(find.byType(MoodFitApp), findsOneWidget);

    // Additional test assertions can be added here as the app develops
  });
}
