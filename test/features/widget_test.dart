import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('🎯 PHASE 1: Basic Unit Tests (No Firebase)', () {
    
    test('TEST 1: Math operations work', () {
      expect(2 + 2, 4);
      expect(10 - 5, 5);
      expect(3 * 3, 9);
      print('✅ TEST 1 PASSED: Math works!');
    });

    test('TEST 2: String operations work', () {
      const email = 'test@example.com';
      expect(email.contains('@'), true);
      expect(email.contains('.com'), true);
      expect(email.split('@').length, 2);
      print('✅ TEST 2 PASSED: String operations work!');
    });

    test('TEST 3: Date formatting works', () {
      final date = DateTime(2025, 10, 29);
      final formatted = date.toIso8601String().split('T').first;
      expect(formatted, '2025-10-29');
      print('✅ TEST 3 PASSED: Date formatting works!');
    });

    test('TEST 4: List operations work', () {
      final numbers = [1, 2, 3, 4, 5];
      expect(numbers.length, 5);
      expect(numbers.first, 1);
      expect(numbers.last, 5);
      expect(numbers.contains(3), true);
      print('✅ TEST 4 PASSED: List operations work!');
    });

    test('TEST 5: Email validation logic', () {
      bool isValidEmail(String email) {
        return email.contains('@') && email.contains('.');
      }

      expect(isValidEmail('test@example.com'), true);
      expect(isValidEmail('invalid'), false);
      expect(isValidEmail('test@'), false);
      expect(isValidEmail('@example.com'), true); // Has @ and .
      print('✅ TEST 5 PASSED: Email validation works!');
    });

    test('TEST 6: Password validation logic', () {
      bool isValidPassword(String password) {
        return password.length >= 6;
      }

      expect(isValidPassword('password123'), true);
      expect(isValidPassword('pass'), false);
      expect(isValidPassword('12345'), false);
      expect(isValidPassword('123456'), true);
      print('✅ TEST 6 PASSED: Password validation works!');
    });

    test('TEST 7: Time ago calculation', () {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      final difference = now.difference(twoHoursAgo);

      expect(difference.inHours, 2);
      expect(difference.inMinutes, 120);
      print('✅ TEST 7 PASSED: Time calculation works!');
    });

    test('TEST 8: Map operations work', () {
      final userData = {
        'email': 'test@example.com',
        'name': 'John Doe',
        'age': 25,
      };

      expect(userData['email'], 'test@example.com');
      expect(userData.containsKey('name'), true);
      expect(userData['age'], 25);
      print('✅ TEST 8 PASSED: Map operations work!');
    });
  });

  group('🎯 PHASE 2: Widget Tests (No Firebase)', () {
    
    testWidgets('TEST 9: Simple button widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      print('✅ TEST 9 PASSED: Button widget works!');
    });

    testWidgets('TEST 10: TextField input works', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
          ),
        ),
      );

      // Find TextField and enter text
      await tester.enterText(find.byType(TextField), 'test@example.com');
      expect(controller.text, 'test@example.com');
      
      // Find hint text
      expect(find.text('Enter your email'), findsOneWidget);
      
      print('✅ TEST 10 PASSED: TextField works!');
    });

    testWidgets('TEST 11: Form validation works', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Try to validate empty field
      expect(formKey.currentState!.validate(), false);
      await tester.pump();

      // Should show error message
      expect(find.text('Please enter your email'), findsOneWidget);
      
      print('✅ TEST 11 PASSED: Form validation works!');
    });

    testWidgets('TEST 12: Password visibility toggle', (tester) async {
      bool obscureText = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextField(
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially password is hidden
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap the icon
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Now password should be visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      
      print('✅ TEST 12 PASSED: Password toggle works!');
    });

    testWidgets('TEST 13: List view with items', (tester) async {
      final items = ['Apple', 'Banana', 'Cherry'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                );
              },
            ),
          ),
        ),
      );

      // Check if all items are present
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
      
      print('✅ TEST 13 PASSED: ListView works!');
    });

    testWidgets('TEST 14: Navigation works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(
                          body: Center(
                            child: Text('Second Screen'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Next Screen'),
                );
              },
            ),
          ),
        ),
      );

      // Initially on first screen
      expect(find.text('Go to Next Screen'), findsOneWidget);

      // Tap button to navigate
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Now on second screen
      expect(find.text('Second Screen'), findsOneWidget);
      
      print('✅ TEST 14 PASSED: Navigation works!');
    });
  });

  group('🎯 PHASE 3: Health App Logic Tests', () {
    
    test('TEST 15: Calculate BMI', () {
      double calculateBMI(double weightKg, double heightM) {
        return weightKg / (heightM * heightM);
      }

      final bmi = calculateBMI(70, 1.75);
      expect(bmi.toStringAsFixed(1), '22.9');
      print('✅ TEST 15 PASSED: BMI calculation works!');
    });

    test('TEST 16: Calculate calories burned', () {
      int calculateCalories(int minutes, String activity) {
        final rates = {
          'running': 10,
          'walking': 5,
          'cycling': 8,
        };
        return minutes * (rates[activity] ?? 0);
      }

      expect(calculateCalories(30, 'running'), 300);
      expect(calculateCalories(60, 'walking'), 300);
      expect(calculateCalories(45, 'cycling'), 360);
      print('✅ TEST 16 PASSED: Calorie calculation works!');
    });

    test('TEST 17: Sleep quality assessment', () {
      String getSleepQuality(double hours) {
        if (hours >= 8) return 'Excellent';
        if (hours >= 7) return 'Good';
        if (hours >= 6) return 'Fair';
        return 'Poor';
      }

      expect(getSleepQuality(9), 'Excellent');
      expect(getSleepQuality(7.5), 'Good');
      expect(getSleepQuality(6.5), 'Fair');
      expect(getSleepQuality(5), 'Poor');
      print('✅ TEST 17 PASSED: Sleep quality works!');
    });

    test('TEST 18: Goal progress calculation', () {
      double getProgress(int current, int goal) {
        return (current / goal * 100).clamp(0, 100);
      }

      expect(getProgress(5000, 10000), 50.0);
      expect(getProgress(10000, 10000), 100.0);
      expect(getProgress(12000, 10000), 100.0); // Clamped
      print('✅ TEST 18 PASSED: Progress calculation works!');
    });

    test('TEST 19: Streak calculation', () {
      int calculateStreak(List<DateTime> dates) {
        if (dates.isEmpty) return 0;
        
        dates.sort((a, b) => b.compareTo(a)); // Latest first
        int streak = 1;
        
        for (int i = 1; i < dates.length; i++) {
          final diff = dates[i - 1].difference(dates[i]).inDays;
          if (diff == 1) {
            streak++;
          } else {
            break;
          }
        }
        return streak;
      }

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      
      expect(calculateStreak([today, yesterday, twoDaysAgo]), 3);
      print('✅ TEST 19 PASSED: Streak calculation works!');
    });

    test('TEST 20: Water intake recommendation', () {
      int getWaterIntake(double weightKg, int exerciseMinutes) {
        int base = (weightKg * 30).toInt(); // 30ml per kg
        int extra = (exerciseMinutes * 12).toInt(); // 12ml per minute
        return base + extra;
      }

      expect(getWaterIntake(70, 30), 2460); // 2100 + 360
      print('✅ TEST 20 PASSED: Water intake works!');
    });
  });
}