//
//  BlainkFlutterPlugin.kt
//  Blaink Flutter SDK
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

package com.blaink.blaink_flutter

import android.content.Context
import com.blaink.Blaink as BlainkSDK
import com.blaink.core.PushEnvironment
import com.blaink.core.BlainkDelegate
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

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
                val sdkKey = call.argument<String>("sdkKey") ?: ""
                val environmentStr = call.argument<String>("environment") ?: "production"
                val isDebugLogsEnabled = call.argument<Boolean>("isDebugLogsEnabled") ?: false
                
                val environment = when (environmentStr) {
                    "development" -> PushEnvironment.DEVELOPMENT
                    "production" -> PushEnvironment.PRODUCTION
                    else -> PushEnvironment.PRODUCTION
                }

                CoroutineScope(Dispatchers.Main).launch {
                    try {
                        BlainkSDK.setup(
                            context = context,
                            sdkKey = sdkKey,
                            environment = environment,
                            isDebugLogsEnabled = isDebugLogsEnabled
                        )
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("SETUP_ERROR", e.message, null)
                    }
                }
            }
            
            "registerForRemoteNotifications" -> {
                val deviceToken = call.argument<String>("deviceToken") ?: ""
                CoroutineScope(Dispatchers.Main).launch {
                    try {
                        BlainkSDK.registerForRemoteNotifications(deviceToken)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("REGISTER_ERROR", e.message, null)
                    }
                }
            }
            
            "getCurrentUser" -> {
                CoroutineScope(Dispatchers.Main).launch {
                    try {
                        val userId = BlainkSDK.getCurrentUser()
                        result.success(userId)
                    } catch (e: Exception) {
                        result.error("GET_USER_ERROR", e.message, null)
                    }
                }
            }
            
            "updateUser" -> {
                val firstName = call.argument<String>("firstName")
                val lastName = call.argument<String>("lastName")
                val email = call.argument<String>("email")
                val phone = call.argument<String>("phone")
                
                CoroutineScope(Dispatchers.Main).launch {
                    try {
                        BlainkSDK.updateUser(
                            firstName = firstName,
                            lastName = lastName,
                            email = email,
                            phone = phone
                        )
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UPDATE_USER_ERROR", e.message, null)
                    }
                }
            }
            
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        
        // Set up Blaink SDK delegate
        BlainkSDK.delegate = object : BlainkDelegate {
            override fun didReceiveNotification(payload: Map<String, String>) {
                eventSink?.success(mapOf(
                    "type" to "didReceiveNotification",
                    "payload" to payload
                ))
            }

            override fun didRegisterForBlainkNotifications(userId: String) {
                eventSink?.success(mapOf(
                    "type" to "didRegisterForBlainkNotifications",
                    "userId" to userId
                ))
            }

            override fun didFailToRegisterForBlainkNotifications(error: String) {
                eventSink?.success(mapOf(
                    "type" to "didFailToRegisterForBlainkNotifications",
                    "error" to error
                ))
            }

            override fun didRefreshFCMToken(newToken: String) {
                eventSink?.success(mapOf(
                    "type" to "didRefreshFCMToken",
                    "newToken" to newToken
                ))
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        BlainkSDK.delegate = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}