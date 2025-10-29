// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ Import your main app
import 'package:health_teen/main.dart' as app;
import 'package:health_teen/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Health Teen App Tests', () {
    setUpAll(() async {
      // Initialize Firebase once
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    setUp(() async {
      // Sign out before each test
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // Ignore if not signed in
      }
    });

    // ==================== LOGIN TESTS ====================
    
    testWidgets('LOGIN-001: Successful login (Happy Path)', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ✅ FIX: Find fields by hint text instead of type
      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');

      // Verify fields exist
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      // Enter credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap Sign In button
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(signInButton, findsOneWidget);
      
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we're on home screen
      expect(find.text('Health Teen'), findsWidgets);
      expect(find.textContaining('Good'), findsOneWidget); // "Good Morning/Afternoon/Evening"
    });

    testWidgets('LOGIN-002: Invalid password (Sad Path)', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should still be on login screen
      expect(find.text('Welcome back! 👋'), findsOneWidget);
    });

    testWidgets('LOGIN-003: Empty fields validation (Sad Path)', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to tap Sign In without entering anything
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    // ==================== HOME TESTS ====================

    testWidgets('HOME-001: Add sleep data successfully (Happy Path)', (tester) async {
      // First login
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap "Log Sleep" button (in Quick Actions)
      final logSleepButton = find.text('Log Sleep');
      expect(logSleepButton, findsWidgets);
      
      await tester.tap(logSleepButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter sleep hours - find the dialog's TextField
      final inputField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(inputField, findsOneWidget);
      
      await tester.enterText(inputField, '7');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap Save button in dialog
      final saveButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Save'),
      );
      expect(saveButton, findsOneWidget);
      
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show success message
      expect(find.textContaining('logged'), findsOneWidget);
    });

    testWidgets('HOME-002: Add steps data successfully (Happy Path)', (tester) async {
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap "Log Steps" button
      final logStepsButton = find.text('Log Steps');
      expect(logStepsButton, findsOneWidget);
      
      await tester.tap(logStepsButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter steps
      final inputField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputField, '8000');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap Save
      final saveButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Save'),
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show success
      expect(find.textContaining('logged'), findsOneWidget);
    });

    testWidgets('HOME-003: Add meal data successfully (Happy Path)', (tester) async {
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap "Log Meal" button
      final logMealButton = find.text('Log Meal');
      expect(logMealButton, findsOneWidget);
      
      await tester.tap(logMealButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter calories
      final inputField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputField, '350');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap Save
      final saveButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Save'),
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show success
      expect(find.textContaining('logged'), findsOneWidget);
    });

    // ==================== COMMUNITY TESTS ====================

    testWidgets('COMM-001: View community feed (Happy Path)', (tester) async {
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Community tab by tapping the bottom nav icon
      final communityTab = find.byIcon(Icons.people);
      expect(communityTab, findsOneWidget);
      
      await tester.tap(communityTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on community screen
      expect(find.text('Community'), findsWidgets);
    });

    testWidgets('COMM-002: Create new post (Happy Path)', (tester) async {
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Community
      final communityTab = find.byIcon(Icons.people);
      await tester.tap(communityTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap FAB to create post
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      
      await tester.tap(fab);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter post content - find TextField in dialog
      final textField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(textField, findsOneWidget);
      
      await tester.enterText(textField, 'Feeling great today!');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap Post button in dialog
      final postButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Post'),
      );
      expect(postButton, findsOneWidget);
      
      await tester.tap(postButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see success message
      expect(find.textContaining('created successfully'), findsOneWidget);
    });

    testWidgets('COMM-003: Like a post (Happy Path)', (tester) async {
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Community
      final communityTab = find.byIcon(Icons.people);
      await tester.tap(communityTab);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find first like button (either favorite or favorite_border)
      final likeButton = find.byIcon(Icons.favorite_border).first;
      
      if (likeButton.evaluate().isNotEmpty) {
        await tester.tap(likeButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify like was registered (icon should change)
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    // ==================== PROFILE TESTS ====================

    testWidgets('PROFILE-001: View profile details (Happy Path)', (tester) async {
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Profile tab
      final profileTab = find.byIcon(Icons.person);
      expect(profileTab, findsOneWidget);
      
      await tester.tap(profileTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify profile content is visible
      expect(find.text('Profile'), findsWidgets);
      expect(find.textContaining('Member'), findsOneWidget);
      expect(find.text('Health Overview'), findsOneWidget);
    });

    testWidgets('LOGIN-008: Logout successfully (Happy Path)', (tester) async {
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Profile
      final profileTab = find.byIcon(Icons.person);
      await tester.tap(profileTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Scroll to find Logout button
      await tester.dragUntilVisible(
        find.widgetWithText(OutlinedButton, 'Logout'),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap Logout
      final logoutButton = find.widgetWithText(OutlinedButton, 'Logout');
      expect(logoutButton, findsOneWidget);
      
      await tester.tap(logoutButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Confirm logout in dialog
      final confirmButton = find.widgetWithText(ElevatedButton, 'Logout');
      expect(confirmButton, findsOneWidget);
      
      await tester.tap(confirmButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be back on login screen
      expect(find.text('Welcome back! 👋'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });
  });
}

// ==================== HELPER FUNCTIONS ====================

Future<void> _performLogin(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Check if already logged in by looking for home screen elements
  if (find.text('Health Teen').evaluate().length > 1) {
    // Already logged in (Health Teen appears multiple times on home)
    return;
  }

  // Find login fields
  final emailField = find.widgetWithText(TextFormField, 'Enter your email');
  final passwordField = find.widgetWithText(TextFormField, 'Enter your password');

  // Verify we're on login screen
  if (emailField.evaluate().isEmpty || passwordField.evaluate().isEmpty) {
    throw Exception('Not on login screen or fields not found');
  }

  // Enter credentials
  await tester.enterText(emailField, 'test@example.com');
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  
  await tester.enterText(passwordField, 'password123');
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // Tap Sign In
  final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
  expect(signInButton, findsOneWidget);
  
  await tester.tap(signInButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Verify login success by checking for home screen
  expect(find.textContaining('Good'), findsOneWidget);
}