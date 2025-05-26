package com.coralogix.flutter.plugin.mappers.cx_rum

import com.coralogix.android.sdk.model.EditableCxRum
import com.coralogix.flutter.plugin.mappers.IMapper

class EditableCxRumMapper(
    private val eventContextMapper: EventContextMapper = EventContextMapper(),
    private val viewContextMapper: ViewContextMapper = ViewContextMapper(),
    private val errorContextMapper: EditableErrorContextMapper = EditableErrorContextMapper(),
    private val logContextMapper: LogContextMapper = LogContextMapper(),
    private val networkRequestContextMapper: NetworkRequestContextMapper = NetworkRequestContextMapper(),
    private val snapshotContextMapper: SnapshotContextMapper = SnapshotContextMapper(),
    private val userContextMapper: UserContextMapper = UserContextMapper(),
    private val lifecycleContextMapper: LifecycleContextMapper = LifecycleContextMapper(),
    private val customMeasurementContextMapper: CustomMeasurementContextMapper = CustomMeasurementContextMapper(),
    private val interactionContextMapper: InteractionContextMapper = InteractionContextMapper()
) : IMapper<EditableCxRum, Map<String, Any?>> {
    override fun toMap(input: EditableCxRum): Map<String, Any?> = mapOf(
        "eventContext" to eventContextMapper.toMap(input.eventContext),
        "labels" to input.labels,
        "spanId" to input.spanId,
        "traceId" to input.traceId,
        "environment" to input.environment,
        "viewContext" to viewContextMapper.toMap(input.viewContext),
        "isSnapshotEvent" to input.isSnapshotEvent,
        "errorContext" to errorContextMapper.toMap(input.errorContext),
        "logContext" to logContextMapper.toMap(input.logContext),
        "networkRequestContext" to networkRequestContextMapper.toMap(input.networkRequestContext),
        "snapshotContext" to snapshotContextMapper.toMap(input.snapshotContext),
        "userContext" to userContextMapper.toMap(input.userContext),
        "lifecycleContext" to lifecycleContextMapper.toMap(input.lifecycleContext),
        "customMeasurementContext" to customMeasurementContextMapper.toMap(input.customMeasurementContext),
        "interactionContext" to interactionContextMapper.toMap(input.interactionContext)
    )

    @Suppress("UNCHECKED_CAST")
    override fun fromMap(input: Map<String, Any?>): EditableCxRum {
        return EditableCxRum(
            eventContext = eventContextMapper.fromMap(input["eventContext"] as? Map<String, Any?>),
            labels = (input["labels"] as? Map<*, *>)?.mapNotNull {
                (it.key as? String)?.let { key ->
                    (it.value as? String)?.let { value -> key to value }
                }
            }?.toMap(),
            spanId = input["spanId"] as? String,
            traceId = input["traceId"] as? String,
            environment = input["environment"] as? String,
            viewContext = viewContextMapper.fromMap(input["viewContext"] as? Map<String, Any?>),
            isSnapshotEvent = input["isSnapshotEvent"] as? Boolean,
            errorContext = errorContextMapper.fromMap(input["errorContext"] as? Map<String, Any?>),
            logContext = logContextMapper.fromMap(input["logContext"] as? Map<String, Any?>),
            networkRequestContext = networkRequestContextMapper.fromMap(input["networkRequestContext"] as? Map<String, Any?>),
            snapshotContext = snapshotContextMapper.fromMap(input["snapshotContext"] as? Map<String, Any?>),
            userContext = userContextMapper.fromMap(input["userContext"] as? Map<String, Any?>),
            lifecycleContext = lifecycleContextMapper.fromMap(input["lifecycleContext"] as? Map<String, Any?>),
            customMeasurementContext = customMeasurementContextMapper.fromMap(input["customMeasurementContext"] as? Map<String, Any?>),
            interactionContext = interactionContextMapper.fromMap(input["interactionContext"] as? Map<String, Any?>)
        )
    }
}