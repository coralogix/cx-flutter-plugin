package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.UserContext
import com.coralogix.flutter.plugin.mappers.IMapper

class UserContextMapper : IMapper<UserContext?, Map<String, Any?>?> {
    override fun toMap(input: UserContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "userId" to input.userId,
            "username" to input.username,
            "email" to input.email,
            "metadata" to input.metadata
        )
    }

    @Suppress("UNCHECKED_CAST")
    override fun fromMap(input: Map<String, Any?>?): UserContext? = input?.let {
        UserContext(
            userId = input["userId"] as? String ?: "",
            username = input["username"] as? String ?: "",
            email = input["email"] as? String ?: "",
            metadata = input["metadata"] as? Map<String, String> ?: emptyMap()
        )
    }
}