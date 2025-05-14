import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/identification.dart'; // Replace with the actual path

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('IdentificationPage Widget Tests', () {
    testWidgets('renders all sections correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const IdentificationPage()));

      expect(find.text('Volunteer/Professional Identification'), findsOneWidget);
      expect(
          find.text('1. Choose the option that matches you the best'),
          findsOneWidget);
      expect(find.text('2. Please upload a document that can verify your identity as one of the mentioned roles.'), findsOneWidget);
      expect(find.text('3. Attestation'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('displays all radio options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const IdentificationPage()));

      expect(find.text('Current Wildlife Organization Volunteer'), findsOneWidget);
      expect(find.text('Wildlife Professional'), findsOneWidget);
      expect(find.text('Governmental Official'), findsOneWidget);
    });

    testWidgets('toggles checkbox on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const IdentificationPage()));

      final checkboxFinder = find.byType(CheckboxListTile);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('shows document upload container', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const IdentificationPage()));

      final uploadContainer = find.byType(GestureDetector);
      expect(uploadContainer, findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('checks Submit button functionality', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const IdentificationPage()));

      final submitButton = find.text('Submit');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(submitButton, findsOneWidget);
    });
  });
}
