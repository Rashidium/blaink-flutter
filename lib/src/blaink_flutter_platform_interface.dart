//
//  blaink_flutter_platform_interface.dart
//  Blaink Flutter SDK
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

import 'package:blaink_flutter/src/blaink_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'blaink_delegate.dart';
import 'push_environment.dart';


/// Platform interface for Blaink Flutter SDK
abstract class BlainkFlutterPlatform extends PlatformInterface {
  /// Constructs a BlainkFlutterPlatform
  BlainkFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BlainkFlutterPlatform _instance = MethodChannelBlainkFlutter();

  /// The default instance of [BlainkFlutterPlatform] to use.
  static BlainkFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BlainkFlutterPlatform] when
  /// they register themselves.
  static set instance(BlainkFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the Blaink SDK
  Future<void> setup({
    required String sdkKey,
    required PushEnvironment environment,
    required bool isDebugLogsEnabled,
  });

  /// Register for remote push notifications
  Future<void> registerForRemoteNotifications(String deviceToken);

  /// Get current user ID
  Future<String?> getCurrentUser();

  /// Update user information
  Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  });

  /// Set delegate for SDK events
  void setDelegate(BlainkDelegate? delegate);
}