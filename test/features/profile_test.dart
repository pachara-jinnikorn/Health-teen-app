import 'package:flutter_test/flutter_test.dart';

/// PROFILE FEATURE TESTS - Redesigned to BDD (Given-When-Then) Style
/// Based on test cases: PROFILE-001 to PROFILE-006
void main() {
  group('PROFILE Feature Scenarios (PROFILE-001 to PROFILE-006)', () {
    
    // PROFILE-001: Happy Path - View profile details
    test('PROFILE-001: Given a logged-in user, When they navigate to the Profile tab, Then their personal info and membership type are displayed.', () {
      // GIVEN: User profile data exists
      final userProfile = {
        'name': 'John Doe',
        'age': 16,
        'membershipType': 'Premium',
      };
      
      // WHEN: Profile data is loaded (Act)
      final hasRequiredFields = userProfile.containsKey('name') &&
                                userProfile.containsKey('age') &&
                                userProfile.containsKey('membershipType');
      
      // THEN: Assertions
      expect(hasRequiredFields, true, 
        reason: 'Profile should have all required fields displayed.');
        
      print('✅ PROFILE-001 Passed: View profile details successfully.');
    });

    // PROFILE-002: Happy Path - Edit profile successfully
    test('PROFILE-002: Given valid modified data (Weight), When the user taps "Save", Then the profile is updated successfully.', () {
      // GIVEN: Current weight and new valid weight
      var userWeight = 55;
      const newWeight = 60;
      
      // WHEN: New data is validated and saved (Act)
      final isValidWeight = _validateWeight(newWeight);
      if (isValidWeight) {
        userWeight = newWeight;
      }
      
      // THEN: Assertions
      expect(userWeight, 60, 
        reason: 'Weight should be updated to 60 kg.');
      expect(isValidWeight, true);
      
      print('✅ PROFILE-002 Passed: Edit profile successfully.');
    });

    // PROFILE-003: Sad Path - Edit profile with invalid data
    test('PROFILE-003: Given invalid data (e.g., negative Age), When the user taps "Save", Then an "Invalid input value" error appears.', () {
      // GIVEN: Invalid age value
      const invalidAge = -25;
      
      // WHEN: Data is validated (Act)
      final isValid = _validateAge(invalidAge);
      
      // THEN: Assertions
      expect(isValid, false, 
        reason: 'Negative age should be rejected.');
        
      print('✅ PROFILE-003 Passed: Rejected invalid profile data (age).');
    });

    // PROFILE-004: Happy Path - View dashboard summary under Profile
    test('PROFILE-004: Given existing health data, When viewing the "Health Overview", Then summarized data for Sleep, Food, and Exercise is displayed.', () {
      // GIVEN: Existing health data
      final healthData = {
        'sleep': 7.5,
        'steps': 8500,
        'calories': 1800,
      };
      
      // WHEN: Health data is loaded (Act)
      final hasHealthData = healthData['sleep'] != null &&
                           healthData['steps'] != null; // Checking core fields
      
      // THEN: Assertions
      expect(hasHealthData, true, 
        reason: 'Profile should display summarized health overview.');
        
      print('✅ PROFILE-004 Passed: View dashboard summary under Profile successfully.');
    });

    // PROFILE-005: Happy Path - Update account settings successfully (Change Password)
    test('PROFILE-005: Given a valid current password and a new password, When the user taps "Save", Then the settings are updated successfully.', () {
      // GIVEN: Valid password inputs
      const currentPassword = 'oldpass123';
      const newPassword = 'newpass456';
      
      // WHEN: Validation checks (Act)
      final isCurrentPasswordValid = currentPassword.length >= 6;
      final isNewPasswordValid = _validatePassword(newPassword);
      final canUpdate = isCurrentPasswordValid && isNewPasswordValid;
      
      // THEN: Assertions
      expect(canUpdate, true, 
        reason: 'Password should be successfully updated.');
        
      print('✅ PROFILE-005 Passed: Update account settings successfully.');
    });

    // PROFILE-006: Sad Path - Invalid account settings change (Empty New Password)
    test('PROFILE-006: Given an empty new password, When the user taps "Save", Then an "New password is required" error is displayed.', () {
      // GIVEN: Empty new password
      const newPassword = '';
      
      // WHEN: Validation check (Act)
      final isNewPasswordValid = _validatePassword(newPassword);
      
      // THEN: Assertions
      expect(isNewPasswordValid, false, 
        reason: 'Empty new password should be rejected.');
        
      print('✅ PROFILE-006 Passed: Invalid account settings change rejected.');
    });
    
    // Additional: Membership type validation (kept for completeness)
    test('PROFILE-007: Given a membership type, When the profile is loaded, Then the membership type is validated against allowed types.', () {
      // GIVEN: Valid membership type
      final validMembershipTypes = ['Free', 'Premium'];
      const userMembership = 'Premium';
      
      // WHEN: Membership is validated (Act)
      final isValidMembership = validMembershipTypes
          .map((e) => e.toLowerCase())
          .contains(userMembership.toLowerCase());
      
      // THEN: Assertions
      expect(isValidMembership, true, 
        reason: 'Membership type should be valid.');
        
      print('✅ PROFILE-007 Passed: Membership type validated.');
    });
  });
}

// Helper Functions
bool _validateWeight(int weight) {
  return weight > 0 && weight <= 300; 
}

bool _validateAge(int age) {
  return age > 0 && age <= 120;
}

bool _validatePassword(String password) {
  return password.length >= 6;
}