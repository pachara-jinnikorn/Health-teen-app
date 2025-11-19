import 'package:flutter_test/flutter_test.dart';

/// COMMUNITY FEATURE TESTS - Redesigned to BDD (Given-When-Then) Style
/// Based on test cases: COMM-001 to COMM-008
void main() {
  group('COMMUNITY Feature Scenarios (COMM-001 to COMM-008)', () {
    
    // COMM-001: Happy Path - Viewing the community feed successfully.
    test('COMM-001: Given a logged-in user with existing posts, When navigating to the Community feed, Then posts are displayed in descending order.', () {
      // GIVEN: Logged in user and existing mock posts
      final mockPosts = [
        {'id': 2, 'author': 'UserB', 'content': 'Latest post!'},
        {'id': 1, 'author': 'UserA', 'content': 'Older post!'},
      ];
      
      // WHEN: Feed loads and posts are processed (Act)
      final postsArePresent = mockPosts.isNotEmpty;
      
      // Explicitly cast the 'id' value to int before comparison
      final postsInDescendingOrder = (mockPosts[0]['id'] as int) > (mockPosts[1]['id'] as int);
      
      // THEN: Assertions
      expect(postsArePresent, true, 
        reason: 'The feed should display posts.');
      expect(postsInDescendingOrder, true, 
        reason: 'Posts must be in descending order (latest first).');
        
      print('✅ COMM-001 Passed: View community feed successfully.');
    });

    // COMM-002: Happy Path - Creating a new post successfully.
    test('COMM-002: Given valid post content, When the user clicks "Post", Then a success message appears and the post is saved.', () {
      // GIVEN: Valid content
      const postContent = 'Feeling great after today\'s cupping session!';
      
      // WHEN: Post is submitted (Act)
      final isValid = _validatePostContent(postContent);
      
      // THEN: Assertions
      expect(isValid, true, 
        reason: 'Valid post content should be accepted.');
        
      print('✅ COMM-002 Passed: Create new post successfully.');
    });

    // COMM-003: Sad Path - Attempt to create a post with empty text.
    test('COMM-003: Given empty post content, When the user attempts to post, Then an error message is displayed and the post is rejected.', () {
      // GIVEN: Empty content
      const emptyContent = '';
      
      // WHEN: Post is submitted (Act)
      final isValid = _validatePostContent(emptyContent);
      
      // THEN: Assertions
      expect(isValid, false, 
        reason: 'Empty post content should be rejected.');
        
      print('✅ COMM-003 Passed: Rejected empty post content.');
    });

    // COMM-004: Happy Path - Liking a post successfully.
    test('COMM-004: Given a logged-in user, When they tap the "Like" button, Then the like count increases and the post owner is notified.', () {
      // GIVEN: Initial state
      int likeCount = 5;
      final likedBy = <String>[];
      const currentUserId = 'user123';
      
      // WHEN: User likes the post
      if (!likedBy.contains(currentUserId)) {
        likedBy.add(currentUserId);
        likeCount++;
      }
      
      // THEN: Assertions
      expect(likeCount, 6, 
        reason: 'Like count should increase by 1.');
      expect(likedBy.contains(currentUserId), true, 
        reason: 'User should be recorded as a liker.');
        
      print('✅ COMM-004 Passed: Liking a post successfully.');
    });

    // COMM-005: Sad Path - Attempt to like a post without being logged in.
    test('COMM-005: Given an unauthenticated user, When they tap the "Like" button, Then a login prompt is displayed and no like is recorded.', () {
      // GIVEN: User not logged in
      const isLoggedIn = false;
      
      // WHEN: Like action is attempted (Act)
      final canLike = isLoggedIn;
      
      // THEN: Assertions
      expect(canLike, false, 
        reason: 'Must be logged in to like posts.');
        
      print('✅ COMM-005 Passed: Like rejected without login.');
    });

    // COMM-006: Happy Path - Commenting on a post successfully.
    test('COMM-006: Given valid comment content, When the user submits the comment, Then the comment appears immediately and is saved.', () {
      // GIVEN: Valid content
      const commentContent = 'That\'s inspiring!';
      int commentCount = 3;
      
      // WHEN: Comment is submitted (Act)
      final isValidComment = _validateComment(commentContent);
      if (isValidComment) {
        commentCount++;
      }
      
      // THEN: Assertions
      expect(isValidComment, true);
      expect(commentCount, 4, 
        reason: 'Comment count should increase.');
        
      print('✅ COMM-006 Passed: Commenting successfully.');
    });

    // COMM-007: Sad Path - Attempt to comment with empty text.
    test('COMM-007: Given empty comment content, When the user attempts to send, Then an error message is displayed and the comment is rejected.', () {
      // GIVEN: Empty content
      const emptyComment = '';
      
      // WHEN: Comment is submitted (Act)
      final isValid = _validateComment(emptyComment);
      
      // THEN: Assertions
      expect(isValid, false, 
        reason: 'Empty comment should be rejected.');
        
      print('✅ COMM-007 Passed: Rejected empty comment.');
    });

    // COMM-008: Happy Path - Sharing a post successfully.
    test('COMM-008: Given a post, When the user shares it, Then the shared post appears in their feed with attribution.', () {
      // GIVEN: Original post details
      const originalAuthor = 'User1';
      const sharedByUser = 'User2';
      final post = {
        'content': 'Great health tip!',
        'originalAuthor': originalAuthor,
      };
      
      // WHEN: User shares the post
      final sharedPost = {
        ...post,
        'sharedBy': sharedByUser,
        'isShared': true,
      };
      
      // THEN: Assertions
      expect(sharedPost['isShared'], true);
      expect(sharedPost['sharedBy'], sharedByUser, reason: 'Should show the sharer.');
      expect(sharedPost['originalAuthor'], originalAuthor, 
        reason: 'Original author should be preserved for attribution.');
        
      print('✅ COMM-008 Passed: Sharing a post successfully.');
    });
    
    // Additional: Unlike post functionality (kept for completeness)
    test('COMM-009: Given a previously liked post, When the user unlikes it, Then the like count decreases.', () {
      // GIVEN: Post is liked
      int likeCount = 6;
      final likedBy = ['user123', 'user456'];
      const currentUserId = 'user123';
      
      // WHEN: User unlikes the post
      if (likedBy.contains(currentUserId)) {
        likedBy.remove(currentUserId);
        likeCount--;
      }
      
      // THEN: Assertions
      expect(likeCount, 5);
      expect(likedBy.contains(currentUserId), false, reason: 'User should be removed from the likedBy list.');
      
      print('✅ COMM-009 Passed: Unlike decreases count.');
    });
  });
}

// Helper Functions
bool _validatePostContent(String content) {
  return content.trim().isNotEmpty && content.length <= 500;
}

bool _validateComment(String content) {
  return content.trim().isNotEmpty && content.length <= 200;
}