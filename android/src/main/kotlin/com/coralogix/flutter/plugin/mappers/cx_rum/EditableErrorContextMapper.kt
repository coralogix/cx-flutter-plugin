package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.EditableCoralogixAndroidStackFrame
import com.coralogix.android.sdk.model.EditableErrorContext
import com.coralogix.flutter.plugin.mappers.IMapper

class EditableErrorContextMapper : IMapper<EditableErrorContext?, Map<String, Any?>?> {
    private val frameMapper = EditableCoralogixAndroidStackFrameMapper()

    override fun toMap(input: EditableErrorContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "message" to it.message,
            "type" to it.type,
            "isCrash" to it.isCrash,
            "stacktrace" to it.stacktrace?.mapNotNull { frame ->
                (frame as? EditableCoralogixAndroidStackFrame)?.let { androidFrame ->
                    frameMapper.toMap(androidFrame)
                }
            }
        )
    }

    @Suppress("UNCHECKED_CAST")
    override fun fromMap(input: Map<String, Any?>?): EditableErrorContext? = input?.let {
        EditableErrorContext(
            message = it["message"] as? String ?: "",
            type = it["type"] as? String ?: "",
            isCrash = it["isCrash"] as? Boolean ?: false,
            stacktrace = (it["stacktrace"] as? List<Map<String, Any?>>)?.map { frameMap ->
                frameMapper.fromMap(frameMap)
            }
        )
    }
}