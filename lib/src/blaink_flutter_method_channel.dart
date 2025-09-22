//
//  blaink_flutter_method_channel.dart
//  Blaink Flutter SDK
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

import 'package:flutter/services.dart';
import 'blaink_flutter_platform_interface.dart';
import 'blaink_delegate.dart';
import 'push_environment.dart';

/// Method channel implementation of [BlainkFlutterPlatform]
class MethodChannelBlainkFlutter extends BlainkFlutterPlatform {
  /// The method channel used to interact with the native platform
  final MethodChannel _methodChannel = const MethodChannel('blaink_flutter');

  /// Event channel for receiving SDK events
  final EventChannel _eventChannel = const EventChannel('blaink_flutter/events');

  BlainkDelegate? _delegate;

  MethodChannelBlainkFlutter() {
    _eventChannel.receiveBroadcastStream().listen(_handleEvent);
  }

  @override
  Future<void> setup({
    required String sdkKey,
    required PushEnvironment environment,
    required bool isDebugLogsEnabled,
  }) async {
    await _methodChannel.invokeMethod('setup', {
      'sdkKey': sdkKey,
      'environment': environment.value,
      'isDebugLogsEnabled': isDebugLogsEnabled,
    });
  }

  @override
  Future<void> registerForRemoteNotifications(String deviceToken) async {
    await _methodChannel.invokeMethod('registerForRemoteNotifications', {
      'deviceToken': deviceToken,
    });
  }

  @override
  Future<String?> getCurrentUser() async {
    final result = await _methodChannel.invokeMethod('getCurrentUser');
    return result as String?;
  }

  @override
  Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    await _methodChannel.invokeMethod('updateUser', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    });
  }

  @override
  void setDelegate(BlainkDelegate? delegate) {
    _delegate = delegate;
  }

  /// Handle events from native platform
  void _handleEvent(dynamic event) {
    if (_delegate == null) return;

    final Map<String, dynamic> eventData = Map<String, dynamic>.from(event);
    final String eventType = eventData['type'] as String;

    switch (eventType) {
      case 'didReceiveNotification':
        final Map<String, String> payload = 
            Map<String, String>.from(eventData['payload'] ?? {});
        _delegate!.didReceiveNotification(payload);
        break;

      case 'didRegisterForBlainkNotifications':
        final String userId = eventData['userId'] as String;
        _delegate!.didRegisterForBlainkNotifications(userId);
        break;

      case 'didFailToRegisterForBlainkNotifications':
        final String error = eventData['error'] as String;
        _delegate!.didFailToRegisterForBlainkNotifications(error);
        break;

      case 'didRefreshFCMToken':
        final String newToken = eventData['newToken'] as String;
        _delegate!.didRefreshFCMToken(newToken);
        break;
    }
  }
}