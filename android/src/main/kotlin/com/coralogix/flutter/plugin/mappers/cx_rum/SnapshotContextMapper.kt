package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.SnapshotContext
import com.coralogix.flutter.plugin.mappers.IMapper

class SnapshotContextMapper : IMapper<SnapshotContext?, Map<String, Any?>?> {
    override fun toMap(input: SnapshotContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "viewCount" to input.viewCount,
            "errorCount" to input.errorCount,
            "actionCount" to input.actionCount
        )
    }

    override fun fromMap(input: Map<String, Any?>?): SnapshotContext? = input?.let {
        SnapshotContext(
            viewCount = input["viewCount"] as? Int ?: 0,
            errorCount = input["errorCount"] as? Int ?: 0,
            actionCount = input["actionCount"] as? Int ?: 0
        )
    }
}