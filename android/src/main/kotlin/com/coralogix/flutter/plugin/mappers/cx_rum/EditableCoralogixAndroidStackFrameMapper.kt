package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.EditableCoralogixAndroidStackFrame
import com.coralogix.flutter.plugin.mappers.IMapper

class EditableCoralogixAndroidStackFrameMapper : IMapper<EditableCoralogixAndroidStackFrame, Map<String, Any?>> {
    override fun toMap(input: EditableCoralogixAndroidStackFrame): Map<String, Any?> = mapOf(
        "className" to input.className,
        "methodName" to input.methodName,
        "lineNumber" to input.lineNumber,
        "fileName" to input.fileName
    )

    override fun fromMap(input: Map<String, Any?>) = EditableCoralogixAndroidStackFrame(
        className = input["className"] as? String ?: "",
        methodName = input["methodName"] as? String ?: "",
        lineNumber = input["lineNumber"] as? Int ?: 0,
        fileName = input["fileName"] as? String ?: ""
    )
}