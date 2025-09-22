# Blaink Flutter SDK

A Flutter plugin that provides a unified interface for the Blaink push notification and messaging platform on both iOS and Android.

## Features

- 🚀 **Cross-Platform**: Works seamlessly on both iOS and Android
- 🔔 **Push Notifications**: Full support for Firebase Cloud Messaging (Android) and APNS (iOS)
- 🔐 **SSL Pinning**: Built-in security with certificate pinning
- 🏪 **Secure Storage**: Encrypted storage for sensitive data
- 📱 **Device Registration**: Automatic device registration with Blaink backend
- 🔄 **Token Management**: Automatic FCM/APNS token refresh handling
- 📊 **User Management**: Update user information and track user sessions

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  blaink_flutter:
    git:
      url: https://github.com/Rashidium/blaink-flutter.git
      ref: main
  firebase_messaging: ^14.7.10
  firebase_core: ^2.24.2
```

## Setup

### 1. Initialize the SDK

```dart
import 'package:blaink_flutter/blaink_flutter.dart';

// Initialize SDK
await Blaink.setup(
  sdkKey: "YOUR_SDK_KEY",
  environment: PushEnvironment.development, // or .production
  isDebugLogsEnabled: true,
);
```

### 2. Set up Delegate

```dart
class MyAppDelegate implements BlainkDelegate {
  @override
  void didReceiveNotification(Map<String, String> payload) {
    // Handle incoming push notification
    print('Received notification: $payload');
  }

  @override
  void didRegisterForBlainkNotifications(String userId) {
    // Device successfully registered
    print('Registered with user ID: $userId');
  }

  @override
  void didFailToRegisterForBlainkNotifications(String error) {
    // Registration failed
    print('Registration failed: $error');
  }

  @override
  void didRefreshFCMToken(String newToken) {
    // FCM token refreshed
    Blaink.registerForRemoteNotifications(newToken);
  }
}

// Set delegate
Blaink.setDelegate(MyAppDelegate());
```

### 3. Register for Push Notifications

```dart
// Get FCM token and register
FirebaseMessaging.instance.getToken().then((token) {
  if (token != null) {
    Blaink.registerForRemoteNotifications(token);
  }
});

// Listen for token refresh
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  Blaink.registerForRemoteNotifications(newToken);
});
```

## API Reference

### Blaink.setup()

Initialize the Blaink SDK.

```dart
static Future<void> setup({
  required String sdkKey,
  PushEnvironment environment = PushEnvironment.production,
  bool isDebugLogsEnabled = false,
});
```

### Blaink.registerForRemoteNotifications()

Register device token for push notifications.

```dart
static Future<void> registerForRemoteNotifications(String deviceToken);
```

### Blaink.getCurrentUser()

Get the current user ID.

```dart
static Future<String?> getCurrentUser();
```

### Blaink.updateUser()

Update user information.

```dart
static Future<void> updateUser({
  String? firstName,
  String? lastName,
  String? email,
  String? phone,
});
```

### Blaink.setDelegate()

Set delegate to receive SDK events.

```dart
static void setDelegate(BlainkDelegate? delegate);
```

## Platform Requirements

- **iOS**: iOS 12.0+
- **Android**: API level 21+ (Android 5.0+)
- **Flutter**: 3.10.0+

## Dependencies

- **iOS**: Uses the native Blaink Swift package
- **Android**: Uses the native Blaink Android SDK
- **Firebase**: Required for push notifications

## Getting Your SDK Key

1. Sign up at [Blaink Dashboard](https://dashboard.blaink.com)
2. Create a new project
3. Copy your SDK key from the project settings

## Example

See the `example/` directory for a complete Flutter app demonstrating SDK usage.

## Support

For support, please contact us at support@blaink.com or visit our [documentation](https://docs.blaink.com).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.