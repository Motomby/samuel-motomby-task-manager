// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_application_1/main.dart';

void main() {
  testWidgets('App renders Task Manager screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaskManagerApp());

    // Verify that our app bar title 'Task Manager' is present.
    expect(find.text('Task Manager'), findsOneWidget);
    
    // Verify that one of our tasks is present.
    expect(find.text('Complete Flutter Assignment'), findsOneWidget);
  });
}
