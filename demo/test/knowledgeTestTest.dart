import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/knowledgeTest.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('KnowledgeTestPage Widget Tests', () {
    testWidgets('renders all questions and radio options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const KnowledgeTestPage()));

      expect(find.text('Knowledge Test'), findsOneWidget);
      expect(find.text('1. Should we feed injured wildlife overnight?'), findsOneWidget);
      expect(find.text('2. Are owls raptors?'), findsOneWidget);
      expect(find.text('3. If I want to control a bird, should I cover its head with a cloth?'), findsOneWidget);
      expect(find.text('Yes'), findsNWidgets(3)); 
      expect(find.text('No'), findsNWidgets(3)); 
    });

    testWidgets('allows selecting answers for each question', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const KnowledgeTestPage()));

      await tester.tap(find.widgetWithText(RadioListTile, 'Yes').at(0));
      await tester.pump();


      await tester.tap(find.widgetWithText(RadioListTile, 'No').at(1));
      await tester.pump();

      await tester.tap(find.widgetWithText(RadioListTile, 'Yes').at(2));
      await tester.pump();

      expect(find.byWidgetPredicate((widget) {
        if (widget is RadioListTile<String>) {
          return widget.value == 'yes' && widget.groupValue == 'yes';
        }
        return false;
      }), findsNWidgets(2)); 

      expect(find.byWidgetPredicate((widget) {
        if (widget is RadioListTile<String>) {
          return widget.value == 'no' && widget.groupValue == 'no';
        }
        return false;
      }), findsNWidgets(1)); 
    });

    testWidgets('triggers the submit button and logs responses', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const KnowledgeTestPage()));

      await tester.tap(find.widgetWithText(RadioListTile, 'Yes').at(0)); 
      await tester.tap(find.widgetWithText(RadioListTile, 'No').at(1)); 
      await tester.tap(find.text('Submit')); 
      await tester.pump();

      expect(find.text('Submit'), findsOneWidget);
    });
  });
}
