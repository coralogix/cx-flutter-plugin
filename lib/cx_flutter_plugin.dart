import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_log_severity.dart';
import 'package:cx_flutter_plugin/user_context.dart';
import 'cx_flutter_plugin_platform_interface.dart';

class CxFlutterPlugin {
  static Future<String?> initSdk(CXExporterOptions options) {
    return CxFlutterPluginPlatform.instance.initSdk(options);
  }

  static Future<void> setNetworkRequestContext(
      Map<String, dynamic> networkRequestContext) {
      return CxFlutterPluginPlatform.instance
        .setNetworkRequestContext(networkRequestContext);
  }

  static Future<String?> setUserContext(UserContext userContext) {
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

  static Future<String?> shutdown() {
    return CxFlutterPluginPlatform.instance.shutdown();
  }  

  static Future<String?> setView(String name) {
    return CxFlutterPluginPlatform.instance.setView(name);
  } 
}
