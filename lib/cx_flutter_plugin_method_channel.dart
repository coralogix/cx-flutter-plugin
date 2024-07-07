import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_log_severity.dart';
import 'package:cx_flutter_plugin/user_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'cx_flutter_plugin_platform_interface.dart';
import 'package:flutter/material.dart';

/// An implementation of [CxFlutterPluginPlatform] that uses method channels.
class MethodChannelCxFlutterPlugin extends CxFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  ///

  @visibleForTesting
  final methodChannel = const MethodChannel('cx_flutter_plugin');

  @override
  Future<String?> initSdk(CXExporterOptions options) async {
    var arguments = options.toMap();
    final version =
        await methodChannel.invokeMethod<String>('initSdk', arguments);
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
      'severity': severity.toString(),
      'message': message,
      'data': data
    };
    final version = await methodChannel.invokeMethod<String>('log', arguments);
    return version;
  }

  @override
  Future<String?> reportError(String message, Map<String, dynamic>? data,
      String? stackTrace) async {
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
}
