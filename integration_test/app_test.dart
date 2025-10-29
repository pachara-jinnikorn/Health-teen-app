// integration_test/app_test.dart
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
      } catch (e) {
        // Ignore if not signed in
      }
    });

    // ==================== LOGIN TESTS ====================
    
    testWidgets('LOGIN-001: Successful login (Happy Path)', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find email and password fields
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Enter credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap Sign In button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we're on home screen
      expect(find.text('Health Teen'), findsOneWidget);
    });

    testWidgets('LOGIN-002: Invalid password (Sad Path)', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle();

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should still be on login screen
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('LOGIN-003: Empty fields validation (Sad Path)', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to tap Sign In without entering anything
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    // ==================== HOME TESTS ====================

    testWidgets('HOME-001: Add sleep data successfully (Happy Path)', (tester) async {
      // First login
      await _performLogin(tester);

      // Find and tap "Log Sleep" button
      final logSleepButton = find.text('Log Sleep');
      expect(logSleepButton, findsOneWidget);
      
      await tester.tap(logSleepButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter sleep hours
      final inputField = find.byType(TextField);
      await tester.enterText(inputField, '7');
      await tester.pumpAndSettle();

      // Tap Save
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show success message
      expect(find.textContaining('logged'), findsOneWidget);
    });

    testWidgets('HOME-003: Add meal data successfully (Happy Path)', (tester) async {
      await _performLogin(tester);

      // Tap "Log Meal" button
      final logMealButton = find.text('Log Meal');
      await tester.tap(logMealButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter calories
      final inputField = find.byType(TextField);
      await tester.enterText(inputField, '350');
      await tester.pumpAndSettle();

      // Tap Save
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show success
      expect(find.textContaining('logged'), findsOneWidget);
    });

    // ==================== COMMUNITY TESTS ====================

    testWidgets('COMM-001: View community feed (Happy Path)', (tester) async {
      await _performLogin(tester);

      // Navigate to Community tab
      final communityTab = find.text('Community');
      await tester.tap(communityTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on community screen
      expect(find.text('Community'), findsWidgets);
    });

    testWidgets('COMM-002: Create new post (Happy Path)', (tester) async {
      await _performLogin(tester);

      // Navigate to Community
      final communityTab = find.text('Community');
      await tester.tap(communityTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap FAB to create post
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter post content
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Feeling great today!');
      await tester.pumpAndSettle();

      // Tap Post button
      final postButton = find.text('Post');
      await tester.tap(postButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should see success message
      expect(find.textContaining('created successfully'), findsOneWidget);
    });

    // ==================== PROFILE TESTS ====================

    testWidgets('PROFILE-001: View profile details (Happy Path)', (tester) async {
      await _performLogin(tester);

      // Navigate to Profile tab
      final profileTab = find.text('Profile');
      await tester.tap(profileTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify profile content is visible
      expect(find.text('Profile'), findsOneWidget);
      expect(find.textContaining('Member'), findsOneWidget);
    });

    testWidgets('LOGIN-008: Logout successfully (Happy Path)', (tester) async {
      await _performLogin(tester);

      // Navigate to Profile
      final profileTab = find.text('Profile');
      await tester.tap(profileTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Scroll to find Logout button
      await tester.dragUntilVisible(
        find.text('Logout'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Tap Logout
      final logoutButton = find.text('Logout');
      await tester.tap(logoutButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Confirm logout in dialog
      final confirmButton = find.text('Logout').last;
      await tester.tap(confirmButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be back on login screen
      expect(find.text('Welcome back!'), findsOneWidget);
    });
  });
}

// ==================== HELPER FUNCTIONS ====================

Future<void> _performLogin(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Check if already logged in
  if (find.text('Health Teen').evaluate().isNotEmpty) {
    return; // Already logged in
  }

  // Enter credentials
  final emailField = find.byType(TextField).first;
  final passwordField = find.byType(TextField).last;

  await tester.enterText(emailField, 'test@example.com');
  await tester.enterText(passwordField, 'password123');
  await tester.pumpAndSettle();

  // Tap Sign In
  final signInButton = find.text('Sign In');
  await tester.tap(signInButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));
}