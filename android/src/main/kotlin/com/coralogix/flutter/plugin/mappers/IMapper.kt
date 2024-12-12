package com.coralogix.flutter.plugin.mappers

interface IMapper<in I, out O> {
    fun map(input: I): O
}