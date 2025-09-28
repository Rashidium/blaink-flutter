//
//  BlainkFlutterPlugin.kt
//  Blaink Flutter SDK
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

package com.blaink.blaink_flutter

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class BlainkFlutterPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "blaink_flutter")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "blaink_flutter/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setup" -> {
                // For now, return success to test Android v2 embedding
                result.success(null)
            }
            
            "registerForRemoteNotifications" -> {
                // For now, return success to test Android v2 embedding
                result.success(null)
            }
            
            "getCurrentUser" -> {
                // Return a test user ID
                result.success("test-user-123")
            }
            
            "updateUser" -> {
                // For now, return success to test Android v2 embedding
                result.success(null)
            }
            
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}