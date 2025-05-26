package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.ViewContext
import com.coralogix.flutter.plugin.mappers.IMapper

class ViewContextMapper : IMapper<ViewContext?, Map<String, Any?>?> {
    override fun toMap(input: ViewContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "viewName" to input.viewName,
            "activityName" to input.activityName,
            "fragmentName" to input.fragmentName
        )
    }

    override fun fromMap(input: Map<String, Any?>?): ViewContext? = input?.let {
        ViewContext(
            viewName = input["viewName"] as? String ?: "",
            activityName = input["activityName"] as? String ?: "",
            fragmentName = input["fragmentName"] as? String ?: ""
        )
    }
}