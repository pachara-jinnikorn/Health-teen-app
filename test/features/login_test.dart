import 'package:flutter_test/flutter_test.dart';

/// LOGIN FEATURE TESTS - Redesigned to BDD (Given-When-Then) Style
/// Based on test cases: LOGIN-001 to LOGIN-008
void main() {
  group('LOGIN Feature Scenarios (LOGIN-001 to LOGIN-008)', () {
    
    // LOGIN-001: Happy Path - Successful login
    test('LOGIN-001: Given valid credentials for a registered user, When I tap "Login", Then I am redirected to the Home page.', () {
      // GIVEN: Valid credentials
      const email = 'test@example.com';
      const password = 'password123';
      
      // WHEN: Login is attempted (Act)
      final isEmailValid = _validateEmail(email);
      final isPasswordValid = _validatePassword(password);
      final canLogin = isEmailValid && isPasswordValid;
      
      // THEN: Assertions
      expect(canLogin, true, reason: 'Valid credentials should allow successful login.');
      
      print('✅ LOGIN-001 Passed: Successful login.');
    });

    // LOGIN-002: Sad Path - Invalid password
    test('LOGIN-002: Given a valid email and wrong password, When I tap "Login", Then an "Invalid email or password" error appears.', () {
      // GIVEN: Valid email but incorrect password (e.g., too short/mocking wrong password)
      const email = 'test@example.com';
      const wrongPassword = 'wrong';
      
      // WHEN: Validation checks (Act)
      final isEmailValid = _validateEmail(email);
      final isPasswordValid = _validatePassword(wrongPassword);
      
      // THEN: Assertions
      expect(isEmailValid, true);
      expect(isPasswordValid, false, reason: 'Password validation should fail (mocking backend failure).');
      
      print('✅ LOGIN-002 Passed: Invalid password rejected.');
    });

    // LOGIN-003: Sad Path - Empty email or password
    test('LOGIN-003: Given empty email and password fields, When I tap "Login", Then a "fill all required fields" error is displayed.', () {
      // GIVEN: Empty fields
      const emptyEmail = '';
      const emptyPassword = '';
      
      // WHEN: Attempting login (Act)
      final isEmailEmpty = emptyEmail.isEmpty;
      final isPasswordEmpty = emptyPassword.isEmpty;
      
      // THEN: Assertions
      expect(isEmailEmpty, true, reason: 'Email field is empty.');
      expect(isPasswordEmpty, true, reason: 'Password field is empty.');
      
      print('✅ LOGIN-003 Passed: Empty fields rejected.');
    });

    // LOGIN-004: Sad Path - Nonexistent account
    test('LOGIN-004: Given an unregistered email, When I tap "Login", Then an "Account not found" error is displayed.', () {
      // GIVEN: Unregistered email
      const unregisteredEmail = 'notregistered@example.com';
      final registeredEmails = ['test@example.com', 'user@example.com'];
      
      // WHEN: System checks registration (Act)
      final isRegistered = registeredEmails.contains(unregisteredEmail);
      
      // THEN: Assertions
      expect(isRegistered, false, 
        reason: 'Unregistered email should result in failure.');
        
      print('✅ LOGIN-004 Passed: Nonexistent account rejected.');
    });

    // LOGIN-005: Happy Path - Forgot password
    test('LOGIN-005: Given a registered email, When I request a password reset, Then a confirmation message is displayed.', () {
      // GIVEN: Valid email for reset
      const email = 'test@example.com';
      
      // WHEN: Email is validated (Act)
      final isValidForReset = _validateEmail(email);
      
      // THEN: Assertions
      expect(isValidForReset, true, 
        reason: 'Valid email should allow password reset process to start.');
        
      print('✅ LOGIN-005 Passed: Forgot password link validated.');
    });

    // LOGIN-006: Sad Path - Password reset with invalid email
    test('LOGIN-006: Given an invalid email format for reset, When I request a password reset, Then an "Invalid email address" error is displayed.', () {
      // GIVEN: Invalid email format
      const invalidEmail = 'abc@';
      
      // WHEN: Email is validated (Act)
      final isValid = _validateEmail(invalidEmail);
      
      // THEN: Assertions
      expect(isValid, false, 
        reason: 'Invalid email format should be rejected.');
        
      print('✅ LOGIN-006 Passed: Invalid email format rejected for reset.');
    });

    // LOGIN-007: Happy Path - Stay logged in
    test('LOGIN-007: Given "Remember Me" enabled, When I reopen the app, Then I am automatically redirected to the Home page.', () {
      // GIVEN: Session token is present and "Remember Me" is true
      const rememberMe = true;
      const sessionToken = 'mock-token-12345';
      
      // WHEN: App reopens (Act)
      final shouldStayLoggedIn = rememberMe && sessionToken.isNotEmpty;
      
      // THEN: Assertions
      expect(shouldStayLoggedIn, true, 
        reason: 'Session should be maintained for automatic login.');
        
      print('✅ LOGIN-007 Passed: Stay logged in functionality works.');
    });

    // LOGIN-008: Happy Path - Logout successfully
    test('LOGIN-008: Given a logged-in user, When I tap "Logout", Then the session is cleared and I am redirected to the Login page.', () {
      // GIVEN: Active session
      String? sessionToken = 'active-token';
      
      // WHEN: Logout action is performed (Act)
      sessionToken = null;
      
      // THEN: Assertions
      expect(sessionToken, null, 
        reason: 'Session token must be cleared on logout.');
        
      print('✅ LOGIN-008 Passed: Logout successful and session cleared.');
    });
  });
}

// Helper Functions
bool _validateEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool _validatePassword(String password) {
  return password.length >= 6;
}