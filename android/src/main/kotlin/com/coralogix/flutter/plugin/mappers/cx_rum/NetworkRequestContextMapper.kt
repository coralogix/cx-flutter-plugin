package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.NetworkRequestContext
import com.coralogix.flutter.plugin.mappers.IMapper

class NetworkRequestContextMapper : IMapper<NetworkRequestContext?, Map<String, Any?>?> {
    override fun toMap(input: NetworkRequestContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "method" to input.method,
            "statusCode" to input.statusCode,
            "url" to input.url,
            "fragments" to input.fragments,
            "host" to input.host,
            "schema" to input.schema,
            "statusText" to input.statusText,
            "duration" to input.duration,
            "responseContentLength" to input.responseContentLength
        )
    }

    override fun fromMap(input: Map<String, Any?>?): NetworkRequestContext? = input?.let {
        NetworkRequestContext(
            method = input["method"] as? String ?: "",
            statusCode = input["statusCode"] as? Int ?: 0,
            url = input["url"] as? String ?: "",
            fragments = input["fragments"] as? String ?: "",
            host = input["host"] as? String ?: "",
            schema = input["schema"] as? String ?: "",
            statusText = input["statusText"] as? String ?: "",
            duration = input["duration"] as? Long ?: 0,
            responseContentLength = input["responseContentLength"] as? String ?: "0"
        )
    }
}