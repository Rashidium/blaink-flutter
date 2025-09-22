# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-21

### Added
- Initial release of Blaink Flutter SDK
- Cross-platform support for iOS and Android
- Push notification handling with Firebase Cloud Messaging and APNS
- SSL certificate pinning for secure communications
- Secure storage for sensitive data
- Device registration with Blaink backend
- User management functionality
- Event delegation system for SDK callbacks
- Example Flutter app demonstrating SDK usage
- Comprehensive documentation and integration guides

### Features
- `Blaink.setup()` - Initialize the SDK with configuration
- `Blaink.registerForRemoteNotifications()` - Register for push notifications
- `Blaink.getCurrentUser()` - Get current user information
- `Blaink.updateUser()` - Update user profile information
- `Blaink.setDelegate()` - Set up event handling delegate
- `BlainkDelegate` - Protocol for handling SDK events

### Platform Support
- iOS 12.0+ with native Blaink Swift package
- Android API 21+ with native Blaink Android SDK
- Flutter 3.10.0+

### Dependencies
- Firebase Messaging for push notifications
- Platform channels for native communication
- SSL pinning for secure network requests
- Encrypted storage for sensitive data