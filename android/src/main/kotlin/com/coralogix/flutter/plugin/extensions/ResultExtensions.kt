package com.coralogix.flutter.plugin.extensions

import io.flutter.plugin.common.MethodChannel.Result

internal fun Result.invalidArgumentsError() {
    error("4", "Arguments is null or empty", null)
}

internal fun Result.error(description: String) {
    error("4", description, null)
}

internal fun Result.success() = success("")