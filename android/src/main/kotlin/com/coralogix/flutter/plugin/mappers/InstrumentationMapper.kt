package com.coralogix.flutter.plugin.mappers

import com.coralogix.android.sdk.model.Instrumentation

internal object InstrumentationMapper : IMapper<Map<String, Boolean>, Map<Instrumentation, Boolean>> {
    override fun map(input: Map<String, Boolean>): Map<Instrumentation, Boolean> {
        return input.mapNotNull { (key, value) ->
            val instrumentation = when (key) {
                MOBILE_VITALS -> Instrumentation.MobileVitals
                CUSTOM -> Instrumentation.Custom
                ERRORS -> Instrumentation.Error
                NETWORK -> Instrumentation.Network
                ANR -> Instrumentation.Anr
                LIFE_CYCLE -> Instrumentation.Lifecycle
                else -> null
            }

            instrumentation?.let { it to value }
        }.toMap()
    }

    private const val MOBILE_VITALS = "mobileVitals"
    private const val CUSTOM = "custom"
    private const val ERRORS = "errors"
    private const val NETWORK = "network"
    private const val ANR = "anr"
    private const val LIFE_CYCLE = "lifeCycle"
}