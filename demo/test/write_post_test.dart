import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo/services/write_post.dart'; 
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:demo/providers/user_provider.dart'; 

// Mock classes
class MockUserProvider extends Mock implements UserProvider {}

void main() {
  group('WritePostPage Widget Tests', () {
    late MockUserProvider mockUserProvider;

    setUp(() async {

      mockUserProvider = MockUserProvider();
      when(mockUserProvider.user).thenReturn(null); 
    });

    Widget createTestWidget(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('Displays WritePostPage correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          WritePostPage(latitude: 45.0, longitude: -122.0),
        ),
      );

      expect(find.text('Write a Post'), findsOneWidget);

      expect(find.byType(TextField), findsNWidgets(3));

      expect(find.byType(DropdownButton<String>), findsNWidgets(2));
    });

    testWidgets('Shows error when required fields are empty on send',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          WritePostPage(latitude: 45.0, longitude: -122.0),
        ),
      );

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // Start the async operation

      expect(
          find.text('Please fill all required fields: your post content, phone number, and animal category'),
          findsOneWidget);
    });
  });
}
