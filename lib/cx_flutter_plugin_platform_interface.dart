import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_log_severity.dart';
import 'package:cx_flutter_plugin/cx_user_context.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cx_flutter_plugin_method_channel.dart';

abstract class CxFlutterPluginPlatform extends PlatformInterface {
  /// Constructs a CxFlutterPluginPlatform.
  CxFlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static CxFlutterPluginPlatform _instance = MethodChannelCxFlutterPlugin();

  /// The default instance of [CxFlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelCxFlutterPlugin].
  static CxFlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CxFlutterPluginPlatform] when
  /// they register themselves.
  static set instance(CxFlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> initSdk(CXExporterOptions options) {
    throw UnimplementedError('initSdk() has not been implemented.');
  }

  Future<String?> setNetworkRequestContext(Map<String, dynamic> networkRequestContext) {
    throw UnimplementedError('setNetworkRequestContext() has not been implemented.');
  }

  Future<String?> setUserContext(UserContext userContext) {
    throw UnimplementedError('setUserContext() has not been implemented.');
  }

  Future<String?> setLabels(Map<String, dynamic> labels) {
    throw UnimplementedError('setLabels() has not been implemented.');
  }

  Future<String?> log(CxLogSeverity severity, String message, Map<String, dynamic> data) {
    throw UnimplementedError('log() has not been implemented.');
  }

  Future<String?> reportError(String message, Map<String, dynamic>? data, String? stackTrace) {
    throw UnimplementedError('reportError() has not been implemented.');
  }

  Future<String?> shutdown() {
    throw UnimplementedError('shutdown() has not been implemented.');
  }  
   
  Future<String?> setView(String name) {
    throw UnimplementedError('setView() has not been implemented.');
  } 

  Future<String?> sendCxSpanData(Function(Map<String, dynamic>) cxSpan) {
    throw UnimplementedError('sendCxSpanData() has not been implemented.');
  }
}