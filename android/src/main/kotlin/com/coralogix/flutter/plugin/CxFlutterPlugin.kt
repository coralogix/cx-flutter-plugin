package com.coralogix.flutter.plugin

import android.app.Application
import com.coralogix.flutter.plugin.manager.FlutterPluginManager
import com.coralogix.flutter.plugin.manager.IFlutterPluginManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CxFlutterPlugin */
class CxFlutterPlugin: FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var methodChannel : MethodChannel
    private lateinit var pluginManager: IFlutterPluginManager
    private var eventSink: EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        EventChannel(
            flutterPluginBinding.binaryMessenger,
            "$METHOD_CHANNEL_NAME/onBeforeSend"
        ).setStreamHandler(object: EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink?) {
                eventSink = events
                if (::pluginManager.isInitialized) {
                    pluginManager.eventSink = eventSink
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        val application = flutterPluginBinding.applicationContext as Application
        pluginManager = FlutterPluginManager(application)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            INIT -> pluginManager.initialize(call, result)
            SET_NETWORK_REQUEST_CONTEXT -> pluginManager.reportNetworkRequest(call, result)
            SET_USER_CONTEXT -> pluginManager.setUserContext(call, result)
            SET_LABELS -> pluginManager.setLabels(call, result)
            LOG -> pluginManager.log(call, result)
            REPORT_ERROR -> pluginManager.reportError(call, result)
            SET_VIEW -> pluginManager.setView(call, result)
            SHUTDOWN -> pluginManager.shutdown(result)
            GET_LABELS -> pluginManager.getLabels(result)
            IS_INITIALIZED -> pluginManager.isInitialized(result)
            GET_SESSION_ID -> pluginManager.getSessionId(result)
            SET_APPLICATION_CONTEXT -> pluginManager.setApplicationContext(call, result)
            SEND_CX_SPAN_DATA -> pluginManager.sendCxSpanData(call, result)
            RECORD_FIRST_FRAME_TIME -> pluginManager.recordFirstFrameTime(result)
            SEND_CUSTOM_MEASUREMENT -> pluginManager.sendCustomMeasurement(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    companion object {
        private const val METHOD_CHANNEL_NAME = "cx_flutter_plugin"

        private const val INIT = "initSdk"
        private const val SET_NETWORK_REQUEST_CONTEXT = "setNetworkRequestContext"
        private const val SET_USER_CONTEXT = "setUserContext"
        private const val SET_LABELS = "setLabels"
        private const val LOG = "log"
        private const val REPORT_ERROR = "reportError"
        private const val SET_VIEW = "setView"
        private const val SHUTDOWN = "shutdown"
        private const val GET_LABELS = "getLabels"
        private const val IS_INITIALIZED = "isInitialized"
        private const val GET_SESSION_ID = "getSessionId"
        private const val SET_APPLICATION_CONTEXT = "setApplicationContext"
        private const val SEND_CX_SPAN_DATA = "sendCxSpanData"
        private const val RECORD_FIRST_FRAME_TIME = "recordFirstFrameTime"
        private const val SEND_CUSTOM_MEASUREMENT = "sendCustomMeasurement"
    }
}
