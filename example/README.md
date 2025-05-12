# ChatView Connect Example

A Flutter app demonstrating the use of `chatview_connect` — a wrapper around the `chatview` package that supports multiple cloud backends. This example focuses on Firebase integration.

### Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/release/archive#stable-channel) (version 3.22.0 or higher)
2. [Firebase project](https://console.firebase.google.com/)

### Firebase Setup

1. **Create a Firebase project**:
    - Go to [Firebase Console](https://console.firebase.google.com/)
    - Create a new project or use an existing one

2. **Add Firebase to your Flutter app**:
    - Register your app with Firebase (Android, iOS, Web and Others)
    - Download the configuration files:
        - `google-services.json` for Android
        - `GoogleService-Info.plist` for iOS, MacOS
        - Configure web, windows as needed

3. **Enable Firestore Database and Storage**:
    - In Firebase Console, enable [Cloud Firestore](https://console.firebase.google.com/project/_/firestore/?_gl=1*1df50if*_ga*MjA5MDI2ODM5My4xNzEyNTY1Njkx*_ga_CW55HF8NVT*czE3NDcxOTc5OTckbzExJGcxJHQxNzQ3MjAyNzkwJGozMCRsMCRoMA..)
    - Set up Firestore security rules (see [documentation](https://simform-flutter-packages.web.app/chatViewConnect/firebase-security-rules) for reference rules)
    - Enable [Firebase Storage](https://console.firebase.google.com/project/_/storage/?_gl=1*10n1fix*_ga*MjA5MDI2ODM5My4xNzEyNTY1Njkx*_ga_CW55HF8NVT*czE3NDcxOTc5OTckbzExJGcxJHQxNzQ3MjAzMTkyJGo1MiRsMCRoMA..) for handling media files
    - Configure storage security rules (see [documentation](https://simform-flutter-packages.web.app/chatViewConnect/firebase-security-rules) for reference rules)

### Running the Example App

1. Clone the [repository](https://github.com/SimformSolutionsPvtLtd/chatview_connect.git)
2. Navigate to the example directory (e.g. in terminal, `cd example`)
3. Configure Firebase:
   ```bash
   flutterfire configure
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## Code Structure

The example app follows a modular structure:

- `main.dart`: Entry point with Firebase initialization and ChatViewConnect setup
- `modules/`: Feature-based screens and components
    - `chat_list/`: Chat conversations list screen
    - `chat_detail/`: Individual chat screen
    - `create_chat/`: Screen for creating new chats

## Additional Resources

- [ChatView Connect Documentation](https://simform-flutter-packages.web.app/chatViewConnect)
- [Firebase Documentation](https://firebase.google.com/docs)
