package com.coralogix.flutter.plugin.mappers

import com.coralogix.android.sdk.model.CoralogixLogSeverity

object CoralogixLogSeverityMapper : IMapper<String, CoralogixLogSeverity?> {
    override fun toMap(input: String): CoralogixLogSeverity? {
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

    override fun fromMap(input: CoralogixLogSeverity?): String {
        return when (input) {
            CoralogixLogSeverity.Debug -> "debug"
            CoralogixLogSeverity.Verbose -> "verbose"
            CoralogixLogSeverity.Info -> "info"
            CoralogixLogSeverity.Warn -> "warn"
            CoralogixLogSeverity.Error -> "error"
            CoralogixLogSeverity.Critical -> "critical"
            else -> throw IllegalArgumentException("Unknown Coralogix log severity: $input")
        }
    }
}