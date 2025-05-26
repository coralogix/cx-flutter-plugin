package com.coralogix.flutter.plugin.manager

import android.app.Application
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.coralogix.android.sdk.CoralogixRum
import com.coralogix.android.sdk.internal.features.instrumentations.network.NetworkRequestDetails
import com.coralogix.android.sdk.model.CoralogixLogSeverity
import com.coralogix.android.sdk.model.CoralogixOptions
import com.coralogix.android.sdk.model.EditableCxRum
import com.coralogix.android.sdk.model.Framework
import com.coralogix.android.sdk.model.UserContext
import com.coralogix.flutter.plugin.extensions.error
import com.coralogix.flutter.plugin.extensions.invalidArgumentsError
import com.coralogix.flutter.plugin.extensions.success
import com.coralogix.flutter.plugin.extensions.toStringAnyMap
import com.coralogix.flutter.plugin.extensions.toStringBooleanMap
import com.coralogix.flutter.plugin.extensions.toStringList
import com.coralogix.flutter.plugin.extensions.toStringMap
import com.coralogix.flutter.plugin.extensions.toUserContext
import com.coralogix.flutter.plugin.factories.ThrowableFactory
import com.coralogix.flutter.plugin.mappers.CoralogixDomainMapper
import com.coralogix.flutter.plugin.mappers.CoralogixLogSeverityMapper
import com.coralogix.flutter.plugin.mappers.InstrumentationMapper
import com.coralogix.flutter.plugin.mappers.cx_rum.EditableCxRumMapper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

internal class FlutterPluginManager(
    private val application: Application,
    private val methodChannel: MethodChannel
) : IFlutterPluginManager {
    override fun initialize(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val optionsDetails = arguments.toStringAnyMap()
        val labels = (optionsDetails["labels"] as? Map<*, *>)?.toStringMap()
        val ignoreUrls = (optionsDetails["ignoreUrls"] as? List<*>)?.toStringList()
        val ignoreErrors = (optionsDetails["ignoreErrors"] as? List<*>)?.toStringList()

        val userContextMap = (optionsDetails["userContext"] as? Map<*, *>)?.toStringMap()
        val userContext = userContextMap?.toUserContext() ?: UserContext()

        val instrumentationsMap = (optionsDetails["instrumentations"] as? Map<*, *>)?.toStringBooleanMap() ?: emptyMap()
        val instrumentations = InstrumentationMapper.toMap(instrumentationsMap)

        val domainString = optionsDetails["coralogixDomain"] as? String ?: ""
        val domain = CoralogixDomainMapper.toMap(domainString) ?: run {
            result.error("Failed to parse Coralogix domain")
            return
        }

        val options = CoralogixOptions(
            applicationName = optionsDetails["application"] as? String ?: "",
            coralogixDomain = domain,
            publicKey = optionsDetails["publicKey"] as? String ?: "",
            labels = labels ?: emptyMap(),
            environment = optionsDetails["environment"] as? String ?: "",
            version = optionsDetails["version"] as? String ?: "",
            userContext = userContext,
            instrumentations = instrumentations,
            ignoreUrls = ignoreUrls ?: emptyList(),
            ignoreErrors = ignoreErrors ?: emptyList(),
            collectIPData = optionsDetails["collectIPData"] as? Boolean ?: true,
            sessionSampleRate = optionsDetails["sdkSampler"] as? Int ?: 100,
            fpsSamplingSeconds = optionsDetails["mobileVitalsFPSSamplingRate"] as? Long ?: 300,
            proxyUrl = optionsDetails["proxyUrl"] as? String,
            debug = optionsDetails["debug"] as? Boolean ?: false,
            beforeSend = { rum -> runBlocking { beforeSendHandler(rum) } }
        )

        CoralogixRum.initialize(application, options, Framework.Flutter)
        result.success()
    }

    private suspend fun beforeSendHandler(rum: EditableCxRum): EditableCxRum {
        val cxRumMapper = EditableCxRumMapper()
        val map = cxRumMapper.toMap(rum)

        // Switch only the methodChannel call to main
        val modifiedMap = suspendCancellableCoroutine<Map<String, Any?>> { continuation ->
            Handler(Looper.getMainLooper()).post {
                methodChannel.invokeMethod("onBeforeSend", map, object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        Log.d("FlutterPluginManager", "onBeforeSend success: $result")
                        val resultMap = when (result) {
                            null -> null
                            is Map<*, *> -> {
                                result.entries.mapNotNull { entry ->
                                    (entry.key as? String)?.let { key -> key to entry.value }
                                }.toMap()
                            }
                            else -> {
                                Log.w("FlutterPluginManager", "Unexpected result type: ${result::class.java}")
                                map
                            }
                        } ?: map
                        continuation.resume(resultMap)
                    }

                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        Log.d("FlutterPluginManager", "onBeforeSend error: $errorCode : $errorMessage : $errorDetails")
                        continuation.resume(map)
                    }

                    override fun notImplemented() {
                        Log.d("FlutterPluginManager", "onBeforeSend notImplemented")
                        continuation.resume(map)
                    }
                })
            }
        }

        return cxRumMapper.fromMap(modifiedMap)
    }

    override fun reportNetworkRequest(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val networkRequestDetailsMap = arguments.toStringAnyMap()
        val statusCode = networkRequestDetailsMap["status_code"] as? Int ?: 0
        val severity = if (statusCode >= ERROR_STATUS_CODE) {
            CoralogixLogSeverity.Error.level.toString()
        } else {
            CoralogixLogSeverity.Info.level.toString()
        }

        val networkRequestDetails = NetworkRequestDetails(
            method = networkRequestDetailsMap["method"] as? String ?: "",
            statusCode = statusCode,
            url = networkRequestDetailsMap["url"] as? String ?: "",
            fragments = networkRequestDetailsMap["fragments"] as? String ?: "",
            host = networkRequestDetailsMap["host"] as? String ?: "",
            schema = networkRequestDetailsMap["schema"] as? String ?: "",
            duration = networkRequestDetailsMap["duration"] as? Long ?: 0L,
            responseContentLength = networkRequestDetailsMap["http_response_body_size"] as? Long ?: 0L,
            severity = severity
        )

        CoralogixRum.reportNetworkRequest(networkRequestDetails)
        result.success()
    }

    override fun setUserContext(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        CoralogixRum.setUserContext(arguments.toUserContext())
        result.success()
    }

    override fun setLabels(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        CoralogixRum.setLabels(arguments.toStringMap())
        result.success()
    }

    override fun log(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val logDetails = arguments.toStringAnyMap()
        val message = logDetails["message"] as? String ?: ""

        val dataMap = logDetails["data"] as? Map<*, *>
        val data = dataMap?.toStringMap() ?: emptyMap()

        val severityLevel = logDetails["severity"] as? String ?: ""
        val severity = CoralogixLogSeverityMapper.toMap(severityLevel) ?: run {
            result.error("Failed to parse log severity")
            return
        }

        CoralogixRum.log(severity, message, data)
        result.success()
    }

    override fun reportError(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val errorDetails = arguments.toStringMap()
        val message = errorDetails["message"] ?: ""
        val stackTrace = errorDetails["stackTrace"] ?: ""

        val throwable = ThrowableFactory.create(message, stackTrace)
        CoralogixRum.reportError(throwable)

        result.success()
    }

    override fun setView(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val viewDetails = arguments.toStringMap()
        val viewName = viewDetails["viewName"] ?: ""
        CoralogixRum.setViewContext(viewName)
        result.success()
    }

    override fun shutdown(result: MethodChannel.Result) {
        CoralogixRum.shutdown()
        result.success()
    }

    override fun getLabels(result: MethodChannel.Result) {
        val labels = CoralogixRum.getLabels()
        result.success(labels)
    }

    override fun isInitialized(result: MethodChannel.Result) {
        val isInitialized = CoralogixRum.isInitialized()
        result.success(isInitialized)
    }

    override fun getSessionId(result: MethodChannel.Result) {
        val sessionId = CoralogixRum.getSessionId()
        result.success(sessionId)
    }

    override fun setApplicationContext(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val applicationContextDetails = arguments.toStringMap()
        val applicationName = applicationContextDetails["applicationName"] ?: ""
        val applicationVersion = applicationContextDetails["applicationVersion"] ?: ""

        CoralogixRum.setApplicationContext(applicationName, applicationVersion)
        result.success()
    }

    override fun sendCxSpanData(result: MethodChannel.Result) {
        // NO OP
        result.success()
    }

    companion object {
        private const val ERROR_STATUS_CODE = 400
    }
}