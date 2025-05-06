import 'dart:async';

import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_log_severity.dart';
import 'package:cx_flutter_plugin/cx_types.dart';
import 'package:cx_flutter_plugin/cx_user_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cx_flutter_plugin_platform_interface.dart';

/// An implementation of [CxFlutterPluginPlatform] that uses method channels.
class MethodChannelCxFlutterPlugin extends CxFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  ///

  @visibleForTesting
  final methodChannel = const MethodChannel('cx_flutter_plugin');

  static const EventChannel _eventChannel =
      EventChannel('cx_flutter_plugin/onBeforeSend');

  StreamSubscription? _eventSubscription;

  EditableCxRumEvent? Function(EditableCxRumEvent)? _beforeSendCallback;

  @override
  Future<String?> initSdk(CXExporterOptions options) async {
    var arguments = options.toMap();
    // Remove beforeSend from arguments as it cannot be serialized
    arguments.remove('beforeSend');
    // Add flag to indicate presence of beforeSend callback
    arguments['beforeSend'] = options.beforeSend != null;
    final version =
        await methodChannel.invokeMethod<String>('initSdk', arguments);

    // If Dart-side beforeSend callback is provided, register it
    if (options.beforeSend != null) {
      _beforeSendCallback = options.beforeSend!;
      _startListening();
    }
    return version;
  }

  @override
  Future<String?> setNetworkRequestContext(
      Map<String, dynamic> networkRequestContext) async {
    try {
      final version = await methodChannel.invokeMethod<String>(
          'setNetworkRequestContext', networkRequestContext);
      return version;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<String?> setUserContext(UserContext userContext) async {
    var arguments = userContext.toMap();
    final version =
        await methodChannel.invokeMethod<String>('setUserContext', arguments);
    return version;
  }

  @override
  Future<String?> setLabels(Map<String, dynamic> labels) async {
    final version =
        await methodChannel.invokeMethod<String>('setLabels', labels);
    return version;
  }

  @override
  Future<String?> log(
      CxLogSeverity severity, String message, Map<String, dynamic> data) async {
    var arguments = {
      'severity': severity.value.toString(),
      'message': message,
      'data': data
    };
    final version = await methodChannel.invokeMethod<String>('log', arguments);
    return version;
  }

  @override
  Future<String?> reportError(
      String message, Map<String, dynamic>? data, String? stackTrace) async {
    Map<String, Object?> arguments;
    if (stackTrace != null) {
      arguments = {'message': message, 'data': data, 'stackTrace': stackTrace};
    } else {
      arguments = {'message': message, 'data': data};
    }
    final version =
        await methodChannel.invokeMethod<String>('reportError', arguments);
    return version;
  }

  @override
  Future<String?> shutdown() async {
    final version = await methodChannel.invokeMethod<String>('shutdown');
    return version;
  }

  @override
  Future<String?> setView(String name) async {
    var arguments = {'viewName': name};

    try {
      final version =
          await methodChannel.invokeMethod<String>('setView', arguments);
      return version;
    } on PlatformException {
      return null;
    }
  }

  void _startListening() {
    if (_eventSubscription != null) return;

    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic events) async {
        if (_beforeSendCallback == null || events == null || events is! List) {
          return;
        }

        final List<Map<String, dynamic>> processedEvents = [];

        for (final fullEvent in events) {
          try {
            debugPrint('Received event: $fullEvent');
            final fullEventMap = Map<String, dynamic>.from(fullEvent);
            final textMap = fullEventMap['text'];
            if (textMap is! Map) {
              print('Invalid "text" structure in event: $fullEventMap');
              return;
            }

            final cxRumRaw = textMap['cx_rum'];
            if (cxRumRaw is! Map) {
              print('Invalid or missing "cx_rum": $textMap');
              return;
            }

            final eventMap = Map<String, dynamic>.from(cxRumRaw);
            final editableEvent = EditableCxRumEvent.fromJson(eventMap);

            final result = _beforeSendCallback?.call(editableEvent);
            if (result == null) continue;

            final merged = {
              'text': {
                'cx_rum': result.toJson()
              }
            };

            processedEvents.add(merged);
          } catch (e, stackTrace) {
            debugPrint('Error in beforeSend callback: $e');
            debugPrint('Stack trace: $stackTrace');
          }
        }

        if (processedEvents.isNotEmpty) {
          await methodChannel.invokeMethod('sendCxSpanData', processedEvents);
        }
      },
      onError: (err) {
        debugPrint('onBeforeSend stream error: $err');
      },
    );
  }

  void stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}
