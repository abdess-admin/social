# Social App

A TikTok/Snapchat-style social mobile app built with Flutter and Firebase.

## Features (Version 1 - In Progress)

- User authentication (email/password) with Firebase
- Bottom navigation with 5 tabs: Home, Stories, Camera, Messages, Profile
- Vertical video feed (TikTok-style)
- Video upload functionality
- Like and comment system
- 24-hour Stories
- Private 1-to-1 messaging
- User profile with published videos

## Tech Stack

- **Frontend:** Flutter (Android first, iOS later)
- **Backend:** Firebase (Authentication, Firestore, Storage, Cloud Messaging)

## Prerequisites

### Installing Flutter on macOS

1. **Download Flutter SDK:**
   - Visit the official Flutter installation page: https://docs.flutter.dev/get-started/install/macos
   - Download the latest stable release

2. **Extract and add to PATH:**
   ```bash
   cd ~/development
   unzip ~/Downloads/flutter_macos_arm64_3.x.x-stable.zip
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. **Add Flutter to your shell profile permanently:**
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

4. **Run Flutter Doctor:**
   ```bash
   flutter doctor
   ```
   This will show you any missing dependencies.

5. **Install Xcode (for iOS development):**
   - Download from the Mac App Store
   - Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
   - Run: `sudo xcodebuild -runFirstLaunch`

6. **Install Android Studio (for Android development):**
   - Download from: https://developer.android.com/studio
   - Install the Flutter and Dart plugins

For detailed instructions, see: https://docs.flutter.dev/get-started/install/macos

## Running the App Locally

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd social_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**

   **For Web (Chrome):**
   ```bash
   flutter run -d chrome
   ```

   **For Android:**
   ```bash
   flutter run -d android
   ```

   **For iOS (macOS only):**
   ```bash
   flutter run -d ios
   ```

   **List available devices:**
   ```bash
   flutter devices
   ```

## Firebase Setup (Required for Full Functionality)

Before running the app with full features, you need to configure Firebase:

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Email/Password authentication
3. Create Firestore database
4. Set up Firebase Storage
5. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
6. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── providers/             # State management
│   └── auth_provider.dart
├── screens/               # UI screens
│   ├── main_screen.dart   # Bottom navigation
│   ├── home_screen.dart   # Video feed
│   ├── stories_screen.dart
│   ├── camera_screen.dart
│   ├── messages_screen.dart
│   └── profile_screen.dart
├── models/                # Data models
├── services/              # Firebase services
└── widgets/               # Reusable widgets
```

## Development Status

- [x] Step 1: Project setup with bottom navigation
- [ ] Step 2: Firebase Authentication
- [ ] Step 3: Vertical video feed
- [ ] Step 4: Video upload
- [ ] Step 5: Like and comment system
- [ ] Step 6: Stories system
- [ ] Step 7: Private messaging
- [ ] Step 8: User profile with videos

## License

MIT License
