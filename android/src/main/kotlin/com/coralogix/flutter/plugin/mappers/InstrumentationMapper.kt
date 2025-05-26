package com.coralogix.flutter.plugin.mappers

import com.coralogix.android.sdk.model.Instrumentation

internal object InstrumentationMapper : IMapper<Map<String, Boolean>, Map<Instrumentation, Boolean>> {
    override fun toMap(input: Map<String, Boolean>): Map<Instrumentation, Boolean> {
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

    override fun fromMap(input: Map<Instrumentation, Boolean>): Map<String, Boolean> {
        return input.mapNotNull { (key, value) ->
            val instrumentation = when (key) {
                Instrumentation.MobileVitals -> MOBILE_VITALS
                Instrumentation.Custom -> CUSTOM
                Instrumentation.Error -> ERRORS
                Instrumentation.Network -> NETWORK
                Instrumentation.Anr -> ANR
                Instrumentation.Lifecycle -> LIFE_CYCLE
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