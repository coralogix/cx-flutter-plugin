import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin_platform_interface.dart';
import 'package:cx_flutter_plugin/cx_session_replay_options.dart';
import 'package:cx_flutter_plugin/cx_types.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPlatform
    with MockPlatformInterfaceMixin
    implements CxFlutterPluginPlatform {
  final List<Map<String, dynamic>> capturedNetworkCalls = [];

  @override
  Future<String?> setNetworkRequestContext(Map<String, dynamic> ctx) async {
    capturedNetworkCalls.add(Map<String, dynamic>.from(ctx));
    return 'ok';
  }

  @override Future<String?> initSdk(CXExporterOptions o) async => 'ok';
  @override Future<String?> shutdown() async => 'ok';
  @override Future<String?> setUserContext(UserMetadata u) async => 'ok';
  @override Future<String?> setLabels(Map<String, dynamic> l) async => 'ok';
  @override Future<String?> log(CxLogSeverity s, String m, Map<String, dynamic> d) async => 'ok';
  @override Future<String?> reportError(String m, Map<String, dynamic>? d, String? st) async => 'ok';
  @override Future<String?> setView(String n) async => 'ok';
  @override Future<String?> sendCxSpanData(Function(Map<String, dynamic>) f) async => 'ok';
  @override Future<Map<String, dynamic>?> getLabels() async => {};
  @override Future<bool> isInitialized() async => true;
  @override Future<String?> getSessionId() async => 'session-123';
  @override Future<String?> setApplicationContext(String n, String v) async => 'ok';
  @override Future<String?> initializeSessionReplay(CXSessionReplayOptions o) async => 'ok';
  @override Future<bool> isSessionReplayInitialized() async => false;
  @override Future<bool> isRecording() async => false;
  @override Future<void> shutdownSessionReplay() async {}
  @override Future<void> startSessionRecording() async {}
  @override Future<void> stopSessionRecording() async {}
  @override Future<void> captureScreenshot() async {}
  @override Future<void> registerMaskRegion(String id) async {}
  @override Future<void> unregisterMaskRegion(String id) async {}
  @override Future<String?> getSessionReplayFolderPath() async => null;
  @override Future<String?> setUserInteraction(Map<String, dynamic> m) async => 'ok';
  @override Future<String?> sendCustomMeasurement(String n, double v) async => 'ok';
}
