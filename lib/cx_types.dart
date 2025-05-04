import 'package:cx_flutter_plugin/cx_log_severity.dart';

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

class VersionMetaData {
  final String appName;
  final String appVersion;

  VersionMetaData({
    required this.appName,
    required this.appVersion,
  });
}

class UserMetadata {
  final String userId;
  final String? userName;
  final String? userEmail;
  final Map<String, dynamic>? userMetadata;

  UserMetadata({
    required this.userId,
    this.userName,
    this.userEmail,
    this.userMetadata,
  });
}

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
}

class DeviceState {
  final String? battery;
  final String? networkType;

  DeviceState({this.battery, this.networkType});
}

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
}

class EventContext {
  final CoralogixEventType type;
  final EventSource source;
  final CxLogSeverity severity;

  EventContext({
    required this.type,
    required this.source,
    required this.severity,
  });
}

class ErrorContext {
  final String? domain;
  final String? code;
  final String? errorMessage;
  final String? userInfo;
  final List<Map<String, dynamic>>? originalStacktrace;
  final String? errorType;
  final bool? isCrashed;
  final String? eventType;
  final String? errorContext;
  final String? crashTimestamp;
  final String? processName;
  final String? applicationIdentifier;
  final String? triggeredByThread;
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
}

class LogContext {
  final String message;
  final dynamic data;

  LogContext({required this.message, this.data});
}

class NetworkRequestContext {
  final String method;
  final int statusCode;
  final String url;
  final String fragments;
  final String host;
  final String schema;
  final String statusText;
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
}

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
}

class CxRumEvent {
  final String platform;
  final VersionMetaData versionMetadata;
  final SessionContext sessionContext;
  final DeviceContext deviceContext;
  final DeviceState deviceState;
  final dynamic viewContext; // Replace with actual class if needed
  final EventContext eventContext;
  final ErrorContext? errorContext;
  final LogContext? logContext;
  final NetworkRequestContext? networkRequestContext;
  final SnapshotContext? snapshotContext;
  final dynamic labels; // Replace with actual class
  final String spanId;
  final String traceId;
  final String environment;
  final int timestamp;
  final bool? isSnapshotEvent;

  CxRumEvent({
    required this.platform,
    required this.versionMetadata,
    required this.sessionContext,
    required this.deviceContext,
    required this.deviceState,
    required this.viewContext,
    required this.eventContext,
    this.errorContext,
    this.logContext,
    this.networkRequestContext,
    this.snapshotContext,
    required this.labels,
    required this.spanId,
    required this.traceId,
    required this.environment,
    required this.timestamp,
    this.isSnapshotEvent,
  });
}

class EditableCxRumEvent extends CxRumEvent {
  EditableCxRumEvent({
    required super.platform,
    required super.versionMetadata,
    required SessionContext sessionContext,
    required super.deviceContext,
    required super.deviceState,
    required super.viewContext,
    required super.eventContext,
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
  }) : super(sessionContext: sessionContext);
}

typedef BeforeSendResult = EditableCxRumEvent?;