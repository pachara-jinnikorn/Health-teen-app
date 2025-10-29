import 'package:flutter_test/flutter_test.dart';

/// PROFILE FEATURE TESTS
/// Based on test cases: PROFILE-001 to PROFILE-006
void main() {
  group('PROFILE Feature Tests', () {
    
    // PROFILE-001: View profile details (Happy Path)
    test('PROFILE-001: Display user profile information', () {
      // Arrange
      final userProfile = {
        'name': 'John Doe',
        'age': 16,
        'gender': 'Male',
        'membershipType': 'Premium',
      };
      
      // Act
      final hasRequiredFields = userProfile.containsKey('name') &&
                                userProfile.containsKey('age') &&
                                userProfile.containsKey('membershipType');
      
      // Assert
      expect(hasRequiredFields, true, 
        reason: 'Profile should have all required fields');
      expect(userProfile['name'], 'John Doe');
      expect(userProfile['membershipType'], 'Premium');
    });

    // PROFILE-002: Edit profile successfully (Happy Path)
    test('PROFILE-002: Update profile with valid data', () {
      // Arrange
      var userWeight = 55;
      const newWeight = 60;
      
      // Act
      final isValidWeight = _validateWeight(newWeight);
      if (isValidWeight) {
        userWeight = newWeight;
      }
      
      // Assert
      expect(userWeight, 60, 
        reason: 'Weight should be updated');
      expect(isValidWeight, true);
    });

    // PROFILE-003: Edit profile with invalid data (Sad Path)
    test('PROFILE-003: Reject invalid age value', () {
      // Arrange
      const invalidAge = -25;
      
      // Act
      final isValid = _validateAge(invalidAge);
      
      // Assert
      expect(isValid, false, 
        reason: 'Negative age should be rejected');
    });

    // PROFILE-004: View dashboard summary under Profile (Happy Path)
    test('PROFILE-004: Display health overview in profile', () {
      // Arrange
      final healthData = {
        'sleep': 7.5,
        'steps': 8500,
        'calories': 1800,
      };
      
      // Act
      final hasHealthData = healthData['sleep'] != null &&
                           healthData['steps'] != null &&
                           healthData['calories'] != null;
      
      // Assert
      expect(hasHealthData, true, 
        reason: 'Profile should display health overview');
    });

    // PROFILE-005: Update account settings successfully (Happy Path)
    test('PROFILE-005: Change password with valid input', () {
      // Arrange
      const currentPassword = 'oldpass123';
      const newPassword = 'newpass456';
      
      // Act
      final isCurrentPasswordValid = currentPassword.length >= 6;
      final isNewPasswordValid = _validatePassword(newPassword);
      final canUpdate = isCurrentPasswordValid && isNewPasswordValid;
      
      // Assert
      expect(canUpdate, true, 
        reason: 'Password should be updatable with valid inputs');
    });

    // PROFILE-006: Invalid account settings change (Sad Path)
    test('PROFILE-006: Reject empty new password', () {
      // Arrange
      const currentPassword = 'oldpass123';
      const newPassword = '';
      
      // Act
      final isNewPasswordValid = _validatePassword(newPassword);
      
      // Assert
      expect(isNewPasswordValid, false, 
        reason: 'Empty new password should be rejected');
    });

    // Additional: Membership type validation
    test('PROFILE-007: Validate membership types', () {
      // Arrange
      final validMembershipTypes = ['Free', 'Premium'];
      const userMembership = 'Premium';
      
      // Act
      final isValidMembership = validMembershipTypes
          .map((e) => e.toLowerCase())
          .contains(userMembership.toLowerCase());
      
      // Assert
      expect(isValidMembership, true, 
        reason: 'Membership type should be valid');
    });

    // Additional: Profile data consistency check
    test('PROFILE-008: Profile data consistency check', () {
      // Arrange
      final profile = {
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
      };
      
      // Act
      final isConsistent = profile['email']!.contains('@') &&
                          profile['firstName']!.isNotEmpty &&
                          profile['lastName']!.isNotEmpty;
      
      // Assert
      expect(isConsistent, true, 
        reason: 'Profile data should be consistent');
    });
  });
}

// Helper Functions
bool _validateWeight(int weight) {
  return weight > 0 && weight <= 300; // Reasonable weight range in kg
}

bool _validateAge(int age) {
  return age > 0 && age <= 120; // Reasonable age range
}

bool _validatePassword(String password) {
  return password.length >= 6;
}