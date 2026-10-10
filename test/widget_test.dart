// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preply/screens/Interview/interview_screen.dart';

void main() {
  testWidgets('InterviewScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InterviewScreen(),
      ),
    );

    expect(find.byType(InterviewScreen), findsOneWidget);
    expect(find.text('AI INTERVIEW COACH'), findsOneWidget);
    expect(find.text('Start Mock Interview'), findsOneWidget);
    expect(find.text('Your Recent Activity'), findsOneWidget);
  });
}
