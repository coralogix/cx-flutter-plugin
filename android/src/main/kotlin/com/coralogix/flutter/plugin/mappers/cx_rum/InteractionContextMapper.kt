package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.InteractionContext
import com.coralogix.flutter.plugin.mappers.IMapper

class InteractionContextMapper : IMapper<InteractionContext?, Map<String, Any?>?> {
    override fun toMap(input: InteractionContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "eventName" to it.eventName,
            "targetId" to it.targetId,
            "targetClassName" to it.targetClassName
        )
    }

    override fun fromMap(input: Map<String, Any?>?): InteractionContext? = input?.let {
        InteractionContext(
            eventName = it["eventName"] as? String ?: "",
            targetId = it["targetId"] as? String ?: "",
            targetClassName = it["targetClassName"] as? String ?: ""
        )
    }
}