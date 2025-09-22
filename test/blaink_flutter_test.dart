//
//  blaink_flutter_test.dart
//  Blaink Flutter SDK Tests
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

import 'package:flutter_test/flutter_test.dart';
import 'package:blaink_flutter/blaink_flutter.dart';

void main() {
  group('BlainkFlutter', () {
    test('PushEnvironment enum values', () {
      expect(PushEnvironment.development.value, equals('development'));
      expect(PushEnvironment.production.value, equals('production'));
    });

    test('PushEnvironment fromString', () {
      expect(PushEnvironmentExtension.fromString('development'), 
             equals(PushEnvironment.development));
      expect(PushEnvironmentExtension.fromString('production'), 
             equals(PushEnvironment.production));
      expect(PushEnvironmentExtension.fromString('invalid'), 
             equals(PushEnvironment.production));
    });

    test('BlainkDelegate default implementation', () {
      final delegate = MockBlainkDelegate();
      expect(delegate, isA<BlainkDelegate>());
    });
  });
}

class MockBlainkDelegate implements BlainkDelegate {
  @override
  void didReceiveNotification(Map<String, String> payload) {}

  @override
  void didRegisterForBlainkNotifications(String userId) {}

  @override
  void didFailToRegisterForBlainkNotifications(String error) {}

  @override
  void didRefreshFCMToken(String newToken) {}
}