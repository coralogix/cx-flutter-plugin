import 'package:json_annotation/json_annotation.dart';

part 'cx_types.g.dart';

enum CoralogixEventType {
  error,
  @JsonValue('network-request')
  networkRequest,
  log,
  @JsonValue('user-interaction')
  userInteraction,
  webVitals,
  longTask,
  resources,
  internal,
  navigation,
  @JsonValue('mobile-vitals')
  mobileVitals,
}

enum EventSource {
  console,
  fetch,
  code,
  unhandledRejection,
  @JsonValue('mobile')
  mobile,
  @JsonValue('mobile-vitals')
  mobileVitals,
}

enum CxLogSeverity {
  @JsonValue(1)
  debug,
  @JsonValue(2)
  verbose,
  @JsonValue(3)
  info,
  @JsonValue(4)
  warn,
  @JsonValue(5)
  error,
  @JsonValue(6)
  critical,
}

@JsonSerializable()
class VersionMetaData {
  @JsonKey(name: 'app_name')
  String appName;

  @JsonKey(name: 'app_version')
  String appVersion;

  VersionMetaData({
    required this.appName,
    required this.appVersion,
  });

  factory VersionMetaData.fromJson(Map<String, dynamic> json) {
    try {
      // Ensure we're working with String values
      final appName = json['app_name']?.toString() ?? '';
      final appVersion = json['app_version']?.toString() ?? '';

      return VersionMetaData(
        appName: appName,
        appVersion: appVersion,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'app_version': appVersion,
    };
  }
}

@JsonSerializable()
class MobileSdk {
  @JsonKey(name: 'sdk_version')
  final String sdkVersion;

  @JsonKey(name: 'framework')
  final String framework;

  @JsonKey(name: 'os')
  final String operatingSystem;

  MobileSdk({
    required this.sdkVersion,
    required this.framework,
    required this.operatingSystem,
  });

  factory MobileSdk.fromJson(Map<String, dynamic> json) =>
      _$MobileSdkFromJson(json);

  Map<String, dynamic> toJson() => _$MobileSdkToJson(this);
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

  factory UserMetadata.fromJson(Map<String, dynamic> json) =>
      _$UserMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$UserMetadataToJson(this);
}

@JsonSerializable()
class SessionContext extends UserMetadata {
  String? device;
  String? os;
  dynamic osVersion;

  SessionContext({
    required super.userId,
    super.userName,
    super.userEmail,
    super.userMetadata,
    this.device,
    this.os,
    this.osVersion,
  });

  factory SessionContext.fromJson(Map<String, dynamic> json) =>
      _$SessionContextFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SessionContextToJson(this);
}

@JsonSerializable()
class DeviceState {
  String? battery;

  @JsonKey(name: 'network_type')
  String? networkType;

  DeviceState({this.battery, this.networkType});

  factory DeviceState.fromJson(Map<String, dynamic> json) =>
      _$DeviceStateFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceStateToJson(this);
}

@JsonSerializable()
class DeviceContext {
  String? device;

  @JsonKey(name: 'device_name')
  String? deviceName;

  bool? emulator;
  String? os;
  dynamic osVersion;

  DeviceContext({
    this.device,
    this.deviceName,
    this.emulator,
    this.os,
    this.osVersion,
  });

  factory DeviceContext.fromJson(Map<String, dynamic> json) =>
      _$DeviceContextFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceContextToJson(this);
}

@JsonSerializable()
class EventContext {
  final CoralogixEventType type;
  @JsonKey(includeIfNull: true)
  final EventSource? source;
  @JsonKey(includeIfNull: true)
  final CxLogSeverity? severity;

  EventContext({
    required this.type,
    this.source,
    this.severity,
  });

  factory EventContext.fromJson(Map<String, dynamic> json) =>
      _$EventContextFromJson(json);

  Map<String, dynamic> toJson() => _$EventContextToJson(this);
}

@JsonSerializable()
class ErrorContext {
  String? domain;
  String? code;

  @JsonKey(name: 'error_message')
  String? errorMessage;

  @JsonKey(name: 'user_info')
  String? userInfo;

  @JsonKey(name: 'original_stacktrace')
  List<Map<String, dynamic>>? originalStacktrace;

  @JsonKey(name: 'error_type')
  String? errorType;

  @JsonKey(name: 'is_crashed')
  bool? isCrashed;

  @JsonKey(name: 'event_type')
  String? eventType;

  @JsonKey(name: 'error_context')
  String? errorContext;

  @JsonKey(name: 'crash_timestamp')
  String? crashTimestamp;

  @JsonKey(name: 'process_name')
  String? processName;

  @JsonKey(name: 'application_identifier')
  String? applicationIdentifier;

  @JsonKey(name: 'triggered_by_thread')
  String? triggeredByThread;

  @JsonKey(name: 'base_address')
  String? baseAddress;

  String? arch;
  List<Map<String, dynamic>>? threads;

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

  factory ErrorContext.fromJson(Map<String, dynamic> json) =>
      _$ErrorContextFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorContextToJson(this);
}

@JsonSerializable()
class LogContext {
  String message;
  dynamic data;

  LogContext({required this.message, this.data});

  factory LogContext.fromJson(Map<String, dynamic> json) =>
      _$LogContextFromJson(json);

  Map<String, dynamic> toJson() => _$LogContextToJson(this);
}

@JsonSerializable()
class NetworkRequestContext {
  String method;

  @JsonKey(name: 'status_code')
  int statusCode;

  String url;
  String? fragments;
  String? host;
  String? schema;

  @JsonKey(name: 'status_text')
  String? statusText;

  @JsonKey(name: 'response_content_length')
  String? responseContentLength;

  double? duration;

  NetworkRequestContext({
    required this.method,
    required this.statusCode,
    required this.url,
    this.fragments,
    this.host,
    this.schema,
    this.statusText,
    this.responseContentLength,
    this.duration,
  });

  factory NetworkRequestContext.fromJson(Map<String, dynamic> json) {
    return NetworkRequestContext(
      method: json['method'] as String,
      statusCode: json['status_code'] is String
          ? int.tryParse(json['status_code'] as String) ?? 0
          : json['status_code'] as int,
      url: json['url'] as String,
      fragments: json['fragments'] as String?,
      host: json['host'] as String?,
      schema: json['schema'] as String?,
      statusText: json['status_text'] as String?,
      responseContentLength: json['response_content_length'] as String?,
      duration: json['duration'] is String
          ? double.tryParse(json['duration'] as String)
          : (json['duration'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'status_code': statusCode,
      'url': url,
      'fragments': fragments,
      'host': host,
      'schema': schema,
      'status_text': statusText,
      'response_content_length': responseContentLength,
      'duration': duration,
    };
  }
}

@JsonSerializable()
class SnapshotContext {
  int timestamp;
  @JsonKey(name: 'errorCount')
  int errorCount;
  @JsonKey(name: 'viewCount')
  int viewCount;
  @JsonKey(name: 'clickCount')
  int actionCount;
  @JsonKey(name: 'hasRecording')
  bool hasRecording;

  SnapshotContext({
    required this.timestamp,
    required this.errorCount,
    required this.viewCount,
    required this.actionCount,
    required this.hasRecording,
  });

  factory SnapshotContext.fromJson(Map<String, dynamic> json) {
    return SnapshotContext(
      timestamp: json['timestamp'] is int
          ? json['timestamp']
          : (json['timestamp'] as num?)?.toInt() ?? 0,
      errorCount: json['errorCount'] is int
          ? json['errorCount'] as int
          : int.tryParse(json['errorCount']?.toString() ?? '0') ?? 0,
      viewCount: json['viewCount'] ?? 0,
      actionCount: json['clickCount'] ?? 0,
      hasRecording: json['hasRecording'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'errorCount': errorCount,
      'viewCount': viewCount,
      'clickCount': actionCount,
      'hasRecording': hasRecording,
    };
  }
}

@JsonSerializable()
class LifeCycleContext {
  @JsonKey(name: 'event_name')
  String? eventName;

  LifeCycleContext({this.eventName});

  factory LifeCycleContext.fromJson(Map<String, dynamic> json) =>
      _$LifeCycleContextFromJson(json);

  Map<String, dynamic> toJson() => _$LifeCycleContextToJson(this);
}

@JsonSerializable()
class MobileVitalsContext {
  String type;
  dynamic value;

  MobileVitalsContext({
    required this.type,
    required this.value,
  });

  factory MobileVitalsContext.fromJson(Map<String, dynamic> json) {
    return MobileVitalsContext(
      type: json['type'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }
}

@JsonSerializable()
class ViewContext {
  String? view;

  ViewContext({this.view});

  factory ViewContext.fromJson(Map<String, dynamic> json) =>
      _$ViewContextFromJson(json);

  Map<String, dynamic> toJson() => _$ViewContextToJson(this);
}

@JsonSerializable()
class CxRumEvent {
  int timestamp;
  MobileSdk? mobileSdk;
  String platform;
  VersionMetaData? versionMetadata;
  SessionContext? sessionContext;
  DeviceContext? deviceContext;
  DeviceState? deviceState;
  ViewContext? viewContext;
  EventContext? eventContext;
  ErrorContext? errorContext;
  LogContext? logContext;
  NetworkRequestContext? networkRequestContext;
  SnapshotContext? snapshotContext;
  MobileVitalsContext? mobileVitalsContext;
  LifeCycleContext? lifeCycleContext;
  Map<String, dynamic> labels;
  String spanId;
  String traceId;
  String environment;
  bool? isSnapshotEvent;

  CxRumEvent({
    required this.timestamp,
    this.mobileSdk,
    required this.platform,
    this.versionMetadata,
    this.sessionContext,
    this.deviceContext,
    this.deviceState,
    this.viewContext,
    this.eventContext,
    this.errorContext,
    this.logContext,
    this.networkRequestContext,
    this.snapshotContext,
    this.mobileVitalsContext,
    this.lifeCycleContext,
    required this.labels,
    required this.spanId,
    required this.traceId,
    required this.environment,
    this.isSnapshotEvent,
  });

  factory CxRumEvent.fromJson(Map<String, dynamic> json) {
    return CxRumEvent(
      timestamp: json['timestamp'] as int,
      mobileSdk: json['mobile_sdk'] == null
          ? null
          : MobileSdk.fromJson(json['mobile_sdk'] as Map<String, dynamic>),
      platform: json['platform'] as String,
      versionMetadata: json['version_metadata'] == null
          ? null
          : VersionMetaData.fromJson(
              json['version_metadata'] as Map<String, dynamic>),
      sessionContext: json['session_context'] == null
          ? null
          : SessionContext.fromJson(
              json['session_context'] as Map<String, dynamic>),
      deviceContext: json['device_context'] == null
          ? null
          : DeviceContext.fromJson(
              json['device_context'] as Map<String, dynamic>),
      deviceState: json['device_state'] == null
          ? null
          : DeviceState.fromJson(json['device_state'] as Map<String, dynamic>),
      viewContext: json['view_context'] == null
          ? null
          : ViewContext.fromJson(json['view_context'] as Map<String, dynamic>),
      eventContext: json['event_context'] == null
          ? null
          : EventContext.fromJson(
              json['event_context'] as Map<String, dynamic>),
      errorContext: json['error_context'] == null
          ? null
          : ErrorContext.fromJson(
              json['error_context'] as Map<String, dynamic>),
      logContext: json['log_context'] == null
          ? null
          : LogContext.fromJson(json['log_context'] as Map<String, dynamic>),
      networkRequestContext: json['network_request_context'] == null
          ? null
          : NetworkRequestContext.fromJson(
              json['network_request_context'] as Map<String, dynamic>),
      snapshotContext: json['snapshot_context'] == null
          ? null
          : SnapshotContext.fromJson(
              json['snapshot_context'] as Map<String, dynamic>),
      mobileVitalsContext: json['mobile_vitals_context'] == null
          ? null
          : MobileVitalsContext.fromJson(
              json['mobile_vitals_context'] as Map<String, dynamic>),
      lifeCycleContext: json['life_cycle_context'] == null
          ? null
          : LifeCycleContext.fromJson(
              json['life_cycle_context'] as Map<String, dynamic>),
      labels: Map<String, dynamic>.from(json['labels'] as Map),
      spanId: json['spanId'] as String,
      traceId: json['traceId'] as String,
      environment: json['environment'] as String,
      isSnapshotEvent: json['isSnapshotEvent'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'mobile_sdk': mobileSdk?.toJson(),
      'platform': platform,
      'version_metadata': versionMetadata?.toJson(),
      'session_context': sessionContext?.toJson(),
      'device_context': deviceContext?.toJson(),
      'device_state': deviceState?.toJson(),
      'view_context': viewContext?.toJson(),
      'event_context': eventContext?.toJson(),
      'error_context': errorContext?.toJson(),
      'log_context': logContext?.toJson(),
      'network_request_context': networkRequestContext?.toJson(),
      'snapshot_context': snapshotContext?.toJson(),
      'mobile_vitals_context': mobileVitalsContext?.toJson(),
      'life_cycle_context': lifeCycleContext?.toJson(),
      'labels': labels,
      'spanId': spanId,
      'traceId': traceId,
      'environment': environment,
      'isSnapshotEvent': isSnapshotEvent,
    };
  }
}

@JsonSerializable()
class EditableCxRumEvent extends CxRumEvent {
  EditableCxRumEvent({
    required super.platform,
    super.versionMetadata,
    required super.timestamp,
    super.mobileSdk,
    super.sessionContext,
    super.deviceContext,
    super.deviceState,
    super.viewContext,
    super.eventContext,
    super.errorContext,
    super.logContext,
    super.networkRequestContext,
    super.snapshotContext,
    super.mobileVitalsContext,
    super.lifeCycleContext,
    required super.labels,
    required super.spanId,
    required super.traceId,
    required super.environment,
    super.isSnapshotEvent,
  });

  factory EditableCxRumEvent.fromJson(Map<String, dynamic> json) {
    return EditableCxRumEvent(
      timestamp: json['timestamp'] as int,
      platform: json['platform'] as String,
      mobileSdk: json.containsKey('mobile_sdk') && json['mobile_sdk'] != null
          ? MobileSdk.fromJson(Map<String, dynamic>.from(json['mobile_sdk']))
          : null,
      versionMetadata: json.containsKey('version_metadata') &&
              json['version_metadata'] != null
          ? VersionMetaData.fromJson(
              Map<String, dynamic>.from(json['version_metadata']))
          : null,
      sessionContext:
          json.containsKey('session_context') && json['session_context'] != null
              ? SessionContext.fromJson(
                  Map<String, dynamic>.from(json['session_context']))
              : null,
      deviceContext:
          json.containsKey('device_context') && json['device_context'] != null
              ? DeviceContext.fromJson(
                  Map<String, dynamic>.from(json['device_context']))
              : null,
      deviceState:
          json.containsKey('device_state') && json['device_state'] != null
              ? DeviceState.fromJson(
                  Map<String, dynamic>.from(json['device_state']))
              : null,
      viewContext:
          json.containsKey('view_context') && json['view_context'] != null
              ? ViewContext.fromJson(
                  Map<String, dynamic>.from(json['view_context']))
              : null,
      eventContext:
          json.containsKey('event_context') && json['event_context'] != null
              ? EventContext.fromJson(
                  Map<String, dynamic>.from(json['event_context']))
              : null,
      errorContext:
          json.containsKey('error_context') && json['error_context'] != null
              ? ErrorContext.fromJson(
                  Map<String, dynamic>.from(json['error_context']))
              : null,
      logContext: json.containsKey('log_context') && json['log_context'] != null
          ? LogContext.fromJson(Map<String, dynamic>.from(json['log_context']))
          : null,
      networkRequestContext: json.containsKey('network_request_context') &&
              json['network_request_context'] != null
          ? NetworkRequestContext.fromJson(
              Map<String, dynamic>.from(json['network_request_context']))
          : null,
      snapshotContext: json.containsKey('snapshot_context') &&
              json['snapshot_context'] != null
          ? SnapshotContext.fromJson(
              Map<String, dynamic>.from(json['snapshot_context']))
          : null,
      mobileVitalsContext: json.containsKey('mobile_vitals_context') &&
              json['mobile_vitals_context'] != null
          ? MobileVitalsContext.fromJson(
              Map<String, dynamic>.from(json['mobile_vitals_context']))
          : null,
      lifeCycleContext: json.containsKey('life_cycle_context') &&
              json['life_cycle_context'] != null
          ? LifeCycleContext.fromJson(
              Map<String, dynamic>.from(json['life_cycle_context']))
          : null,
      labels: json.containsKey('labels') && json['labels'] != null
          ? Map<String, dynamic>.from(json['labels'] as Map)
          : {},
      spanId: json['spanId'] as String,
      traceId: json['traceId'] as String,
      environment: json['environment'] as String,
      isSnapshotEvent: json['isSnapshotEvent'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'platform': platform,
      'mobile_sdk': mobileSdk?.toJson(),
      'version_metadata': versionMetadata?.toJson(),
      'session_context': sessionContext?.toJson(),
      'device_context': deviceContext?.toJson(),
      'device_state': deviceState?.toJson(),
      'view_context': viewContext?.toJson(),
      'event_context': eventContext?.toJson(),
      'error_context': errorContext?.toJson(),
      'log_context': logContext?.toJson(),
      'network_request_context': networkRequestContext?.toJson(),
      'snapshot_context': snapshotContext?.toJson(),
      'mobile_vitals_context': mobileVitalsContext?.toJson(),
      'life_cycle_context': lifeCycleContext?.toJson(),
      'labels': labels,
      'spanId': spanId,
      'traceId': traceId,
      'environment': environment,
      'isSnapshotEvent': isSnapshotEvent,
    };
  }
}

class AndroidEditableCxRumEvent extends EditableCxRumEvent {
  final UserContext? userContext;
  final CustomMeasurementContext? customMeasurementContext;
  final InteractionContext? interactionContext;

  AndroidEditableCxRumEvent({
    required super.platform,
    required super.timestamp,
    required super.labels,
    required super.spanId,
    required super.traceId,
    required super.environment,
    super.eventContext,
    super.viewContext,
    super.isSnapshotEvent,
    super.errorContext,
    super.logContext,
    super.networkRequestContext,
    super.snapshotContext,
    super.lifeCycleContext,
    this.userContext,
    this.customMeasurementContext,
    this.interactionContext
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventContext': eventContext?.toJson(),
      'labels': labels,
      'spanId': spanId,
      'traceId': traceId,
      'environment': environment,
      'viewContext': viewContext?.toJson(),
      'isSnapshotEvent': isSnapshotEvent,
      'errorContext': errorContext?.toJson(),
      'logContext': logContext?.toJson(),
      'networkRequestContext': networkRequestContext?.toJson(),
      'snapshotContext': snapshotContext?.toJson(),
      'userContext': userContext?.toJson(),
      'lifecycleContext': lifeCycleContext?.toJson(),
      'customMeasurementContext': customMeasurementContext?.toJson(),
      'interactionContext': interactionContext?.toJson(),
    };
  }

  factory AndroidEditableCxRumEvent.fromJson(Map<String, dynamic> map) {
    return AndroidEditableCxRumEvent(
      eventContext: map['eventContext'] != null
          ? EventContext.fromJson(Map<String, dynamic>.from(map['eventContext']))
          : null,
      labels: Map<String, dynamic>.from(map['labels']),
      spanId: map['spanId'],
      traceId: map['traceId'],
      environment: map['environment'],
      viewContext: map['viewContext'] != null
          ? ViewContext.fromJson(Map<String, dynamic>.from(map['viewContext']))
          : null,
      isSnapshotEvent: map['isSnapshotEvent'],
      errorContext: map['errorContext'] != null
          ? ErrorContext.fromJson(Map<String, dynamic>.from(map['errorContext']))
          : null,
      logContext: map['logContext'] != null
          ? LogContext.fromJson(Map<String, dynamic>.from(map['logContext']))
          : null,
      networkRequestContext: map['networkRequestContext'] != null
          ? NetworkRequestContext.fromJson(Map<String, dynamic>.from(map['networkRequestContext']))
          : null,
      snapshotContext: map['snapshotContext'] != null
          ? SnapshotContext.fromJson(Map<String, dynamic>.from(map['snapshotContext']))
          : null,
      userContext: map['userContext'] != null
          ? UserContext.fromJson(Map<String, dynamic>.from(map['userContext']))
          : null,
      lifeCycleContext: map['lifecycleContext'] != null
          ? LifeCycleContext.fromJson(Map<String, dynamic>.from(map['lifecycleContext']))
          : null,
      customMeasurementContext: map['customMeasurementContext'] != null
          ? CustomMeasurementContext.fromJson(Map<String, dynamic>.from(map['customMeasurementContext']))
          : null,
      interactionContext: map['interactionContext'] != null
          ? InteractionContext.fromJson(Map<String, dynamic>.from(map['interactionContext']))
          : null,
      platform: '',
      timestamp: 0,
    );
  }
}

class UserContext {
  final String userId;
  final String username;
  final String email;
  final Map<String, String> metadata;

  UserContext({
    this.userId = '',
    this.username = '',
    this.email = '',
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': username,
      'user_email': email,
      'user_metadata': metadata,
    };
  }

  factory UserContext.fromJson(Map<String, dynamic> json) {
    return UserContext(
      userId: json['user_id'] ?? '',
      username: json['user_name'] ?? '',
      email: json['user_email'] ?? '',
      metadata: json['user_metadata'] != null
          ? Map<String, String>.from(json['user_metadata'])
          : {},
    );
  }
}

class CustomMeasurementContext {
  final String name;
  final int value;

  CustomMeasurementContext({
    this.name = '',
    this.value = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }

  factory CustomMeasurementContext.fromJson(Map<String, dynamic> json) {
    return CustomMeasurementContext(
      name: json['name'] ?? '',
      value: (json['value'] as num?)?.toInt() ?? 0,
    );
  }
}

class InteractionContext {
  final String eventName;
  final String targetId;
  final String targetClassName;

  InteractionContext({
    this.eventName = '',
    this.targetId = '',
    this.targetClassName = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'event_name': eventName,
      'element_id': targetId,
      'element_class_name': targetClassName,
    };
  }

  factory InteractionContext.fromJson(Map<String, dynamic> json) {
    return InteractionContext(
      eventName: json['event_name'] ?? '',
      targetId: json['element_id'] ?? '',
      targetClassName: json['element_class_name'] ?? '',
    );
  }
}

typedef BeforeSendResult = EditableCxRumEvent?;
