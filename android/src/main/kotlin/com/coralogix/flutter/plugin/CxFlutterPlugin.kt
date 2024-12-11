package com.coralogix.flutter.plugin

import android.app.Application
import com.coralogix.android.sdk.CoralogixRum
import com.coralogix.android.sdk.internal.features.instrumentations.network.NetworkRequestDetails
import com.coralogix.android.sdk.model.CoralogixDomain
import com.coralogix.android.sdk.model.CoralogixLogSeverity
import com.coralogix.android.sdk.model.CoralogixOptions
import com.coralogix.android.sdk.model.Framework
import com.coralogix.android.sdk.model.Instrumentation
import com.coralogix.android.sdk.model.UserContext
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject

/** CxFlutterPlugin */
class CxFlutterPlugin: FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    private lateinit var application: Application

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cx_flutter_plugin")
        channel.setMethodCallHandler(this)

        application = flutterPluginBinding.applicationContext as Application
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            INIT -> initSdk(call, result)
            SET_NETWORK_REQUEST_CONTEXT -> setNetworkRequestContext(call, result)
            SET_USER_CONTEXT -> setUserContext(call, result)
            SET_LABELS -> setLabels(call, result)
            LOG -> log(call, result)
            REPORT_ERROR -> reportError(call, result)
            SET_VIEW -> setView(call, result)
            SHUTDOWN -> shutdown(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initSdk(call: MethodCall, result: Result) {
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

        val instrumentationsMap = (optionsDetails["instrumentations"] as? Map<*, *>)?.toStringBooleanMap()
        val instrumentations = instrumentationsMap?.mapNotNull { (key, value) ->
            val instrumentation = when (key) {
                "mobileVitals" -> Instrumentation.MobileVitals
                "custom" -> Instrumentation.Custom
                "errors" -> Instrumentation.Error
                "network" -> Instrumentation.Network
                "anr" -> Instrumentation.Anr
                "lifeCycle" -> Instrumentation.Lifecycle
                else -> null
            }

            instrumentation?.let { it to value }
        }?.toMap()

        val domainString = optionsDetails["coralogixDomain"] as? String
        val domain = when (domainString) {
            CoralogixDomain.AP1.url -> CoralogixDomain.AP1
            CoralogixDomain.AP2.url -> CoralogixDomain.AP2
            CoralogixDomain.AP3.url -> CoralogixDomain.AP3
            CoralogixDomain.EU1.url -> CoralogixDomain.EU1
            CoralogixDomain.EU2.url -> CoralogixDomain.EU2
            CoralogixDomain.US1.url -> CoralogixDomain.US1
            CoralogixDomain.US2.url -> CoralogixDomain.US2
            else -> {
                result.error("Failed to parse Coralogix domain")
                return
            }
        }

        val options = CoralogixOptions(
            applicationName = optionsDetails["application"] as? String ?: "",
            coralogixDomain = domain,
            publicKey = optionsDetails["publicKey"] as? String ?: "",
            labels = labels ?: emptyMap(),
            environment = optionsDetails["environment"] as? String ?: "",
            version = optionsDetails["version"] as? String ?: "",
            userContext = userContext,
            instrumentations = instrumentations ?: emptyMap(),
            ignoreUrls = ignoreUrls ?: emptyList(),
            ignoreErrors = ignoreErrors ?: emptyList(),
            collectIPData = optionsDetails["collectIPData"] as? Boolean ?: true,
            sessionSampleRate = optionsDetails["sdkSampler"] as? Int ?: 100,
            fpsSamplingSeconds = optionsDetails["mobileVitalsFPSSamplingRate"] as? Long ?: 300,
            customDomainUrl = optionsDetails["customDomainUrl"] as? String ?: "",
            debug = optionsDetails["debug"] as? Boolean ?: false
        )

        CoralogixRum.initialize(application, options, Framework.Flutter)
        result.success()
    }

    private fun setNetworkRequestContext(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val networkRequestDetailsMap = arguments.toStringAnyMap()
        val statusCode = networkRequestDetailsMap["status_code"] as? Int ?: 0
        val networkRequestDetails = NetworkRequestDetails(
            method = networkRequestDetailsMap["method"] as? String ?: "",
            statusCode = statusCode,
            url = networkRequestDetailsMap["url"] as? String ?: "",
            fragments = networkRequestDetailsMap["fragments"] as? String ?: "",
            host = networkRequestDetailsMap["host"] as? String ?: "",
            schema = networkRequestDetailsMap["schema"] as? String ?: "",
            duration = networkRequestDetailsMap["duration"] as? Long ?: 0L,
            responseContentLength = networkRequestDetailsMap["http_response_body_size"] as? Long ?: 0L,
            severity = getSeverity(statusCode)
        )

        CoralogixRum.reportNetworkRequest(networkRequestDetails)
        result.success()
    }

    private fun setUserContext(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        CoralogixRum.setUserContext(arguments.toUserContext())
        result.success()
    }

    private fun setLabels(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        CoralogixRum.setLabels(arguments.toStringMap())
        result.success()
    }

    private fun log(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val logDetails = arguments.toStringAnyMap()
        val message = logDetails["message"] as? String ?: ""

        val dataMap = logDetails["data"] as? Map<*, *>
        val data = dataMap?.toStringMap() ?: emptyMap()

        val severityLevel = (logDetails["severity"] as? String)?.toIntOrNull() ?: 5
        val severity = when (severityLevel) {
            1 -> CoralogixLogSeverity.Debug
            2 -> CoralogixLogSeverity.Verbose
            3 -> CoralogixLogSeverity.Info
            4 -> CoralogixLogSeverity.Warn
            5 -> CoralogixLogSeverity.Error
            6 -> CoralogixLogSeverity.Critical
            else -> {
                result.error("Failed to parse log severity")
                return
            }
        }

        CoralogixRum.log(severity, message, data)
        result.success()
    }

    private fun reportError(call: MethodCall, result: Result) {
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

    private fun setView(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null || arguments.isEmpty()) {
            result.invalidArgumentsError()
            return
        }

        val viewDetails = arguments.toStringMap()
        CoralogixRum.setViewContext(viewDetails["viewName"] ?: "")
        result.success()
    }

    private fun shutdown(result: Result) {
        CoralogixRum.shutdown()
        result.success()
    }

    private fun Result.invalidArgumentsError() {
        error("4", "Arguments is null or empty", null)
    }

    private fun Result.error(description: String) {
        error("4", description, null)
    }

    private fun Result.success() = success("")

    private fun Map<*, *>.toStringMap(): Map<String, String> {
        return mapNotNull { (key, value) ->
            if (key is String) {
                value?.toString()?.let { stringValue -> key to stringValue }
            } else {
                null
            }
        }.toMap()
    }

    private fun Map<*, *>.toStringAnyMap(): Map<String, Any> {
        return mapNotNull { (key, value) ->
            if (key is String && value != null) {
                val processedValue: Any = if (value is Map<*, *>) {
                    value.toStringAnyMap()
                } else {
                    value
                }
                key to processedValue
            } else {
                null
            }
        }.toMap()
    }

    private fun Map<*, *>.toStringBooleanMap(): Map<String, Boolean> {
        return mapNotNull { (key, value) ->
            if (key is String) {
                (value as? Boolean)?.let { v -> key to v }
            } else {
                null
            }
        }.toMap()
    }

    private fun Map<*, *>.toUserContext(): UserContext {
        val userContextDetails = toStringMap()
        val userMetadataRaw = userContextDetails["userMetadata"]
        val userMetadata: Map<String, String> = try {
            val jsonObject = userMetadataRaw?.let { JSONObject(it) }
            jsonObject?.keys()?.asSequence()?.associateWith { key -> jsonObject.getString(key) } ?: emptyMap()
        } catch (e: Exception) {
            emptyMap()
        }

        return UserContext(
            userId = userContextDetails["userId"] ?: "",
            username = userContextDetails["userName"] ?: "",
            email = userContextDetails["userEmail"] ?: "",
            metadata = userMetadata
        )
    }

    private fun List<*>.toStringList(): List<String> {
        return mapNotNull { it as? String }
    }

    private fun getSeverity(statusCode: Int): String {
        return if (statusCode >= ERROR_STATUS_CODE) {
            CoralogixLogSeverity.Error.level.toString()
        } else {
            CoralogixLogSeverity.Info.level.toString()
        }
    }

    companion object {
        private const val INIT = "initSdk"
        private const val SET_NETWORK_REQUEST_CONTEXT = "setNetworkRequestContext"
        private const val SET_USER_CONTEXT = "setUserContext"
        private const val SET_LABELS = "setLabels"
        private const val LOG = "log"
        private const val REPORT_ERROR = "reportError"
        private const val SET_VIEW = "setView"
        private const val SHUTDOWN = "shutdown"

        private const val ERROR_STATUS_CODE = 400
    }
}
