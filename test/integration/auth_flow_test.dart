// test/integration/auth_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ Import your actual app files
import 'package:health_teen/main.dart' as app;
import 'package:health_teen/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LOGIN Tests', () {
    setUp(() async {
      await Firebase.initializeApp();
      // Clean up test data
      await FirebaseAuth.instance.signOut();
    });

    testWidgets('LOGIN-001: Successful login (Happy Path)', (tester) async {
      // Precondition: User has a valid account
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      // Step 1: Open the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Step 2: Enter valid email and password
      await tester.enterText(
        find.byType(TextFormField).at(0),
        testEmail,
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        testPassword,
      );

      // Step 3: Tap "Login"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Expected: Redirected to Home page
      expect(find.text('Health Teen'), findsOneWidget);
      expect(find.text('Good Morning'), findsOneWidget);

      // Expected: Message "Login successful" displayed
      expect(find.text('Login successful'), findsOneWidget);
    });

    testWidgets('LOGIN-002: Invalid password (Sad Path)', (tester) async {
      // Precondition: User has a valid email
      const testEmail = 'test@example.com';
      const wrongPassword = 'wrongpassword';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Step 2: Enter valid email and wrong password
      await tester.enterText(find.byType(TextFormField).at(0), testEmail);
      await tester.enterText(find.byType(TextFormField).at(1), wrongPassword);

      // Step 3: Tap "Login"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expected: Error message appears
      expect(
        find.textContaining('Invalid email or password'),
        findsOneWidget,
      );

      // Expected: User remains on Login page
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('LOGIN-003: Empty email or password (Sad Path)', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Step 1: Leave fields blank and tap Login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Expected: Error message displayed
      expect(
        find.text('Please enter your email'),
        findsOneWidget,
      );

      // Expected: Login not processed
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('LOGIN-004: Nonexistent account (Sad Path)', (tester) async {
      const unregisteredEmail = 'nonexistent@example.com';
      const anyPassword = 'password123';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), unregisteredEmail);
      await tester.enterText(find.byType(TextFormField).at(1), anyPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expected: Error "Account not found" displayed
      expect(find.textContaining('Account not found'), findsOneWidget);

      // Expected: Prompt to "Sign up" shown
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('LOGIN-008: Logout successfully (Happy Path)', (tester) async {
      // Precondition: User is logged in
      await _loginHelper(tester);

      // Step 1: Tap "Logout" button in Profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.widgetWithText(OutlinedButton, 'Logout'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      
      await tester.tap(find.widgetWithText(OutlinedButton, 'Logout'));
      await tester.pumpAndSettle();

      // Step 2: Confirm logout
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expected: User redirected to Login page
      expect(find.text('Welcome back!'), findsOneWidget);

      // Expected: Session cleared
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNull);
    });
  });

  group('HOME Tests', () {
    setUp(() async {
      await Firebase.initializeApp();
      await FirebaseAuth.instance.signOut();
    });

    testWidgets('HOME-001: Add sleep data successfully (Happy Path)', (tester) async {
      // Precondition: Logged in as a user
      await _loginHelper(tester);

      // Precondition: User is on the Home page
      expect(find.text('Health Teen'), findsOneWidget);

      // Step 1: Tap "Add Sleep" (using quick action or health card)
      await tester.tap(find.text('Log Sleep'));
      await tester.pumpAndSettle();

      // Step 2: Enter "7 hours"
      await tester.enterText(find.byType(TextField), '7');

      // Step 3: Click "Save"
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expected: Success message appears
      expect(find.text('sleep logged to database! ✅'), findsOneWidget);

      // Expected: Quick Snapshot updates
      expect(find.text('7.0h'), findsOneWidget);

      // Expected: Data stored in database
      final user = FirebaseAuth.instance.currentUser;
      final logs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('healthLogs')
          .get();
      expect(logs.docs.isNotEmpty, true);
    });

    testWidgets('HOME-002: Add sleep data with invalid value (Sad Path)', (tester) async {
      await _loginHelper(tester);

      await tester.tap(find.text('Log Sleep'));
      await tester.pumpAndSettle();

      // Step 2: Enter "-3"
      await tester.enterText(find.byType(TextField), '-3');

      // Step 3: Click "Save"
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Expected: Error message appears
      expect(find.textContaining('must be'), findsOneWidget);

      // Expected: Data not saved
      expect(find.text('-3.0h'), findsNothing);
    });

    testWidgets('HOME-003: Add meal data successfully (Happy Path)', (tester) async {
      await _loginHelper(tester);

      // Step 1: Tap "Add Meal"
      await tester.tap(find.text('Log Meal'));
      await tester.pumpAndSettle();

      // Step 2: Enter calories "350"
      await tester.enterText(find.byType(TextField), '350');

      // Step 3: Click "Save"
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expected: Success message appears
      expect(find.textContaining('logged to database'), findsOneWidget);

      // Expected: Quick Snapshot updates
      expect(find.text('350'), findsWidgets);
    });

    testWidgets('HOME-006: Add exercise with invalid input (Sad Path)', (tester) async {
      await _loginHelper(tester);

      await tester.tap(find.text('Log Steps'));
      await tester.pumpAndSettle();

      // Step 2: Enter "-10"
      await tester.enterText(find.byType(TextField), '-10');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Expected: Error message appears (validation or save failure)
      expect(find.textContaining('Failed'), findsAny);
    });
  });

  group('COMMUNITY Tests', () {
    testWidgets('COMM-001: Viewing the community feed successfully (Happy Path)', (tester) async {
      // Precondition: Logged in as a user
      await _loginHelper(tester);

      // Step: Navigate to the Community tab
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();

      // Expected: The system displays the latest posts
      expect(find.text('Community'), findsOneWidget);

      // Expected: Posts appear (if any exist)
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('COMM-002: Creating a new post successfully (Happy Path)', (tester) async {
      await _loginHelper(tester);

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();

      // Step 1: Tap "+ New Post"
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Step 2: Enter text
      await tester.enterText(
        find.byType(TextField),
        'Feeling great after today\'s cupping session!',
      );

      // Step 3: Click "Post"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Post'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expected: Success message appears
      expect(find.text('Post created successfully! 🎉'), findsOneWidget);

      // Expected: New post appears at the top
      expect(
        find.text('Feeling great after today\'s cupping session!'),
        findsOneWidget,
      );
    });

    testWidgets('COMM-003: Attempt to create post with empty text (Sad Path)', (tester) async {
      await _loginHelper(tester);

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Step 2: Leave text field blank
      // Step 3: Click "Post"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Post'));
      await tester.pumpAndSettle();

      // Expected: Post is not created (button might be disabled or validation)
      expect(find.text('Post created successfully'), findsNothing);
    });

    testWidgets('COMM-004: Liking a post successfully (Happy Path)', (tester) async {
      await _loginHelper(tester);

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find first post and get initial like count
      final likeButton = find.byIcon(Icons.favorite_border).first;
      
      if (find.byIcon(Icons.favorite_border).evaluate().isNotEmpty) {
        // Tap the "Like" button
        await tester.tap(likeButton);
        await tester.pumpAndSettle();

        // Expected: Like button changes state
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      }
    });

    testWidgets('COMM-006: Commenting on a post successfully (Happy Path)', (tester) async {
      await _loginHelper(tester);

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap "Comment" on first post
      final commentButton = find.byIcon(Icons.chat_bubble_outline).first;
      
      if (commentButton.evaluate().isNotEmpty) {
        await tester.tap(commentButton);
        await tester.pumpAndSettle();

        // Enter comment text
        await tester.enterText(
          find.byType(TextField),
          'That\'s inspiring!',
        );

        // Click "Send"
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Expected: Comment appears
        expect(find.text('That\'s inspiring!'), findsOneWidget);
      }
    });

    testWidgets('COMM-007: Attempt to comment with empty text (Sad Path)', (tester) async {
      await _loginHelper(tester);

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final commentButton = find.byIcon(Icons.chat_bubble_outline).first;
      
      if (commentButton.evaluate().isNotEmpty) {
        await tester.tap(commentButton);
        await tester.pumpAndSettle();

        // Leave comment field blank and tap send
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Expected: Comment not saved (send button might be disabled)
        expect(find.text('Comment deleted'), findsNothing);
      }
    });
  });

  group('PROFILE Tests', () {
    testWidgets('PROFILE-001: View profile details (Happy Path)', (tester) async {
      // Precondition: Logged in as a user
      await _loginHelper(tester);

      // Step 1: Tap "Profile" tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Expected: System displays user's personal info
      expect(find.text('Profile'), findsOneWidget);

      // Expected: Membership type visible
      expect(find.textContaining('Member'), findsOneWidget);

      // Expected: Health dashboard summary visible
      expect(find.text('Health Overview'), findsOneWidget);
    });

    testWidgets('PROFILE-004: View dashboard summary under Profile (Happy Path)', (tester) async {
      await _loginHelper(tester);

      // Step 1: Tap "Profile" tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Step 2: Scroll to "Health Overview"
      await tester.dragUntilVisible(
        find.text('Health Overview'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );

      // Expected: System displays summarized data
      expect(find.text('Steps'), findsWidgets);
      expect(find.text('Sleep'), findsWidgets);
      expect(find.text('Calories'), findsWidgets);
    });
  });
}

// Helper function for login
Future<void> _loginHelper(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  // Enter credentials
  await tester.enterText(
    find.byType(TextFormField).at(0),
    'test@example.com',
  );
  await tester.enterText(
    find.byType(TextFormField).at(1),
    'password123',
  );

  // Tap login
  await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
  await tester.pumpAndSettle(const Duration(seconds: 3));
}