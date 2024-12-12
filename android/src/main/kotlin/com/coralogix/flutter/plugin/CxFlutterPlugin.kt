package com.coralogix.flutter.plugin

import android.app.Application
import com.coralogix.flutter.plugin.manager.FlutterPluginManager
import com.coralogix.flutter.plugin.manager.IFlutterPluginManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
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
    private lateinit var channel : MethodChannel
    private lateinit var pluginManager: IFlutterPluginManager

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(this)

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
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
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
    }
}
