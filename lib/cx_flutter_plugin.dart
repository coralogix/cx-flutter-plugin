import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_session_replay_options.dart';
import 'package:cx_flutter_plugin/cx_types.dart';

import 'cx_flutter_plugin_platform_interface.dart';

class CxFlutterPlugin {
  // Global storage for options
  static CXExporterOptions? _globalOptions;

  // Getter to access global options
  static CXExporterOptions? get globalOptions => _globalOptions;

  // Check if options are available
  static bool get hasGlobalOptions => _globalOptions != null;

  static Future<String?> initSdk(CXExporterOptions options) {
    // Save options globally for later use
    _globalOptions = options;
    return CxFlutterPluginPlatform.instance.initSdk(options);
  }

  static Future<String?> setNetworkRequestContext(
      Map<String, dynamic> networkRequestContext) {
      return CxFlutterPluginPlatform.instance
        .setNetworkRequestContext(networkRequestContext);
  }

  static Future<String?> setUserContext(UserMetadata userContext) {
    return CxFlutterPluginPlatform.instance
        .setUserContext(userContext);
  }

  static  Future<String?> setLabels(Map<String, dynamic> labels) {
     return CxFlutterPluginPlatform.instance.setLabels(labels);
  }

  static Future<String?> reportError(String message, Map<String, dynamic>? data, String? stackTrace) {
    return CxFlutterPluginPlatform.instance.reportError(message, data, stackTrace);
  }

  static Future<String?> log(CxLogSeverity severity, String message, Map<String, dynamic> data) {
    return CxFlutterPluginPlatform.instance.log(severity, message, data);
  }

  static Future<String?> sendCustomMeasurement(String name, double value) {
    return CxFlutterPluginPlatform.instance.sendCustomMeasurement(name, value);
  }

  static Future<String?> shutdown() {
    // Clear global options on shutdown
    _globalOptions = null;
    return CxFlutterPluginPlatform.instance.shutdown();
  }  

  static Future<String?> setView(String name) {
    return CxFlutterPluginPlatform.instance.setView(name);
  } 

  static Future<String?> sendCxSpanData(Function(Map<String, dynamic>) cxSpan) {
    return CxFlutterPluginPlatform.instance.sendCxSpanData(cxSpan);
  }

  static Future<Map<String, dynamic>?> getLabels() {
    return CxFlutterPluginPlatform.instance.getLabels();
  }

  static Future<bool> isInitialized() {
    return CxFlutterPluginPlatform.instance.isInitialized();
  }

  static Future<String?> getSessionId() {
    return CxFlutterPluginPlatform.instance.getSessionId();
  }

  static Future<String?> setApplicationContext(String applicationName, String applicationVersion) {
    return CxFlutterPluginPlatform.instance.setApplicationContext(applicationName, applicationVersion);
  }

  static Future<String?> recordFirstFrameTime(Map<String, dynamic> mobileVitals) {
    return CxFlutterPluginPlatform.instance.recordFirstFrameTime(mobileVitals);
  }

  // session replay methods
  static Future<String?> initializeSessionReplay(CXSessionReplayOptions options) {
    return CxFlutterPluginPlatform.instance.initializeSessionReplay(options);
  }

  static Future<bool> isSessionReplayInitialized() {
    return CxFlutterPluginPlatform.instance.isSessionReplayInitialized();
  }

  static Future<bool> isRecording() {
    return CxFlutterPluginPlatform.instance.isRecording();
  }

  static Future<void> shutdownSessionReplay() {
    return CxFlutterPluginPlatform.instance.shutdownSessionReplay();
  }

  static Future<void> startSessionRecording() {
    return CxFlutterPluginPlatform.instance.startSessionRecording();
  }

  static Future<void> stopSessionRecording() {
    return CxFlutterPluginPlatform.instance.stopSessionRecording();
  }
  
  static Future<void> captureScreenshot() {
    return CxFlutterPluginPlatform.instance.captureScreenshot();
  }

  static Future<void> registerMaskRegion(String id) {
    return CxFlutterPluginPlatform.instance.registerMaskRegion(id);
  }

  static Future<void> unregisterMaskRegion(String id) {
    return CxFlutterPluginPlatform.instance.unregisterMaskRegion(id);
  }

  static Future<String?> getSessionReplayFolderPath() {
    return CxFlutterPluginPlatform.instance.getSessionReplayFolderPath();
  }
}
