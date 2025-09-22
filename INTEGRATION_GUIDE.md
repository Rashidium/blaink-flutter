# Blaink Flutter SDK Integration Guide

This guide will help you integrate the Blaink Flutter SDK into your Flutter application.

## Prerequisites

- Flutter 3.10.0 or higher
- iOS 12.0+ for iOS builds
- Android API level 21+ for Android builds
- Firebase project with Cloud Messaging enabled

## Installation

### 1. Add Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  blaink_flutter:
    git:
      url: https://github.com/Rashidium/blaink-flutter.git
      ref: main
  firebase_messaging: ^14.7.10
  firebase_core: ^2.24.2
```

### 2. Install Dependencies

```bash
flutter pub get
```

## Platform Setup

### iOS Setup

1. **Add Blaink Swift Package**:
   - Open your iOS project in Xcode
   - Go to File → Add Package Dependencies
   - Add the Blaink Swift package from your repository

2. **Configure Firebase**:
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to your iOS project in Xcode

3. **Enable Push Notifications**:
   - In Xcode, select your target
   - Go to Signing & Capabilities
   - Add "Push Notifications" capability

### Android Setup

1. **Configure Firebase**:
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/` directory

2. **Update Android Gradle Files**:
   - Add Google Services plugin to `android/build.gradle`:
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```
   - Apply plugin in `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

3. **Add GitHub Packages Repository**:
   Add to `android/build.gradle`:
   ```gradle
   allprojects {
     repositories {
       maven {
         name = "GitHubPackages"
         url = uri("https://maven.pkg.github.com/Rashidium/blaink-android")
         credentials {
           username = project.findProperty("gpr.user") ?: System.getenv("USERNAME")
           password = project.findProperty("gpr.key") ?: System.getenv("TOKEN")
         }
       }
     }
   }
   ```

## Implementation

### 1. Initialize Firebase

In your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### 2. Create Blaink Delegate

```dart
class MyBlainkDelegate implements BlainkDelegate {
  @override
  void didReceiveNotification(Map<String, String> payload) {
    // Handle incoming push notification
    print('Received notification: $payload');
    
    // Navigate to specific screen based on payload
    // Show local notification
    // Update UI state
  }

  @override
  void didRegisterForBlainkNotifications(String userId) {
    // Device successfully registered with Blaink
    print('Registered with user ID: $userId');
    
    // Save user ID to local storage
    // Update user interface
  }

  @override
  void didFailToRegisterForBlainkNotifications(String error) {
    // Registration failed
    print('Registration failed: $error');
    
    // Show error message to user
    // Retry registration
  }

  @override
  void didRefreshFCMToken(String newToken) {
    // FCM token was refreshed
    print('FCM token refreshed: $newToken');
    
    // Register new token with Blaink
    Blaink.registerForRemoteNotifications(newToken);
  }
}
```

### 3. Initialize Blaink SDK

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeBlaink();
  }

  void _initializeBlaink() async {
    try {
      // Set up delegate
      Blaink.setDelegate(MyBlainkDelegate());
      
      // Initialize SDK
      await Blaink.setup(
        sdkKey: "YOUR_SDK_KEY_HERE",
        environment: PushEnvironment.development, // or .production
        isDebugLogsEnabled: true,
      );
      
      // Set up Firebase Messaging
      await _setupFirebaseMessaging();
      
    } catch (e) {
      print('Blaink initialization failed: $e');
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    // Get FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await Blaink.registerForRemoteNotifications(token);
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      Blaink.registerForRemoteNotifications(newToken);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}
```

### 4. Request Notification Permissions

```dart
Future<void> _requestNotificationPermissions() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}
```

### 5. Update User Information

```dart
Future<void> _updateUserProfile() async {
  try {
    await Blaink.updateUser(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phone: '+1234567890',
    );
    print('User profile updated successfully');
  } catch (e) {
    print('Failed to update user profile: $e');
  }
}
```

### 6. Get Current User

```dart
Future<void> _getCurrentUser() async {
  try {
    String? userId = await Blaink.getCurrentUser();
    if (userId != null) {
      print('Current user ID: $userId');
    } else {
      print('No user registered');
    }
  } catch (e) {
    print('Failed to get current user: $e');
  }
}
```

## Testing

### 1. Test on iOS Simulator

```bash
flutter run -d ios
```

### 2. Test on Android Emulator

```bash
flutter run -d android
```

### 3. Test Push Notifications

1. Use Firebase Console to send test notifications
2. Use your backend to send notifications via Blaink API
3. Test both foreground and background notification handling

## Troubleshooting

### Common Issues

1. **SDK Initialization Fails**:
   - Check if SDK key is correct
   - Verify network connectivity
   - Check debug logs for SSL pinning issues

2. **Push Notifications Not Received**:
   - Verify Firebase configuration
   - Check notification permissions
   - Ensure device token is registered

3. **Build Errors**:
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check iOS/Android specific setup
   - Verify all dependencies are correctly added

### Debug Logs

Enable debug logging to troubleshoot issues:

```dart
await Blaink.setup(
  sdkKey: "YOUR_SDK_KEY",
  environment: PushEnvironment.development,
  isDebugLogsEnabled: true, // Enable debug logs
);
```

## Best Practices

1. **Error Handling**: Always wrap SDK calls in try-catch blocks
2. **Token Management**: Handle FCM token refresh automatically
3. **Background Processing**: Use background message handlers for important notifications
4. **User Experience**: Request notification permissions at appropriate times
5. **Testing**: Test on both platforms and various device states

## Support

For additional support:
- Check the [README](README.md) for API documentation
- Visit [Blaink Documentation](https://docs.blaink.com)
- Contact support at support@blaink.com