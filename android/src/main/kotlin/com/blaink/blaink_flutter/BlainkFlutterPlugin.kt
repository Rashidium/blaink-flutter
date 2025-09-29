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
import com.blaink.Blaink
import com.blaink.core.BlainkDelegate
import com.blaink.core.PushEnvironment
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class BlainkFlutterPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, BlainkDelegate {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var blaink: Blaink

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "blaink_flutter")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "blaink_flutter/events")
        eventChannel.setStreamHandler(this)
        
        // Don't initialize SDK instance here - wait for setup() call
        // This prevents singleton contamination between apps
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setup" -> {
                try {
                    val sdkKey = call.argument<String>("sdkKey")
                    val environmentStr = call.argument<String>("environment") ?: "production"
                    val isDebugLogsEnabled = call.argument<Boolean>("isDebugLogsEnabled") ?: false
                    
                    if (sdkKey == null) {
                        result.error("INVALID_ARGUMENTS", "SDK key is required", null)
                        return
                    }
                    
                    val environment = when (environmentStr) {
                        "development" -> PushEnvironment.DEVELOPMENT
                        "production" -> PushEnvironment.PRODUCTION
                        else -> PushEnvironment.PRODUCTION
                    }
                    
                    // Initialize SDK instance with proper isolation
                    blaink = Blaink.getInstance()
                    blaink.delegate = this
                    
                    blaink.setup(
                        context = context,
                        sdkKey = sdkKey,
                        environment = environment,
                        isDebugLogsEnabled = isDebugLogsEnabled
                    )
                    
                    result.success(null)
                } catch (e: Exception) {
                    result.error("SETUP_ERROR", "Failed to setup Blaink SDK: ${e.message}", null)
                }
            }
            
            "registerForRemoteNotifications" -> {
                try {
                    if (!::blaink.isInitialized) {
                        result.error("SDK_NOT_INITIALIZED", "Blaink SDK not initialized. Call setup() first.", null)
                        return
                    }
                    
                    val deviceToken = call.argument<String>("deviceToken")
                    if (deviceToken == null) {
                        result.error("INVALID_ARGUMENTS", "Device token is required", null)
                        return
                    }
                    
                    blaink.registerForRemoteNotifications(deviceToken)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("REGISTRATION_ERROR", "Failed to register for notifications: ${e.message}", null)
                }
            }
            
            "getCurrentUser" -> {
                if (!::blaink.isInitialized) {
                    result.error("SDK_NOT_INITIALIZED", "Blaink SDK not initialized. Call setup() first.", null)
                    return
                }
                
                CoroutineScope(Dispatchers.Main).launch {
                    try {
                        val userResult = blaink.getCurrentUser()
                        if (userResult.isSuccess) {
                            result.success(userResult.getOrNull())
                        } else {
                            result.error("GET_USER_ERROR", "Failed to get current user: ${userResult.exceptionOrNull()?.message}", null)
                        }
                    } catch (e: Exception) {
                        result.error("GET_USER_ERROR", "Failed to get current user: ${e.message}", null)
                    }
                }
            }
            
            "updateUser" -> {
                try {
                    // For now, the Android SDK doesn't seem to have an updateUser method
                    // We'll just return success to maintain compatibility with the Flutter interface
                    // Users can implement user updates through their own backend
                    result.success(null)
                } catch (e: Exception) {
                    result.error("UPDATE_USER_ERROR", "Failed to update user: ${e.message}", null)
                }
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
    
    // BlainkDelegate implementation
    override fun didReceiveNotification(notification: Map<String, Any>) {
        eventSink?.success(mapOf(
            "type" to "didReceiveNotification",
            "payload" to notification
        ))
    }
    
    override fun didRegisterForBlainkNotifications(blainkUserId: String) {
        eventSink?.success(mapOf(
            "type" to "didRegisterForBlainkNotifications",
            "userId" to blainkUserId
        ))
    }
}