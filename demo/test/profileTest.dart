import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:demo/models/user_model.dart';
import 'package:demo/pages/login.dart'; // Import the login page

import '../lib/pages/profile.dart';
import '../lib/providers/user_provider.dart'; // Replace with actual path
import '../lib/pages/login.dart'; // Replace with actual path
import '../lib/pages/knowledgeTest.dart'; // Replace with actual path
import '../lib/pages/identification.dart'; // Replace with actual path

class MockUserProvider extends Mock implements UserProvider {}

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
  });

  Widget createTestWidget(Widget child) {
    return ChangeNotifierProvider<UserProvider>(
      create: (_) => mockUserProvider,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('ProfilePage Widget Tests', () {
    testWidgets('renders the ProfilePage with user data', (WidgetTester tester) async {
      when(mockUserProvider.user).thenReturn(
        UserModel(username: 'test_user', email: 'test@example.com', uid: '123'),
      );

      await tester.pumpWidget(createTestWidget(ProfilePage(theme: ThemeData())));

      expect(find.text('test_user'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('navigates to Knowledge Test page on tap', (WidgetTester tester) async {
      when(mockUserProvider.user).thenReturn(
        UserModel(username: 'test_user', email: 'test@example.com', uid: '123'),
      );

      await tester.pumpWidget(createTestWidget(ProfilePage(theme: ThemeData())));
      await tester.tap(find.text('Knowledge Test'));
      await tester.pumpAndSettle();

      expect(find.byType(KnowledgeTestPage), findsOneWidget);
    });

    testWidgets('navigates to Identification page on tap', (WidgetTester tester) async {
      when(mockUserProvider.user).thenReturn(
        UserModel(username: 'test_user', email: 'test@example.com', uid: '123'),
      );

      await tester.pumpWidget(createTestWidget(ProfilePage(theme: ThemeData())));
      await tester.tap(find.text('Volunteer/Professional Identification'));
      await tester.pumpAndSettle();

      expect(find.byType(IdentificationPage), findsOneWidget);
    });

    testWidgets('clears user data and navigates to Login page on Logoff', (WidgetTester tester) async {
      when(mockUserProvider.user).thenReturn(
        UserModel(username: 'test_user', email: 'test@example.com', uid: '123'),
      );

      await tester.pumpWidget(createTestWidget(ProfilePage(theme: ThemeData())));
      await tester.tap(find.text('Logoff'));
      await tester.pumpAndSettle();

      verify(mockUserProvider.clearLocalData()).called(1);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('shows edit UID dialog on username tap', (WidgetTester tester) async {
      when(mockUserProvider.user).thenReturn(
        UserModel(username: 'test_user', email: 'test@example.com', uid: '123'),
      );

      await tester.pumpWidget(createTestWidget(ProfilePage(theme: ThemeData())));
      await tester.tap(find.text('test_user'));
      await tester.pumpAndSettle();


      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Edit UID'), findsOneWidget);
    });
  });
}
