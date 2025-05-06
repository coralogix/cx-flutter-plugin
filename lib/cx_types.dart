import 'package:cx_flutter_plugin/cx_log_severity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'cx_types.g.dart';

enum CoralogixEventType {
  error,
  networkRequest,
  log,
  userInteraction,
  webVitals,
  longTask,
  resources,
  internal,
  navigation,
}

enum EventSource {
  console,
  fetch,
  code,
  unhandledRejection,
}

@JsonSerializable()
class VersionMetaData {
  @JsonKey(name: 'app_name')
  final String appName;

  @JsonKey(name: 'app_version')
  final String appVersion;

  VersionMetaData({
    required this.appName,
    required this.appVersion,
  });

  factory VersionMetaData.fromJson(Map<String, dynamic> json) => _$VersionMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$VersionMetaDataToJson(this);
}

@JsonSerializable()
class UserMetadata {
  @JsonKey(name: 'user_id')
  String userId;

  @JsonKey(name: 'user_name')
  String? userName;
    
  @JsonKey(name: 'user_email')
  String? userEmail;

  @JsonKey(name: 'user_metadata')
  Map<String, dynamic>? userMetadata;

  UserMetadata({
    required this.userId,
    this.userName,
    this.userEmail,
    this.userMetadata,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) => _$UserMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$UserMetadataToJson(this);
}

@JsonSerializable()
class SessionContext extends UserMetadata {
  final String? device;
  final String? os;
  final dynamic osVersion;

  SessionContext({
    required super.userId,
    super.userName,
    super.userEmail,
    super.userMetadata,
    this.device,
    this.os,
    this.osVersion,
  });

  factory SessionContext.fromJson(Map<String, dynamic> json) => _$SessionContextFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SessionContextToJson(this);
}

@JsonSerializable()
class DeviceState {
  final String? battery;
    
  @JsonKey(name: 'network_type')
  final String? networkType;

  DeviceState({this.battery, this.networkType});

  factory DeviceState.fromJson(Map<String, dynamic> json) => _$DeviceStateFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceStateToJson(this);
}

@JsonSerializable()
class DeviceContext {
  final String? device;
  final String? deviceName;
  final bool? emulator;
  final String? os;
  final dynamic osVersion;

  DeviceContext({
    this.device,
    this.deviceName,
    this.emulator,
    this.os,
    this.osVersion,
  });

  factory DeviceContext.fromJson(Map<String, dynamic> json) => _$DeviceContextFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceContextToJson(this);
}

@JsonSerializable()
class EventContext {
  final CoralogixEventType type;
  final EventSource source;
  final CxLogSeverity severity;

  EventContext({
    required this.type,
    required this.source,
    required this.severity,
  });

  factory EventContext.fromJson(Map<String, dynamic> json) => _$EventContextFromJson(json);
  Map<String, dynamic> toJson() => _$EventContextToJson(this);
}

@JsonSerializable()
class ErrorContext {
  final String? domain;
  final String? code;

  @JsonKey(name: 'error_message')
  final String? errorMessage;

  @JsonKey(name: 'user_info')
  final String? userInfo;

  @JsonKey(name: 'original_stacktrace')
  final List<Map<String, dynamic>>? originalStacktrace;

  @JsonKey(name: 'error_type')
  final String? errorType;

  @JsonKey(name: 'is_crashed')
  final bool? isCrashed;

  @JsonKey(name: 'event_type')
  final String? eventType;

  @JsonKey(name: 'error_context')
  final String? errorContext;

  @JsonKey(name: 'crash_timestamp')
  final String? crashTimestamp;

  @JsonKey(name: 'process_name')
  final String? processName;

  @JsonKey(name: 'application_identifier')
  final String? applicationIdentifier;

  @JsonKey(name: 'triggered_by_thread')
  final String? triggeredByThread;

  @JsonKey(name: 'base_address')
  final String? baseAddress;

  final String? arch;
  final List<Map<String, dynamic>>? threads;

  ErrorContext({
    this.domain,
    this.code,
    this.errorMessage,
    this.userInfo,
    this.originalStacktrace,
    this.errorType,
    this.isCrashed,
    this.eventType,
    this.errorContext,
    this.crashTimestamp,
    this.processName,
    this.applicationIdentifier,
    this.triggeredByThread,
    this.baseAddress,
    this.arch,
    this.threads,
  });

  factory ErrorContext.fromJson(Map<String, dynamic> json) => _$ErrorContextFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorContextToJson(this);
}

@JsonSerializable()
class LogContext {
  final String message;
  final dynamic data;

  LogContext({required this.message, this.data});

  factory LogContext.fromJson(Map<String, dynamic> json) => _$LogContextFromJson(json);
  Map<String, dynamic> toJson() => _$LogContextToJson(this);
}

@JsonSerializable()
class NetworkRequestContext {
  final String method;
    
  @JsonKey(name: 'status_code')
  final int statusCode;

  final String url;
  final String fragments;
  final String host;
  final String schema;

  @JsonKey(name: 'status_text')
  final String statusText;

  @JsonKey(name: 'response_content_length')
  final String responseContentLength;

  final double duration;

  NetworkRequestContext({
    required this.method,
    required this.statusCode,
    required this.url,
    required this.fragments,
    required this.host,
    required this.schema,
    required this.statusText,
    required this.responseContentLength,
    required this.duration,
  });

  factory NetworkRequestContext.fromJson(Map<String, dynamic> json) => _$NetworkRequestContextFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkRequestContextToJson(this);
}

@JsonSerializable()
class SnapshotContext {
  final int timestamp;
  final int errorCount;
  final int viewCount;
  final int actionCount;
  final bool hasRecording;

  SnapshotContext({
    required this.timestamp,
    required this.errorCount,
    required this.viewCount,
    required this.actionCount,
    required this.hasRecording,
  });

  factory SnapshotContext.fromJson(Map<String, dynamic> json) => _$SnapshotContextFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotContextToJson(this);
}

@JsonSerializable()
class CxRumEvent {
  final String platform;
  
  @JsonKey(name: 'version_metadata')
  final VersionMetaData versionMetadata;
  
  @JsonKey(name: 'session_context')
  final SessionContext? sessionContext;

  @JsonKey(name: 'device_context')
  final DeviceContext? deviceContext;
  
  @JsonKey(name: 'device_state')
  final DeviceState? deviceState;
  
  @JsonKey(name: 'view_context')
  final dynamic viewContext;

  @JsonKey(name: 'event_context')
  final EventContext? eventContext;

  @JsonKey(name: 'error_context')
  final ErrorContext? errorContext;
    
  @JsonKey(name: 'log_context')
  final LogContext? logContext;

  @JsonKey(name: 'network_request_context')
  final NetworkRequestContext? networkRequestContext;
  
  @JsonKey(name: 'snapshot_context')
  final SnapshotContext? snapshotContext;

  final dynamic labels;
  final String spanId;
  final String traceId;
  final String environment;
  final int timestamp;
  final bool? isSnapshotEvent;

  CxRumEvent({
    required this.platform,
    required this.versionMetadata,
    this.sessionContext,
    this.deviceContext,
    this.deviceState,
    this.viewContext,
    this.eventContext,
    this.errorContext,
    this.logContext,
    this.networkRequestContext,
    this.snapshotContext,
    this.labels,
    required this.spanId,
    required this.traceId,
    required this.environment,
    required this.timestamp,
    this.isSnapshotEvent,
  });

  factory CxRumEvent.fromJson(Map<String, dynamic> json) => _$CxRumEventFromJson(json);
  Map<String, dynamic> toJson() => _$CxRumEventToJson(this);
}

@JsonSerializable()
class EditableCxRumEvent extends CxRumEvent {
  EditableCxRumEvent({
    required super.platform,
    required super.versionMetadata,
    super.sessionContext,
    super.deviceContext,
    super.deviceState,
    super.viewContext,
    super.eventContext,
    super.errorContext,
    super.logContext,
    super.networkRequestContext,
    super.snapshotContext,
    required super.labels,
    required super.spanId,
    required super.traceId,
    required super.environment,
    required super.timestamp,
    super.isSnapshotEvent,
  });

  factory EditableCxRumEvent.fromJson(Map<String, dynamic> json) => _$EditableCxRumEventFromJson(json);
  Map<String, dynamic> toJson() => _$EditableCxRumEventToJson(this);
}

typedef BeforeSendResult = EditableCxRumEvent?;