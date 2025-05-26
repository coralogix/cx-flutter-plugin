package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.InteractionContext
import com.coralogix.flutter.plugin.mappers.IMapper

class InteractionContextMapper : IMapper<InteractionContext?, Map<String, Any?>?> {
    override fun toMap(input: InteractionContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "eventName" to input.eventName,
            "targetId" to input.targetId,
            "targetClassName" to input.targetClassName
        )
    }

    override fun fromMap(input: Map<String, Any?>?): InteractionContext? = input?.let {
        InteractionContext(
            eventName = input["eventName"] as? String ?: "",
            targetId = input["targetId"] as? String ?: "",
            targetClassName = input["targetClassName"] as? String ?: ""
        )
    }
}