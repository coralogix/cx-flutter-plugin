package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.LifecycleContext
import com.coralogix.flutter.plugin.mappers.IMapper

class LifecycleContextMapper : IMapper<LifecycleContext?, Map<String, Any?>?> {
    override fun toMap(input: LifecycleContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "event" to input.event,
            "screenView" to input.screenView
        )
    }

    override fun fromMap(input: Map<String, Any?>?): LifecycleContext? = input?.let {
        LifecycleContext(
            event = input["event"] as? String ?: "",
            screenView = input["screenView"] as? String ?: ""
        )
    }
}