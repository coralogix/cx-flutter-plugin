package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.EventContext
import com.coralogix.flutter.plugin.mappers.IMapper

class EventContextMapper : IMapper<EventContext?, Map<String, Any?>?> {
    override fun toMap(input: EventContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "severity" to it.severity,
            "type" to it.type
        )
    }

    override fun fromMap(input: Map<String, Any?>?): EventContext? = input?.let {
        EventContext(
            severity = it["severity"] as? Int ?: 0,
            type = it["type"] as? String ?: ""
        )
    }
}