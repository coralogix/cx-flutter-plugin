package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.EditableCoralogixAndroidStackFrame
import com.coralogix.android.sdk.model.EditableErrorContext
import com.coralogix.flutter.plugin.mappers.IMapper

class EditableErrorContextMapper : IMapper<EditableErrorContext?, Map<String, Any?>?> {
    private val frameMapper = EditableCoralogixAndroidStackFrameMapper()

    override fun toMap(input: EditableErrorContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "message" to input.message,
            "type" to input.type,
            "isCrash" to input.isCrash,
            "stacktrace" to input.stacktrace?.map { frame ->
                if (frame is EditableCoralogixAndroidStackFrame)
                    frameMapper.toMap(frame)
            }
        )
    }

    @Suppress("UNCHECKED_CAST")
    override fun fromMap(input: Map<String, Any?>?): EditableErrorContext? = input?.let {
        EditableErrorContext(
            message = input["message"] as? String ?: "",
            type = input["type"] as? String ?: "",
            isCrash = input["isCrash"] as? Boolean ?: false,
            stacktrace = (input["stacktrace"] as? List<Map<String, Any?>>)?.map { frameMap ->
                frameMapper.fromMap(frameMap)
            }
        )
    }
}