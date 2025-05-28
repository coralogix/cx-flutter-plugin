package com.coralogix.flutter.plugin.manager

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

internal interface IFlutterPluginManager {
    var eventSink: EventChannel.EventSink?

    fun initialize(call: MethodCall, result: Result)
    fun reportNetworkRequest(call: MethodCall, result: Result)
    fun setUserContext(call: MethodCall, result: Result)
    fun setLabels(call: MethodCall, result: Result)
    fun log(call: MethodCall, result: Result)
    fun reportError(call: MethodCall, result: Result)
    fun setView(call: MethodCall, result: Result)
    fun shutdown(result: Result)
    fun getLabels(result: Result)
    fun isInitialized(result: Result)
    fun getSessionId(result: Result)
    fun setApplicationContext(call: MethodCall, result: Result)
    fun sendCxSpanData(call: MethodCall, result: Result)
}