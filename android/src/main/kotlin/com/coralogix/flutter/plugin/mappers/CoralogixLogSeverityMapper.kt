package com.coralogix.flutter.plugin.mappers

import com.coralogix.android.sdk.model.CoralogixLogSeverity

object CoralogixLogSeverityMapper : IMapper<Int, CoralogixLogSeverity?> {
    override fun map(input: Int): CoralogixLogSeverity? {
        return when (input) {
            1 -> CoralogixLogSeverity.Debug
            2 -> CoralogixLogSeverity.Verbose
            3 -> CoralogixLogSeverity.Info
            4 -> CoralogixLogSeverity.Warn
            5 -> CoralogixLogSeverity.Error
            6 -> CoralogixLogSeverity.Critical
            else -> null
        }
    }
}