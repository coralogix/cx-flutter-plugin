package com.coralogix.flutter.plugin.mappers

interface IMapper<I, O> {
    fun toMap(input: I): O
    fun fromMap(input: O): I
}