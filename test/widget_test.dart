// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracker/main.dart';
// import 'package:expense_tracker/screens/auth_screen.dart';
// import 'package:expense_tracker/screens/dashboard_screen.dart';
// import 'package:expense_tracker/services/db_service.dart';
// import 'package:expense_tracker/models/user_model.dart';

// // Create a mock class for DBService
// class MockDBService extends Mock implements DBService {}

// void main() {
//   testWidgets('AuthScreen login and DashboardScreen test', (WidgetTester tester) async {
//     // Create a mock DBService
//     final mockDBService = MockDBService();

//     // Define the behavior of the mock DBService
//     when(mockDBService.isLoggedIn()).thenAnswer((_) async => false);
//     when(mockDBService.authenticateUser(any, any)).thenAnswer((_) async => true);
//     when(mockDBService.getUserIdByUsername(any)).thenAnswer((_) async => 1);

//     // Build our app with the mock DBService
//     await tester.pumpWidget(
//       MaterialApp(
//         home: ChangeNotifierProvider<DBService>.value(
//           value: mockDBService,
//           child: AuthScreen(),
//         ),
//       ),
//     );

//     // Verify that AuthScreen is displayed initially
//     expect(find.text('Login'), findsOneWidget);
//     expect(find.text('Register'), findsNothing);

//     // Input fields and buttons
//     final usernameField = find.byType(TextField).at(0);
//     final passwordField = find.byType(TextField).at(1);
//     final loginButton = find.text('Login');

//     // Enter username and password
//     await tester.enterText(usernameField, 'testuser');
//     await tester.enterText(passwordField, 'password');

//     // Simulate button press
//     await tester.tap(loginButton);
//     await tester.pump(); // Trigger a frame

//     // Verify that DashboardScreen is displayed
//     expect(find.text('Dashboard'), findsOneWidget);
//   });
// }
