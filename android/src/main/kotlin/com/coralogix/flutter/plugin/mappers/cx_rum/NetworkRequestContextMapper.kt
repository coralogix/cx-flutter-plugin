package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.NetworkRequestContext
import com.coralogix.flutter.plugin.mappers.IMapper

class NetworkRequestContextMapper : IMapper<NetworkRequestContext?, Map<String, Any?>?> {
    override fun toMap(input: NetworkRequestContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "method" to it.method,
            "statusCode" to it.statusCode,
            "url" to it.url,
            "fragments" to it.fragments,
            "host" to it.host,
            "schema" to it.schema,
            "statusText" to it.statusText,
            "duration" to it.duration,
            "responseContentLength" to it.responseContentLength
        )
    }

    override fun fromMap(input: Map<String, Any?>?): NetworkRequestContext? = input?.let {
        NetworkRequestContext(
            method = it["method"] as? String ?: "",
            statusCode = it["statusCode"] as? Int ?: 0,
            url = it["url"] as? String ?: "",
            fragments = it["fragments"] as? String ?: "",
            host = it["host"] as? String ?: "",
            schema = it["schema"] as? String ?: "",
            statusText = it["statusText"] as? String ?: "",
            duration = it["duration"] as? Long ?: 0,
            responseContentLength = it["responseContentLength"] as? String ?: "0"
        )
    }
}