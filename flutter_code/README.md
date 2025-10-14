# Health Teen Flutter App

Complete Flutter implementation of the Health Teen health and wellness tracking application.

## Quick Start

### 1. Create Flutter Project
\`\`\`bash
flutter create health_teen
cd health_teen
\`\`\`

### 2. Copy Files
Copy all files from the `flutter_code/` directory into your Flutter project:
- Replace entire `lib/` folder
- Replace `pubspec.yaml`

### 3. Install Dependencies
\`\`\`bash
flutter pub get
\`\`\`

### 4. Run the App
\`\`\`bash
# Chrome (easiest for testing)
flutter run -d chrome

# iOS Simulator (Mac only)
open -a Simulator
flutter run

# Android
flutter run

# Windows Desktop
flutter run -d windows
\`\`\`

## Troubleshooting

### ❌ "No devices found"
Start a device first:
\`\`\`bash
flutter run -d chrome  # Easiest option
\`\`\`

### ❌ "Package not found" or compilation errors
\`\`\`bash
flutter clean
flutter pub get
flutter run
\`\`\`

### ❌ "Developer Mode required" (Windows)
\`\`\`bash
start ms-settings:developers
# Enable Developer Mode in Windows Settings
\`\`\`

### ❌ Badge naming conflict
Fixed in latest version - `Badge` class renamed to `AchievementBadge`

## Project Structure

\`\`\`
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── health_data.dart
│   ├── achievement_badge.dart   # Renamed to avoid conflict
│   ├── post.dart
│   └── message.dart
├── providers/                   # State management
│   ├── health_data_provider.dart
│   ├── community_provider.dart
│   └── chat_provider.dart
├── screens/                     # App screens
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── community_screen.dart
│   ├── chat_screen.dart
│   ├── conversation_screen.dart
│   ├── challenges_screen.dart
│   └── profile_screen.dart
├── widgets/                     # Reusable components
│   ├── health_card.dart
│   └── post_card.dart
└── utils/                       # Constants and helpers
    └── constants.dart
\`\`\`

## Features Implemented

✅ Health tracking (steps, sleep, calories)  
✅ Dashboard with charts and analytics  
✅ Community feed with posts  
✅ Like/comment functionality  
✅ Direct messaging and chat  
✅ Wellness coach chat  
✅ Challenges system  
✅ User profile  
✅ Local data persistence (SharedPreferences)  
✅ Bottom navigation  
✅ Mobile-optimized UI  
✅ Interactive charts (fl_chart)  

## What's Working Out of the Box

- All screens render correctly
- Health data logs and persists between sessions
- Charts update with real data
- Community posts can be liked and commented on
- Chat messages can be sent and received
- Profile settings are editable
- No Firebase required for basic functionality

## Optional: Firebase Setup

Firebase is commented out by default. To enable cloud features:

\`\`\`bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
\`\`\`

Then uncomment Firebase initialization in `main.dart`:
\`\`\`dart
await Firebase.initializeApp();
\`\`\`

## Next Steps

1. **Test the app**: Run on your preferred platform
2. **Customize colors**: Edit `lib/utils/constants.dart`
3. **Add Firebase**: Follow optional setup above for cloud sync
4. **Add authentication**: Implement Firebase Auth
5. **Deploy**: Build for production with `flutter build`

## Package Versions

All packages are set to latest compatible versions:
- Firebase packages: v3.x - v15.x (latest stable)
- Provider: v6.1.1
- fl_chart: v0.66.0
- shared_preferences: v2.2.2

## Notes

- Data persists locally using SharedPreferences
- Firebase code is commented out (optional)
- Charts use fl_chart for visualization
- No mood tracking (removed per requirements)
- All UI matches the original React design
