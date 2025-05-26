package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.ViewContext
import com.coralogix.flutter.plugin.mappers.IMapper

class ViewContextMapper : IMapper<ViewContext?, Map<String, Any?>?> {
    override fun toMap(input: ViewContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "viewName" to it.viewName,
            "activityName" to it.activityName,
            "fragmentName" to it.fragmentName
        )
    }

    override fun fromMap(input: Map<String, Any?>?): ViewContext? = input?.let {
        ViewContext(
            viewName = it["viewName"] as? String ?: "",
            activityName = it["activityName"] as? String ?: "",
            fragmentName = it["fragmentName"] as? String ?: ""
        )
    }
}