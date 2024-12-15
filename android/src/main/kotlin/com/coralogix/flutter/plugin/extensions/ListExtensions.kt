package com.coralogix.flutter.plugin.extensions

internal fun List<*>.toStringList(): List<String> {
    return mapNotNull { it as? String }
}