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

import 'dart:async';
import 'package:flutter/services.dart';
import 'blaink_flutter_platform_interface.dart'; // your platform interface


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

/*
class MethodChannelBlainkFlutter extends BlainkFlutterPlatform {
  static const MethodChannel _channel = MethodChannel('blaink_flutter');
  static const EventChannel _events = EventChannel('blaink_flutter/events');

  BlainkDelegate? _delegate;
  StreamSubscription<dynamic>? _sub;

  // ---- Helpers ----

  String _envToNative(PushEnvironment env) {
    switch (env) {
      case PushEnvironment.production:
        return 'production';
      case PushEnvironment.development:
        return 'development';
    }
  }

  Map<String, dynamic> _withoutNulls(Map<String, dynamic?> src) {
    final out = <String, dynamic>{};
    src.forEach((k, v) {
      if (v != null) out[k] = v;
    });
    return out;
  }

  /// Safely cast dynamic map to Map<String,String>, dropping non-string values.
  Map<String, String> _asStringMap(dynamic value) {
    final result = <String, String>{};
    if (value is Map) {
      value.forEach((k, v) {
        final key = k?.toString();
        final val = v?.toString();
        if (key != null && val != null) result[key] = val;
      });
    }
    return result;
  }

  void _attachEvents() {
    _sub?.cancel();
    _sub = null;

    if (_delegate == null) return;

    _sub = _events.receiveBroadcastStream().listen((dynamic event) {
      if (event is! Map) return;

      final map = Map<String, dynamic>.from(event);
      final type = (map['type'] ?? '').toString();
      final payload = map['payload'];

      switch (type) {
        case 'notification_received':
          _delegate?.didReceiveNotification(_asStringMap(payload));
          break;

        case 'registered':
          _delegate?.didRegisterForBlainkNotifications(
            (payload?['userId'] ?? payload?['user_id'] ?? '').toString(),
          );
          break;

        case 'registration_failed':
          _delegate?.didFailToRegisterForBlainkNotifications(
            (payload?['error'] ?? '').toString(),
          );
          break;

        case 'token_refreshed':
          _delegate?.didRefreshFCMToken(
            (payload?['token'] ?? payload?['newToken'] ?? '').toString(),
          );
          break;

        default:
        // Unknown event type: ignore (or add logging if you like)
          break;
      }
    }, onError: (_) {
      // Swallow errors to avoid tearing down the stream; native side should log.
    }, cancelOnError: false);
  }

  // ---- Public API ----

  @override
  Future<void> setup({
    required String sdkKey,
    required PushEnvironment environment,
    required bool isDebugLogsEnabled,
  }) async {
    await _channel.invokeMethod<void>('setup', {
      'sdkKey': sdkKey,
      'environment': _envToNative(environment),
      'debug': isDebugLogsEnabled,
    });
  }

  @override
  Future<void> registerForRemoteNotifications(String deviceToken) async {
    await _channel.invokeMethod<void>('registerForRemoteNotifications', {
      'deviceToken': deviceToken,
    });
  }

  @override
  Future<String?> getCurrentUser() async {
    return _channel.invokeMethod<String?>('getCurrentUser');
  }

  @override
  Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    await _channel.invokeMethod<void>('updateUser', _withoutNulls({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    }));
  }

  @override
  void setDelegate(BlainkDelegate? delegate) {
    _delegate = delegate;
    _attachEvents();
  }

  // Optional cleanup if you expose it
  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _delegate = null;
  }
}
*/