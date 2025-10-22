1. Introduction & Scope
This section outlines the specific test cases for the key user stories being developed in Sprint 2.
 The main objective is to verify the Community feature, ensuring its reliability, correctness, and usability as a social interaction platform within The Cupping Hub.
 These test cases will be used for both manual and automated testing to minimize defects and improve user experience.
Project: The Cupping Hub
Feature: Community
Author(s): [List team members]
Date Created: October 22, 2025

2. Feature: Community
User Story: "As a user, I want to view, create, and interact with community posts so that I can share experiences and engage with others."

COMM-001
(Happy Path) Viewing the community feed successfully.
1.Logged in as a user.
2.At least one post exists from friends or groups.


Navigate to the Community tab.
Observe the feed.
The system displays the latest posts from friends or groups.


Each post shows username, text content, and interaction buttons (like, comment, share).


Posts appear in descending order (latest first).
COMM-002


(Happy Path) Creating a new post successfully.


1.Logged in as a user.
Tap “+ New Post.”
Enter text: “Feeling great after today’s cupping session!”
Click “Post.”


A success message “Post created successfully” appears.


The new post appears at the top of the feed.


Post data is saved to the database.


COMM-003
(Sad Path) 
Attempt to create a post with empty text.
1.Logged in as a user.
Tap “+ New Post.”
Leave the text field blank.
Click “Post.”
An error message “Post content cannot be empty” is displayed.


Post is not created.


The feed remains unchanged.
COMM-004
(Happy Path) 
Liking a post successfully.
1.Logged in as a user.
2.At least one post is visible in the feed.
Tap the “Like” button on a post.
The like count increases by 1.


The like button changes state (e.g., filled heart).


A notification is sent to the post owner.
COMM-005
(Sad Path) 
Attempt to like a post without being logged in.
User is not logged in.


A public feed is visible.


Tap the “Like” button on a post.
A message “Please log in to interact with posts” appears.


No like is recorded.
COMM-006
(Happy Path) Commenting on a post successfully.
Logged in as a user.


At least one post is visible in the feed.
Tap “Comment” on a post.
Enter text: “That’s inspiring!”
Click “Send.”
The comment appears immediately below the post.


Comment data is saved to the database.


The post owner receives a notification.
COMM-007
(Sad Path) 
Attempt to comment with empty text.
Logged in as a user.


Viewing a post.
Tap “Comment.”


Leave the comment field blank.


Click “Send.”


An error message “Comment cannot be empty” is displayed.


Comment is not saved.
COMM-008
(Happy Path)
 Sharing a post successfully.
Logged in as a user.


At least one post is visible.


Tap the “Share” button on a post.


Confirm the share action.
The shared post appears in the user’s feed with a label “Shared from [username].”


A notification is sent to the original post owner.



Feature: Home
Test ID
Scenario (Type)
Preconditions
Test Steps
Expected Results
HOME-001
(Happy Path) 
Add sleep data successfully
- Logged in as a user
- User is on the Home page
1. Tap “Add Sleep”
2. Enter “7 hours”
3. Click “Save”
- Success message “Sleep data saved successfully” appears
- Quick Snapshot & Dashboard update immediately
- Data stored securely in the database
HOME-002
(Sad Path) 
Add sleep data with invalid value
- Logged in as a user
- User is on the Home page
1. Tap “Add Sleep”
2. Enter “-3”
3. Click “Save”
- Error message “Sleep hours must be a positive number” appears
- Data not saved
- Quick Snapshot remains unchanged
HOME-003
(Happy Path) 
Add meal data successfully
- Logged in as a user
- User is on the Home page
1. Tap “Add Meal”
2. Enter “Grilled chicken salad” and “350 kcal”
3. Click “Save”
- Success message “Meal added successfully” appears
- Quick Snapshot & Nutrition Summary update
- Data saved in the database
HOME-004
(Sad Path) 
Add meal data with missing calories
- Logged in as a user
- User is on the Home page
1. Tap “Add Meal”
2. Enter “Omelet” and leave calories blank
3. Click “Save”
- Error message “Calories value is required” appears
- Data not saved
HOME-005
(Happy Path) 
Add exercise successfully
- Logged in as a user
- User is on the Home page
1. Tap “Add Exercise”
2. Enter “Running 30 minutes”
3. Click “Save”
- Success message “Exercise added successfully” appears
- Quick Snapshot & Progress Statistics update
- Data stored securely
HOME-006
(Sad Path) 
Add exercise with invalid input
- Logged in as a user
- User is on the Home page
1. Tap “Add Exercise”
2. Enter “Running -10 minutes”
3. Click “Save”
- Error message “Duration must be greater than zero” appears
- Data not saved
HOME-007
(Happy Path) 
View notifications and daily goals
- Logged in as a user
- User has existing goals and notifications
1. Tap “Notifications”
2. Tap “Daily Goals”
- System displays relevant alerts and reminders
- Goal progress shown accurately
HOME-008
(Happy Path) 
Navigate via shortcuts
- Logged in as a user
- User is on the Home page
1. Tap “Dashboard” shortcut
2. Tap “Community” shortcut
3. Tap “Profile” shortcut
- Each shortcut navigates to the correct page smoothly
- Navigation works consistently
HOME-009
(Sad Path) 
Access shortcuts without login
- User is not logged in
1. Open the app
2. Tap “Dashboard” or “Community” shortcut
- Redirected to Login page
- Message “Please log in to access this feature” displayed
HOME-010
(Happy Path) 
Verify data encryption
- Logged in as a user
- User adds any health data
1. Add new data (sleep/meal/exercise)
2. Check database or API
- Data stored in encrypted format
- No sensitive data in plain text

PDF flie https://drive.google.com/file/d/1T6-nze-sZehyoVgiSvyD9RJCpWclBWN-/view?usp=sharing

