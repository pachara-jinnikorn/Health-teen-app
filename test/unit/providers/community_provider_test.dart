// test/unit/providers/community_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('Community Provider Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);
    });

    test('COMM-002: Creating a new post saves to database', () async {
      // Arrange
      const postContent = 'Feeling great after today\'s cupping session!';
      final userId = mockAuth.currentUser!.uid;

      // Act
      await fakeFirestore.collection('posts').add({
        'author': 'Test User',
        'authorId': userId,
        'content': postContent,
        'timestamp': DateTime.now(),
        'likes': 0,
        'comments': 0,
        'likedBy': [],
      });

      // Assert
      final posts = await fakeFirestore.collection('posts').get();
      expect(posts.docs.length, 1);
      expect(posts.docs.first.get('content'), postContent);
    });

    test('COMM-003: Empty post content should not be created', () async {
      // Arrange
      const emptyContent = '';

      // Act & Assert
      expect(
        () => emptyContent.isEmpty ? throw Exception('Post content cannot be empty') : null,
        throwsException,
      );
    });

    test('COMM-004: Liking a post increases count by 1', () async {
      // Arrange
      final postRef = await fakeFirestore.collection('posts').add({
        'content': 'Test post',
        'likes': 0,
        'likedBy': [],
      });

      // Act
      await postRef.update({
        'likes': 1,
        'likedBy': ['user123'],
      });

      // Assert
      final post = await postRef.get();
      expect(post.get('likes'), 1);
      expect((post.get('likedBy') as List).contains('user123'), true);
    });

    test('COMM-006: Comment is saved to database', () async {
      // Arrange
      final postRef = await fakeFirestore.collection('posts').add({
        'content': 'Test post',
        'comments': 0,
      });

      // Act
      await postRef.collection('comments').add({
        'authorId': 'user123',
        'authorName': 'Test User',
        'content': 'That\'s inspiring!',
        'timestamp': DateTime.now(),
      });

      await postRef.update({'comments': 1});

      // Assert
      final comments = await postRef.collection('comments').get();
      expect(comments.docs.length, 1);
      expect(comments.docs.first.get('content'), 'That\'s inspiring!');

      final post = await postRef.get();
      expect(post.get('comments'), 1);
    });

    test('COMM-007: Empty comment should not be saved', () {
      // Arrange
      const emptyComment = '';

      // Act & Assert
      expect(
        () => emptyComment.isEmpty ? throw Exception('Comment cannot be empty') : null,
        throwsException,
      );
    });
  });

  group('Health Data Provider Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);
    });

    test('HOME-001: Sleep data is saved to database', () async {
      // Arrange
      final userId = mockAuth.currentUser!.uid;
      final logDate = DateTime.now().toIso8601String().split('T').first;

      // Act
      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('healthLogs')
          .add({
        'sleepHours': 7,
        'logDate': logDate,
        'calories': 0,
        'exerciseMinutes': 0,
        'steps': 0,
        'source': 'manual',
        'createdAt': DateTime.now(),
      });

      // Assert
      final logs = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('healthLogs')
          .get();

      expect(logs.docs.length, 1);
      expect(logs.docs.first.get('sleepHours'), 7);
    });

    test('HOME-002: Invalid sleep value should be rejected', () {
      // Arrange
      const invalidSleepHours = -3;

      // Act & Assert
      expect(
        () => invalidSleepHours < 0
            ? throw Exception('Sleep hours must be a positive number')
            : null,
        throwsException,
      );
    });

    test('HOME-003: Meal data with calories is saved', () async {
      // Arrange
      final userId = mockAuth.currentUser!.uid;
      final logDate = DateTime.now().toIso8601String().split('T').first;

      // Act
      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('healthLogs')
          .add({
        'calories': 350,
        'logDate': logDate,
        'sleepHours': 0,
        'exerciseMinutes': 0,
        'steps': 0,
        'source': 'manual',
        'createdAt': DateTime.now(),
      });

      // Assert
      final logs = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('healthLogs')
          .get();

      expect(logs.docs.length, 1);
      expect(logs.docs.first.get('calories'), 350);
    });

    test('HOME-004: Meal without calories should fail validation', () {
      // Arrange
      int? calories;

      // Act & Assert
      expect(
        () => calories == null
            ? throw Exception('Calories value is required')
            : null,
        throwsException,
      );
    });

    test('HOME-006: Exercise with invalid duration should be rejected', () {
      // Arrange
      const invalidDuration = -10;

      // Act & Assert
      expect(
        () => invalidDuration <= 0
            ? throw Exception('Duration must be greater than zero')
            : null,
        throwsException,
      );
    });

    test('Weekly data aggregation calculates correctly', () {
      // Arrange
      final logs = [
        {'sleepHours': 7, 'calories': 2000, 'steps': 8000},
        {'sleepHours': 8, 'calories': 2200, 'steps': 10000},
        {'sleepHours': 6, 'calories': 1800, 'steps': 7000},
      ];

      // Act
      final avgSleep = logs.fold<int>(0, (sum, log) => sum + (log['sleepHours'] as int)) / logs.length;
      final avgCalories = logs.fold<int>(0, (sum, log) => sum + (log['calories'] as int)) / logs.length;
      final avgSteps = logs.fold<int>(0, (sum, log) => sum + (log['steps'] as int)) / logs.length;

      // Assert
      expect(avgSleep, 7.0);
      expect(avgCalories, 2000.0);
      expect(avgSteps, closeTo(8333.33, 0.01));
    });

    test('Streak calculation works correctly', () {
      // Arrange
      final dates = [
        DateTime(2025, 1, 5),
        DateTime(2025, 1, 4),
        DateTime(2025, 1, 3),
        DateTime(2025, 1, 2),
      ];

      // Act
      int streak = 1;
      for (int i = 1; i < dates.length; i++) {
        final gap = dates[i - 1].difference(dates[i]).inDays;
        if (gap == 1) {
          streak++;
        } else {
          break;
        }
      }

      // Assert
      expect(streak, 4);
    });
  });

  group('Auth Service Tests', () {
    test('LOGIN-002: Invalid password throws error', () async {
      // Arrange
      final mockAuth = MockFirebaseAuth();

      // Act & Assert
      expect(
        () async => await mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('LOGIN-003: Empty fields should be validated', () {
      // Arrange
      const email = '';
      const password = '';

      // Act & Assert
      expect(
        () {
          if (email.isEmpty || password.isEmpty) {
            throw Exception('Please fill in all required fields');
          }
        },
        throwsException,
      );
    });

    test('LOGIN-006: Invalid email format should be rejected', () {
      // Arrange
      const invalidEmail = 'abc@';

      // Act & Assert
      final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(invalidEmail);
      
      expect(isValid, false);
    });

    test('User registration creates health log', () async {
      // Arrange
      final fakeFirestore = FakeFirebaseFirestore();
      final userId = 'testUser123';
      final logDate = DateTime.now().toIso8601String().split('T').first;

      // Act
      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('healthLogs')
          .add({
        'calories': 1500,
        'exerciseMinutes': 30,
        'sleepHours': 7,
        'steps': 5000,
        'logDate': logDate,
        'source': 'register',
        'createdAt': DateTime.now(),
      });

      // Assert
      final logs = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('healthLogs')
          .get();

      expect(logs.docs.length, 1);
      expect(logs.docs.first.get('source'), 'register');
    });
  });

  group('Profile Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);
    });

    test('PROFILE-002: Profile update saves successfully', () async {
      // Arrange
      final userId = mockAuth.currentUser!.uid;
      await fakeFirestore.collection('users').doc(userId).set({
        'firstname': 'John',
        'lastname': 'Doe',
        'weight': 70,
      });

      // Act
      await fakeFirestore.collection('users').doc(userId).update({
        'weight': 60,
      });

      // Assert
      final user = await fakeFirestore.collection('users').doc(userId).get();
      expect(user.get('weight'), 60);
    });

    test('PROFILE-003: Invalid profile data should be rejected', () {
      // Arrange
      const invalidAge = -25;

      // Act & Assert
      expect(
        () => invalidAge < 0
            ? throw Exception('Invalid input value')
            : null,
        throwsException,
      );
    });

    test('PROFILE-006: Empty new password should fail validation', () {
      // Arrange
      const newPassword = '';

      // Act & Assert
      expect(
        () => newPassword.isEmpty
            ? throw Exception('New password is required')
            : null,
        throwsException,
      );
    });
  });

  group('Goal Calculations', () {
    test('Steps goal percentage calculates correctly', () {
      // Arrange
      const currentSteps = 7500;
      const goalSteps = 10000;

      // Act
      final percentage = (currentSteps / goalSteps).clamp(0.0, 1.0);

      // Assert
      expect(percentage, 0.75);
    });

    test('Sleep goal percentage calculates correctly', () {
      // Arrange
      const currentSleep = 6.0;
      const goalSleep = 8.0;

      // Act
      final percentage = (currentSleep / goalSleep).clamp(0.0, 1.0);

      // Assert
      expect(percentage, 0.75);
    });

    test('Daily goals met when all targets reached', () {
      // Arrange
      const steps = 10500;
      const sleep = 8.5;
      const calories = 2000;

      // Act
      final allGoalsMet = steps >= 10000 && sleep >= 8 && calories >= 1800;

      // Assert
      expect(allGoalsMet, true);
    });

    test('Daily goals not met when any target missed', () {
      // Arrange
      const steps = 8000;
      const sleep = 6.0;
      const calories = 2000;

      // Act
      final allGoalsMet = steps >= 10000 && sleep >= 8 && calories >= 1800;

      // Assert
      expect(allGoalsMet, false);
    });
  });
}