package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.UserContext
import com.coralogix.flutter.plugin.mappers.IMapper

class UserContextMapper : IMapper<UserContext?, Map<String, Any?>?> {
    override fun toMap(input: UserContext?): Map<String, Any?>? = input?.let {
        mapOf(
            "user_id" to input.userId,
            "user_name" to input.username,
            "user_email" to input.email,
            "user_metadata" to input.metadata
        )
    }

    @Suppress("UNCHECKED_CAST")
    override fun fromMap(input: Map<String, Any?>?): UserContext? = input?.let {
        UserContext(
            userId = input["user_id"] as? String ?: "",
            username = input["user_name"] as? String ?: "",
            email = input["user_email"] as? String ?: "",
            metadata = input["user_metadata"] as? Map<String, String> ?: emptyMap()
        )
    }
}