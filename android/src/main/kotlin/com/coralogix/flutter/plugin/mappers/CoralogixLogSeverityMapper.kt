package com.coralogix.flutter.plugin.mappers

import com.coralogix.android.sdk.model.CoralogixLogSeverity

object CoralogixLogSeverityMapper : IMapper<String, CoralogixLogSeverity> {
    override fun toMap(input: String): CoralogixLogSeverity {
        return when (input) {
            DEBUG -> CoralogixLogSeverity.Debug
            VERBOSE -> CoralogixLogSeverity.Verbose
            INFO -> CoralogixLogSeverity.Info
            WARN -> CoralogixLogSeverity.Warn
            ERROR -> CoralogixLogSeverity.Error
            CRITICAL -> CoralogixLogSeverity.Critical
            else -> throw IllegalArgumentException("Unknown Coralogix log severity: $input")
        }
    }

    private const val DEBUG = "debug"
    private const val VERBOSE = "verbose"
    private const val INFO = "info"
    private const val WARN = "warn"
    private const val ERROR = "error"
    private const val CRITICAL = "critical"
}