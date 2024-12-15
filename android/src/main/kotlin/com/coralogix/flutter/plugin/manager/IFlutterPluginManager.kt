package com.coralogix.flutter.plugin.manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

internal interface IFlutterPluginManager {
    fun initialize(call: MethodCall, result: Result)
    fun reportNetworkRequest(call: MethodCall, result: Result)
    fun setUserContext(call: MethodCall, result: Result)
    fun setLabels(call: MethodCall, result: Result)
    fun log(call: MethodCall, result: Result)
    fun reportError(call: MethodCall, result: Result)
    fun setView(call: MethodCall, result: Result)
    fun shutdown(result: Result)
}