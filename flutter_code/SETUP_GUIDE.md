# Quick Setup Guide

## Step-by-Step Instructions

### 1. Download the Code
- Download the ZIP file from v0
- Extract to a folder (e.g., `Downloads/health-teen-flutter`)

### 2. Create Flutter Project
\`\`\`bash
flutter create health_teen
cd health_teen
\`\`\`

### 3. Copy Files
Copy these files from the extracted `flutter_code/` folder to your project:

**Replace:**
- `lib/` → Copy entire folder
- `pubspec.yaml` → Replace file

### 4. Install Packages
\`\`\`bash
flutter pub get
\`\`\`

### 5. Run the App
\`\`\`bash
# For Chrome (easiest)
flutter run -d chrome

# For iOS Simulator (Mac)
open -a Simulator
flutter run

# For Android
flutter run

# For Windows Desktop
flutter run -d windows
\`\`\`

## Common Issues & Fixes

### ❌ "No devices found"
**Solution:** Start a device first
\`\`\`bash
# Chrome
flutter run -d chrome

# iOS Simulator
open -a Simulator

# Android - open Android Studio and start emulator
\`\`\`

### ❌ "Package not found"
**Solution:**
\`\`\`bash
flutter clean
flutter pub get
\`\`\`

### ❌ "Developer Mode required" (Windows)
**Solution:**
\`\`\`bash
start ms-settings:developers
# Enable Developer Mode in settings
\`\`\`

### ❌ Compilation errors
**Solution:**
\`\`\`bash
flutter clean
flutter pub get
# Restart your IDE
flutter run
\`\`\`

## Verify Installation

After setup, you should see:
- ✅ Home screen with health metrics
- ✅ Dashboard with charts
- ✅ Community feed
- ✅ Chat interface
- ✅ Profile page

## Need Help?

1. Run `flutter doctor` to check your setup
2. Make sure Flutter SDK is properly installed
3. Ensure all files are copied correctly
4. Try `flutter clean` and reinstall packages

## What's Working

- ✅ All UI screens
- ✅ Health tracking with local storage
- ✅ Interactive charts
- ✅ Community posts with likes/comments
- ✅ Chat messaging
- ✅ Profile management
- ✅ Data persistence (saves between sessions)

## Optional: Enable Firebase

Firebase is commented out by default. To enable:

1. Install Firebase CLI
2. Run `flutterfire configure`
3. Uncomment Firebase code in `main.dart`
