package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.LogContext
import com.coralogix.flutter.plugin.mappers.IMapper

class LogContextMapper : IMapper<LogContext?, Map<String, Any?>?> {
    override fun toMap(input: LogContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "message" to it.message,
            "data" to it.data
        )
    }

    override fun fromMap(input: Map<String, Any?>?): LogContext? = input?.let {
        LogContext(
            message = it["message"] as? String ?: "",
            data = it["data"] as? String ?: ""
        )
    }
}