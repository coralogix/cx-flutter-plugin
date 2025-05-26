package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.CustomMeasurementContext
import com.coralogix.flutter.plugin.mappers.IMapper

class CustomMeasurementContextMapper : IMapper<CustomMeasurementContext?, Map<String, Any?>?> {
    override fun toMap(input: CustomMeasurementContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "name" to input.name,
            "value" to input.value
        )
    }

    override fun fromMap(input: Map<String, Any?>?): CustomMeasurementContext? = input?.let {
        CustomMeasurementContext(
            name = input["name"] as? String ?: "",
            value = input["value"] as? Long ?: 0
        )
    }
}