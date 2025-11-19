# 🍏 Healthteen App

A modern wellness application designed to help users track their daily health, manage their profile, and stay connected with a supportive community.

## 🚀 Live Deployment
The application is deployed on **Vercel** and accessible here:

| Environment | URL |
|------------|-----|
| Production / Staging | https://health-teen-app-v2.vercel.app/ |

## ✨ Core Features

Healthteen focuses on **user management**, **daily wellness tracking**, and **community interaction**.

### 🔐 Login & Authentication
- Secure login and credential validation  
- Session management (stay logged in / logout)  
- Error handling for invalid credentials  
**User Stories:** LOGIN-001 → LOGIN-008

### 🏠 Home Dashboard
- Overview of today’s wellness summary  
- Track Sleep, Meals, and Exercise  
- Add / edit daily health entries  
**User Stories:** HOME-001 → HOME-010

### 👥 Community Hub
- View global posts  
- Create, like, comment, and share posts  
- Handles actions for logged-in and guest users  
**User Stories:** COMM-001 → COMM-008

### 🙋‍♂️ User Profile
- Update personal info  
- Review health summary  
- Change account password  
**User Stories:** PROFILE-001 → PROFILE-006

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK (bundled)
- VS Code or Android Studio

### Installation

#### Clone
```
git clone [your-repository-url]
cd healthteen-app
```

#### Install
```
flutter pub get
```

#### Run
```
flutter run
```

## 🧪 Testing

### Run all tests
```
flutter test
```

### Test Files

| Test File | Focus | Coverage |
|-----------|--------|----------|
| login_test.dart | Authentication | LOGIN-001 → LOGIN-008 |
| profile_test.dart | Profile logic | PROFILE-001 → PROFILE-006 |
| home_test.dart | Health tracking | HOME-001 → HOME-010 |
| community_test.dart | Posts & interactions | COMM-001 → COMM-008 |
| widget_test.dart | UI checks | TESTS 1 → 20 |

## 👥 Authors

| Name | Student ID |
|------|------------|
| Pakpoom Rojana | 6531503062 |
| Pachara Chinnikorn | 6531503057 |
| Teerapat Khwandee | 6531503037 |
| Patthamaporn Sertluecha | 6531503200 |
| Punyawee Prommool | 6531503056 |
| Kongphop Saenphai | 6531503008 |
| Suranan Chirachatchai | 6531503086 |
| Sasithon Kaeotang | 6531503076 |
