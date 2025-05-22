package com.coralogix.flutter.plugin.mappers

import com.coralogix.android.sdk.model.CoralogixLogSeverity

object CoralogixLogSeverityMapper : IMapper<String, CoralogixLogSeverity?> {
    override fun map(input: String): CoralogixLogSeverity? {
        return when (input) {
            "debug" -> CoralogixLogSeverity.Debug
            "verbose" -> CoralogixLogSeverity.Verbose
            "info" -> CoralogixLogSeverity.Info
            "warn" -> CoralogixLogSeverity.Warn
            "error" -> CoralogixLogSeverity.Error
            "critical" -> CoralogixLogSeverity.Critical
            else -> null
        }
    }
}