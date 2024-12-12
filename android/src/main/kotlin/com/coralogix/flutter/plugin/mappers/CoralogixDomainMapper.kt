package com.coralogix.flutter.plugin.mappers

import com.coralogix.android.sdk.model.CoralogixDomain

object CoralogixDomainMapper : IMapper<String, CoralogixDomain?> {
    override fun map(input: String): CoralogixDomain? {
        return when (input) {
            CoralogixDomain.AP1.url -> CoralogixDomain.AP1
            CoralogixDomain.AP2.url -> CoralogixDomain.AP2
            CoralogixDomain.AP3.url -> CoralogixDomain.AP3
            CoralogixDomain.EU1.url -> CoralogixDomain.EU1
            CoralogixDomain.EU2.url -> CoralogixDomain.EU2
            CoralogixDomain.US1.url -> CoralogixDomain.US1
            CoralogixDomain.US2.url -> CoralogixDomain.US2
            else -> null
        }
    }
}