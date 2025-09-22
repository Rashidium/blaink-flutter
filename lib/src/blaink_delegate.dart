//
//  blaink_delegate.dart
//  Blaink Flutter SDK
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

/// Delegate protocol for Blaink SDK events
abstract class BlainkDelegate {
  /// Called when a push notification is received
  void didReceiveNotification(Map<String, String> payload);
  
  /// Called when device is successfully registered with Blaink backend
  void didRegisterForBlainkNotifications(String userId);
  
  /// Called when push notification registration fails
  void didFailToRegisterForBlainkNotifications(String error);
  
  /// Called when FCM token is refreshed
  void didRefreshFCMToken(String newToken);
}