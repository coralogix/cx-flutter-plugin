package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.CustomMeasurementContext
import com.coralogix.flutter.plugin.mappers.IMapper

class CustomMeasurementContextMapper : IMapper<CustomMeasurementContext?, Map<String, Any?>?> {
    override fun toMap(input: CustomMeasurementContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "name" to it.name,
            "value" to it.value
        )
    }

    override fun fromMap(input: Map<String, Any?>?): CustomMeasurementContext? = input?.let {
        CustomMeasurementContext(
            name = it["name"] as? String ?: "",
            value = it["value"] as? Long ?: 0
        )
    }
}