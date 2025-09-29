#
#  blaink_flutter.podspec
#  Blaink Flutter SDK
#
#  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
#

Pod::Spec.new do |s|
  s.name             = 'blaink_flutter'
  s.version          = '1.1.7'
  s.summary          = 'Flutter SDK for Blaink push notification and messaging platform'
  s.description      = <<-DESC
Flutter SDK for Blaink push notification and messagin g platform
                       DESC
  s.homepage         = 'https://github.com/Rashidium/blaink-ios'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rashidium' => 'support@blaink.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Blaink', '~> 1.1.7'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end