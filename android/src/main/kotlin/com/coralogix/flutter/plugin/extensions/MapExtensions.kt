package com.coralogix.flutter.plugin.extensions

import com.coralogix.android.sdk.model.UserContext
import org.json.JSONObject

internal fun Map<*, *>.toStringMap(): Map<String, String> {
    return mapNotNull { (key, value) ->
        if (key is String) {
            value?.toString()?.let { stringValue -> key to stringValue }
        } else {
            null
        }
    }.toMap()
}

internal fun Map<*, *>.toStringAnyMap(): Map<String, Any> {
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

internal fun Map<*, *>.toStringBooleanMap(): Map<String, Boolean> {
    return mapNotNull { (key, value) ->
        if (key is String) {
            (value as? Boolean)?.let { v -> key to v }
        } else {
            null
        }
    }.toMap()
}

internal fun Map<*, *>.toUserContext(): UserContext {
    val userContextDetails = toStringMap()
    val userMetadataRaw = userContextDetails["user_metadata"]
    val userMetadata: Map<String, String> = try {
        val jsonObject = userMetadataRaw?.let { JSONObject(it) }
        jsonObject?.keys()?.asSequence()?.associateWith { key -> jsonObject.getString(key) } ?: emptyMap()
    } catch (e: Exception) {
        emptyMap()
    }

    return UserContext(
        userId = userContextDetails["user_id"] ?: "",
        username = userContextDetails["user_name"] ?: "",
        email = userContextDetails["user_email"] ?: "",
        metadata = userMetadata
    )
}