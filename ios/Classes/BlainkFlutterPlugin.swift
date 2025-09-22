//
//  BlainkFlutterPlugin.swift
//  Blaink Flutter SDK
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

import Flutter
import UIKit
import Blaink

public class BlainkFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "blaink_flutter", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "blaink_flutter/events", binaryMessenger: registrar.messenger())
        
        let instance = BlainkFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setup":
            setup(call: call, result: result)
        case "registerForRemoteNotifications":
            registerForRemoteNotifications(call: call, result: result)
        case "getCurrentUser":
            getCurrentUser(result: result)
        case "updateUser":
            updateUser(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let sdkKey = args["sdkKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "SDK key is required", details: nil))
            return
        }
        
        let environmentStr = args["environment"] as? String ?? "production"
        let isDebugLogsEnabled = args["isDebugLogsEnabled"] as? Bool ?? false
        
        let environment: PushEnvironment = environmentStr == "development" ? .development : .production
        
        Blaink.shared.setup(
            sdkKey: sdkKey,
            environment: environment,
            isDebugLogsEnabled: isDebugLogsEnabled
        )
        
        result(nil)
    }
    
    private func registerForRemoteNotifications(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let deviceToken = args["deviceToken"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Device token is required", details: nil))
            return
        }
        
        Blaink.shared.registerForRemoteNotifications(deviceToken: deviceToken)
        result(nil)
    }
    
    private func getCurrentUser(result: @escaping FlutterResult) {
        Task {
            let userId = await Blaink.shared.getCurrentUser()
            result(userId)
        }
    }
    
    private func updateUser(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let firstName = args["firstName"] as? String
        let lastName = args["lastName"] as? String
        let email = args["email"] as? String
        let phone = args["phone"] as? String
        
        Task {
            await Blaink.shared.updateUser(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone
            )
            result(nil)
        }
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        // Set up Blaink SDK delegate
        Blaink.shared.delegate = BlainkDelegateWrapper(eventSink: events)
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        Blaink.shared.delegate = nil
        return nil
    }
}

// MARK: - BlainkDelegate Wrapper

class BlainkDelegateWrapper: BlainkDelegate {
    private let eventSink: FlutterEventSink
    
    init(eventSink: @escaping FlutterEventSink) {
        self.eventSink = eventSink
    }
    
    func didReceiveNotification(_ notification: UNNotification) {
        let payload = notification.request.content.userInfo
        let stringPayload = payload.compactMapValues { value in
            return String(describing: value)
        }
        
        eventSink([
            "type": "didReceiveNotification",
            "payload": stringPayload
        ])
    }
    
    func didRegisterForBlainkNotifications(userId: String) {
        eventSink([
            "type": "didRegisterForBlainkNotifications",
            "userId": userId
        ])
    }
    
    func didFailToRegisterForBlainkNotifications(error: Error) {
        eventSink([
            "type": "didFailToRegisterForBlainkNotifications",
            "error": error.localizedDescription
        ])
    }
}