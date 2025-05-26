package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.SnapshotContext
import com.coralogix.flutter.plugin.mappers.IMapper

class SnapshotContextMapper : IMapper<SnapshotContext?, Map<String, Any?>?> {
    override fun toMap(input: SnapshotContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "viewCount" to it.viewCount,
            "errorCount" to it.errorCount,
            "actionCount" to it.actionCount
        )
    }

    override fun fromMap(input: Map<String, Any?>?): SnapshotContext? = input?.let {
        SnapshotContext(
            viewCount = it["viewCount"] as? Int ?: 0,
            errorCount = it["errorCount"] as? Int ?: 0,
            actionCount = it["actionCount"] as? Int ?: 0
        )
    }
}