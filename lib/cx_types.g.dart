// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cx_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionMetaData _$VersionMetaDataFromJson(Map<String, dynamic> json) =>
    VersionMetaData(
      appName: json['appName'] as String,
      appVersion: json['appVersion'] as String,
    );

Map<String, dynamic> _$VersionMetaDataToJson(VersionMetaData instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'appVersion': instance.appVersion,
    };

UserMetadata _$UserMetadataFromJson(Map<String, dynamic> json) => UserMetadata(
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      userMetadata: json['userMetadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserMetadataToJson(UserMetadata instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'userMetadata': instance.userMetadata,
    };

SessionContext _$SessionContextFromJson(Map<String, dynamic> json) =>
    SessionContext(
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      userMetadata: json['userMetadata'] as Map<String, dynamic>?,
      device: json['device'] as String?,
      os: json['os'] as String?,
      osVersion: json['osVersion'],
    );

Map<String, dynamic> _$SessionContextToJson(SessionContext instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'userMetadata': instance.userMetadata,
      'device': instance.device,
      'os': instance.os,
      'osVersion': instance.osVersion,
    };

DeviceState _$DeviceStateFromJson(Map<String, dynamic> json) => DeviceState(
      battery: json['battery'] as String?,
      networkType: json['networkType'] as String?,
    );

Map<String, dynamic> _$DeviceStateToJson(DeviceState instance) =>
    <String, dynamic>{
      'battery': instance.battery,
      'networkType': instance.networkType,
    };

DeviceContext _$DeviceContextFromJson(Map<String, dynamic> json) =>
    DeviceContext(
      device: json['device'] as String?,
      deviceName: json['deviceName'] as String?,
      emulator: json['emulator'] as bool?,
      os: json['os'] as String?,
      osVersion: json['osVersion'],
    );

Map<String, dynamic> _$DeviceContextToJson(DeviceContext instance) =>
    <String, dynamic>{
      'device': instance.device,
      'deviceName': instance.deviceName,
      'emulator': instance.emulator,
      'os': instance.os,
      'osVersion': instance.osVersion,
    };

EventContext _$EventContextFromJson(Map<String, dynamic> json) => EventContext(
      type: $enumDecode(_$CoralogixEventTypeEnumMap, json['type']),
      source: $enumDecode(_$EventSourceEnumMap, json['source']),
      severity: $enumDecode(_$CxLogSeverityEnumMap, json['severity']),
    );

Map<String, dynamic> _$EventContextToJson(EventContext instance) =>
    <String, dynamic>{
      'type': _$CoralogixEventTypeEnumMap[instance.type]!,
      'source': _$EventSourceEnumMap[instance.source]!,
      'severity': _$CxLogSeverityEnumMap[instance.severity]!,
    };

const _$CoralogixEventTypeEnumMap = {
  CoralogixEventType.error: 'error',
  CoralogixEventType.networkRequest: 'networkRequest',
  CoralogixEventType.log: 'log',
  CoralogixEventType.userInteraction: 'userInteraction',
  CoralogixEventType.webVitals: 'webVitals',
  CoralogixEventType.longTask: 'longTask',
  CoralogixEventType.resources: 'resources',
  CoralogixEventType.internal: 'internal',
  CoralogixEventType.navigation: 'navigation',
};

const _$EventSourceEnumMap = {
  EventSource.console: 'console',
  EventSource.fetch: 'fetch',
  EventSource.code: 'code',
  EventSource.unhandledRejection: 'unhandledRejection',
};

const _$CxLogSeverityEnumMap = {
  CxLogSeverity.debug: 'debug',
  CxLogSeverity.verbose: 'verbose',
  CxLogSeverity.info: 'info',
  CxLogSeverity.warn: 'warn',
  CxLogSeverity.error: 'error',
  CxLogSeverity.critical: 'critical',
};

ErrorContext _$ErrorContextFromJson(Map<String, dynamic> json) => ErrorContext(
      domain: json['domain'] as String?,
      code: json['code'] as String?,
      errorMessage: json['errorMessage'] as String?,
      userInfo: json['userInfo'] as String?,
      originalStacktrace: (json['originalStacktrace'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      errorType: json['errorType'] as String?,
      isCrashed: json['isCrashed'] as bool?,
      eventType: json['eventType'] as String?,
      errorContext: json['errorContext'] as String?,
      crashTimestamp: json['crashTimestamp'] as String?,
      processName: json['processName'] as String?,
      applicationIdentifier: json['applicationIdentifier'] as String?,
      triggeredByThread: json['triggeredByThread'] as String?,
      baseAddress: json['baseAddress'] as String?,
      arch: json['arch'] as String?,
      threads: (json['threads'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ErrorContextToJson(ErrorContext instance) =>
    <String, dynamic>{
      'domain': instance.domain,
      'code': instance.code,
      'errorMessage': instance.errorMessage,
      'userInfo': instance.userInfo,
      'originalStacktrace': instance.originalStacktrace,
      'errorType': instance.errorType,
      'isCrashed': instance.isCrashed,
      'eventType': instance.eventType,
      'errorContext': instance.errorContext,
      'crashTimestamp': instance.crashTimestamp,
      'processName': instance.processName,
      'applicationIdentifier': instance.applicationIdentifier,
      'triggeredByThread': instance.triggeredByThread,
      'baseAddress': instance.baseAddress,
      'arch': instance.arch,
      'threads': instance.threads,
    };

LogContext _$LogContextFromJson(Map<String, dynamic> json) => LogContext(
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$LogContextToJson(LogContext instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };

NetworkRequestContext _$NetworkRequestContextFromJson(
        Map<String, dynamic> json) =>
    NetworkRequestContext(
      method: json['method'] as String,
      statusCode: (json['statusCode'] as num).toInt(),
      url: json['url'] as String,
      fragments: json['fragments'] as String,
      host: json['host'] as String,
      schema: json['schema'] as String,
      statusText: json['statusText'] as String,
      responseContentLength: json['responseContentLength'] as String,
      duration: (json['duration'] as num).toDouble(),
    );

Map<String, dynamic> _$NetworkRequestContextToJson(
        NetworkRequestContext instance) =>
    <String, dynamic>{
      'method': instance.method,
      'statusCode': instance.statusCode,
      'url': instance.url,
      'fragments': instance.fragments,
      'host': instance.host,
      'schema': instance.schema,
      'statusText': instance.statusText,
      'responseContentLength': instance.responseContentLength,
      'duration': instance.duration,
    };

SnapshotContext _$SnapshotContextFromJson(Map<String, dynamic> json) =>
    SnapshotContext(
      timestamp: (json['timestamp'] as num).toInt(),
      errorCount: (json['errorCount'] as num).toInt(),
      viewCount: (json['viewCount'] as num).toInt(),
      actionCount: (json['actionCount'] as num).toInt(),
      hasRecording: json['hasRecording'] as bool,
    );

Map<String, dynamic> _$SnapshotContextToJson(SnapshotContext instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'errorCount': instance.errorCount,
      'viewCount': instance.viewCount,
      'actionCount': instance.actionCount,
      'hasRecording': instance.hasRecording,
    };

CxRumEvent _$CxRumEventFromJson(Map<String, dynamic> json) => CxRumEvent(
      platform: json['platform'] as String,
      versionMetadata: VersionMetaData.fromJson(
          json['versionMetadata'] as Map<String, dynamic>),
      sessionContext: SessionContext.fromJson(
          json['sessionContext'] as Map<String, dynamic>),
      deviceContext:
          DeviceContext.fromJson(json['deviceContext'] as Map<String, dynamic>),
      deviceState:
          DeviceState.fromJson(json['deviceState'] as Map<String, dynamic>),
      viewContext: json['viewContext'],
      eventContext:
          EventContext.fromJson(json['eventContext'] as Map<String, dynamic>),
      errorContext: json['errorContext'] == null
          ? null
          : ErrorContext.fromJson(json['errorContext'] as Map<String, dynamic>),
      logContext: json['logContext'] == null
          ? null
          : LogContext.fromJson(json['logContext'] as Map<String, dynamic>),
      networkRequestContext: json['networkRequestContext'] == null
          ? null
          : NetworkRequestContext.fromJson(
              json['networkRequestContext'] as Map<String, dynamic>),
      snapshotContext: json['snapshotContext'] == null
          ? null
          : SnapshotContext.fromJson(
              json['snapshotContext'] as Map<String, dynamic>),
      labels: json['labels'],
      spanId: json['spanId'] as String,
      traceId: json['traceId'] as String,
      environment: json['environment'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      isSnapshotEvent: json['isSnapshotEvent'] as bool?,
    );

Map<String, dynamic> _$CxRumEventToJson(CxRumEvent instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'versionMetadata': instance.versionMetadata,
      'sessionContext': instance.sessionContext,
      'deviceContext': instance.deviceContext,
      'deviceState': instance.deviceState,
      'viewContext': instance.viewContext,
      'eventContext': instance.eventContext,
      'errorContext': instance.errorContext,
      'logContext': instance.logContext,
      'networkRequestContext': instance.networkRequestContext,
      'snapshotContext': instance.snapshotContext,
      'labels': instance.labels,
      'spanId': instance.spanId,
      'traceId': instance.traceId,
      'environment': instance.environment,
      'timestamp': instance.timestamp,
      'isSnapshotEvent': instance.isSnapshotEvent,
    };

EditableCxRumEvent _$EditableCxRumEventFromJson(Map<String, dynamic> json) =>
    EditableCxRumEvent(
      platform: json['platform'] as String,
      versionMetadata: VersionMetaData.fromJson(
          json['versionMetadata'] as Map<String, dynamic>),
      sessionContext: SessionContext.fromJson(
          json['sessionContext'] as Map<String, dynamic>),
      deviceContext:
          DeviceContext.fromJson(json['deviceContext'] as Map<String, dynamic>),
      deviceState:
          DeviceState.fromJson(json['deviceState'] as Map<String, dynamic>),
      viewContext: json['viewContext'],
      eventContext:
          EventContext.fromJson(json['eventContext'] as Map<String, dynamic>),
      errorContext: json['errorContext'] == null
          ? null
          : ErrorContext.fromJson(json['errorContext'] as Map<String, dynamic>),
      logContext: json['logContext'] == null
          ? null
          : LogContext.fromJson(json['logContext'] as Map<String, dynamic>),
      networkRequestContext: json['networkRequestContext'] == null
          ? null
          : NetworkRequestContext.fromJson(
              json['networkRequestContext'] as Map<String, dynamic>),
      snapshotContext: json['snapshotContext'] == null
          ? null
          : SnapshotContext.fromJson(
              json['snapshotContext'] as Map<String, dynamic>),
      labels: json['labels'],
      spanId: json['spanId'] as String,
      traceId: json['traceId'] as String,
      environment: json['environment'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      isSnapshotEvent: json['isSnapshotEvent'] as bool?,
    );

Map<String, dynamic> _$EditableCxRumEventToJson(EditableCxRumEvent instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'versionMetadata': instance.versionMetadata,
      'sessionContext': instance.sessionContext,
      'deviceContext': instance.deviceContext,
      'deviceState': instance.deviceState,
      'viewContext': instance.viewContext,
      'eventContext': instance.eventContext,
      'errorContext': instance.errorContext,
      'logContext': instance.logContext,
      'networkRequestContext': instance.networkRequestContext,
      'snapshotContext': instance.snapshotContext,
      'labels': instance.labels,
      'spanId': instance.spanId,
      'traceId': instance.traceId,
      'environment': instance.environment,
      'timestamp': instance.timestamp,
      'isSnapshotEvent': instance.isSnapshotEvent,
    };
