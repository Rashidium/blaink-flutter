//
//  push_environment.dart
//  Blaink Flutter SDK
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

/// Push notification environment types
enum PushEnvironment {
  /// Development environment
  development,
  
  /// Production environment
  production,
}

extension PushEnvironmentExtension on PushEnvironment {
  /// Convert to string for platform channels
  String get value {
    switch (this) {
      case PushEnvironment.development:
        return 'development';
      case PushEnvironment.production:
        return 'production';
    }
  }
  
  /// Create from string value
  static PushEnvironment fromString(String value) {
    switch (value.toLowerCase()) {
      case 'development':
        return PushEnvironment.development;
      case 'production':
        return PushEnvironment.production;
      default:
        return PushEnvironment.production;
    }
  }
}