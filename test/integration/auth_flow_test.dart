// test/integration/auth_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ Import your actual app files
import 'package:health_teen/main.dart' as app;
import 'package:health_teen/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('LOGIN Tests', () {
    setUp(() async {
      // Clean up test data
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // Ignore
      }
    });

    testWidgets('LOGIN-001: Successful login (Happy Path)', (tester) async {
      // Precondition: User has a valid account
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      // Step 1: Open the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 2: Enter valid email and password
      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');

      await tester.enterText(emailField, testEmail);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Step 3: Tap "Login"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Expected: Redirected to Home page
      expect(find.text('Health Teen'), findsWidgets);
      expect(find.textContaining('Good'), findsOneWidget);
    });

    testWidgets('LOGIN-002: Invalid password (Sad Path)', (tester) async {
      // Precondition: User has a valid email
      const testEmail = 'test@example.com';
      const wrongPassword = 'wrongpassword';

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 2: Enter valid email and wrong password
      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');

      await tester.enterText(emailField, testEmail);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await tester.enterText(passwordField, wrongPassword);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Step 3: Tap "Login"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Expected: User remains on Login page
      expect(find.text('Welcome back! 👋'), findsOneWidget);
    });

    testWidgets('LOGIN-003: Empty email or password (Sad Path)', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Leave fields blank and tap Login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Expected: Error message displayed
      expect(find.text('Please enter your email'), findsOneWidget);

      // Expected: Login not processed
      expect(find.text('Welcome back! 👋'), findsOneWidget);
    });

    testWidgets('LOGIN-008: Logout successfully (Happy Path)', (tester) async {
      // Precondition: User is logged in
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 1: Navigate to Profile
      final profileIcon = find.byIcon(Icons.person);
      await tester.tap(profileIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Scroll to Logout button
      await tester.dragUntilVisible(
        find.widgetWithText(OutlinedButton, 'Logout'),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 3: Tap Logout
      await tester.tap(find.widgetWithText(OutlinedButton, 'Logout'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 4: Confirm logout
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Expected: User redirected to Login page
      expect(find.text('Welcome back! 👋'), findsOneWidget);

      // Expected: Session cleared
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNull);
    });
  });

  group('HOME Tests', () {
    setUp(() async {
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // Ignore
      }
    });

    testWidgets('HOME-001: Add sleep data successfully (Happy Path)', (tester) async {
      // Precondition: Logged in as a user
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Precondition: User is on the Home page
      expect(find.text('Health Teen'), findsWidgets);

      // Step 1: Tap "Log Sleep"
      await tester.tap(find.text('Log Sleep').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 2: Enter "7 hours"
      final inputField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputField, '7');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Step 3: Click "Save"
      final saveButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Save'),
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Expected: Success message appears
      expect(find.textContaining('logged'), findsOneWidget);

      // Expected: Data stored in database
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final logs = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('healthLogs')
            .get();
        expect(logs.docs.isNotEmpty, true);
      }
    });

    testWidgets('HOME-003: Add meal data successfully (Happy Path)', (tester) async {
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 1: Tap "Log Meal"
      await tester.tap(find.text('Log Meal'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 2: Enter calories "350"
      final inputField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputField, '350');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Step 3: Click "Save"
      final saveButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Save'),
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Expected: Success message appears
      expect(find.textContaining('logged'), findsOneWidget);
    });
  });

  group('COMMUNITY Tests', () {
    setUp(() async {
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // Ignore
      }
    });

    testWidgets('COMM-001: Viewing the community feed successfully (Happy Path)', (tester) async {
      // Precondition: Logged in as a user
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step: Navigate to the Community tab
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expected: The system displays the latest posts
      expect(find.text('Community'), findsWidgets);
    });

    testWidgets('COMM-002: Creating a new post successfully (Happy Path)', (tester) async {
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 1: Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 2: Enter text
      final textField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(
        textField,
        'Feeling great after today\'s workout!',
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Step 3: Click "Post"
      final postButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Post'),
      );
      await tester.tap(postButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Expected: Success message appears
      expect(find.textContaining('created successfully'), findsOneWidget);
    });

    testWidgets('COMM-004: Liking a post successfully (Happy Path)', (tester) async {
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find first post's like button
      final likeButton = find.byIcon(Icons.favorite_border).first;
      
      if (likeButton.evaluate().isNotEmpty) {
        // Tap the "Like" button
        await tester.tap(likeButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Expected: Like button changes state
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('COMM-006: Commenting on a post successfully (Happy Path)', (tester) async {
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap "Comment" on first post
      final commentButton = find.byIcon(Icons.chat_bubble_outline).first;
      
      if (commentButton.evaluate().isNotEmpty) {
        await tester.tap(commentButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Enter comment text
        final commentField = find.byType(TextField).last;
        await tester.enterText(commentField, 'That\'s inspiring!');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Click "Send"
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Expected: Comment appears
        expect(find.text('That\'s inspiring!'), findsOneWidget);
      }
    });
  });

  group('PROFILE Tests', () {
    setUp(() async {
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // Ignore
      }
    });

    testWidgets('PROFILE-001: View profile details (Happy Path)', (tester) async {
      // Precondition: Logged in as a user
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 1: Tap "Profile" tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expected: System displays user's personal info
      expect(find.text('Profile'), findsWidgets);

      // Expected: Membership type visible
      expect(find.textContaining('Member'), findsOneWidget);

      // Expected: Health dashboard summary visible
      expect(find.text('Health Overview'), findsOneWidget);
    });

    testWidgets('PROFILE-004: View dashboard summary under Profile (Happy Path)', (tester) async {
      await _loginHelper(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 1: Tap "Profile" tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Scroll to "Health Overview"
      await tester.dragUntilVisible(
        find.text('Health Overview'),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Expected: System displays summarized data
      expect(find.text('Steps'), findsWidgets);
      expect(find.text('Sleep'), findsWidgets);
      expect(find.text('Calories'), findsWidgets);
    });
  });
}

// ==================== HELPER FUNCTION ====================

Future<void> _loginHelper(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Check if already logged in
  if (find.text('Health Teen').evaluate().length > 1) {
    return; // Already logged in
  }

  // Find and fill login fields
  final emailField = find.widgetWithText(TextFormField, 'Enter your email');
  final passwordField = find.widgetWithText(TextFormField, 'Enter your password');

  await tester.enterText(emailField, 'test@example.com');
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  
  await tester.enterText(passwordField, 'password123');
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // Tap login button
  await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Verify login success
  expect(find.textContaining('Good'), findsOneWidget);
}