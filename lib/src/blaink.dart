//
//  blaink.dart
//  Blaink Flutter SDK
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

import 'blaink_flutter_platform_interface.dart';
import 'blaink_delegate.dart';
import 'push_environment.dart';

/// Main Blaink SDK class for Flutter
class Blaink {
  static BlainkDelegate? _delegate;

  /// Initialize the Blaink SDK
  /// 
  /// [sdkKey] Your Blaink SDK key
  /// [environment] Push notification environment (development/production)
  /// [isDebugLogsEnabled] Enable debug logging
  static Future<void> setup({
    required String sdkKey,
    PushEnvironment environment = PushEnvironment.production,
    bool isDebugLogsEnabled = false,
  }) async {
    await BlainkFlutterPlatform.instance.setup(
      sdkKey: sdkKey,
      environment: environment,
      isDebugLogsEnabled: isDebugLogsEnabled,
    );
  }

  /// Register for remote push notifications
  /// 
  /// [deviceToken] FCM token for Android or APNS token for iOS
  static Future<void> registerForRemoteNotifications(String deviceToken) async {
    await BlainkFlutterPlatform.instance.registerForRemoteNotifications(deviceToken);
  }

  /// Get current user ID
  static Future<String?> getCurrentUser() async {
    return await BlainkFlutterPlatform.instance.getCurrentUser();
  }

  /// Update user information
  /// 
  /// [firstName] User's first name
  /// [lastName] User's last name
  /// [email] User's email address
  /// [phone] User's phone number
  static Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    await BlainkFlutterPlatform.instance.updateUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
  }

  /// Set delegate for SDK events
  /// 
  /// [delegate] BlainkDelegate instance to receive SDK events
  static void setDelegate(BlainkDelegate? delegate) {
    _delegate = delegate;
    BlainkFlutterPlatform.instance.setDelegate(delegate);
  }

  /// Get current delegate
  static BlainkDelegate? get delegate => _delegate;
}