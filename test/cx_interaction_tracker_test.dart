import 'package:flutter_test/flutter_test.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin_platform_interface.dart';
import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_domain.dart';
import 'package:cx_flutter_plugin/cx_instrumentation_type.dart';
import 'package:cx_flutter_plugin/cx_interaction_tracker.dart';
import 'package:cx_flutter_plugin/cx_session_replay_options.dart';
import 'package:cx_flutter_plugin/cx_types.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCxFlutterPluginPlatform
    with MockPlatformInterfaceMixin
    implements CxFlutterPluginPlatform {
  List<Map<String, dynamic>> capturedInteractions = [];

  @override
  Future<String?> initSdk(CXExporterOptions options) async => 'initialized';

  @override
  Future<String?> shutdown() async => 'shutdown';

  @override
  Future<String?> setUserInteraction(
      Map<String, dynamic> interactionDataContext) async {
    capturedInteractions.add(interactionDataContext);
    return 'ok';
  }

  @override
  Future<String?> log(CxLogSeverity severity, String message,
          Map<String, dynamic> data) async =>
      'ok';

  @override
  Future<String?> setNetworkRequestContext(
          Map<String, dynamic> networkRequestContext) async =>
      'ok';

  @override
  Future<String?> setLabels(Map<String, dynamic> labels) async => 'ok';

  @override
  Future<String?> setUserContext(UserMetadata userContext) async => 'ok';

  @override
  Future<String?> setApplicationContext(
          String applicationName, String applicationVersion) async =>
      'ok';

  @override
  Future<String?> reportError(
          String message, Map<String, dynamic>? data, String? stackTrace) async =>
      'ok';

  @override
  Future<String?> getSessionId() async => 'session-123';

  @override
  Future<bool> isInitialized() async => true;

  @override
  Future<Map<String, dynamic>?> getLabels() async => {};

  @override
  Future<String?> sendCustomMeasurement(String name, double value) async =>
      'ok';

  @override
  Future<String?> setView(String name) async => 'ok';

  @override
  Future<String?> sendCxSpanData(Function(Map<String, dynamic>) cxSpan) async =>
      'ok';

  @override
  Future<String?> initializeSessionReplay(CXSessionReplayOptions options) async =>
      'ok';

  @override
  Future<bool> isRecording() async => false;

  @override
  Future<bool> isSessionReplayInitialized() async => false;

  @override
  Future<void> shutdownSessionReplay() async {}

  @override
  Future<void> startSessionRecording() async {}

  @override
  Future<void> stopSessionRecording() async {}

  @override
  Future<void> captureScreenshot() async {}

  @override
  Future<void> registerMaskRegion(String id) async {}

  @override
  Future<void> unregisterMaskRegion(String id) async {}

  @override
  Future<String?> getSessionReplayFolderPath() async => null;

  void reset() {
    capturedInteractions.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCxFlutterPluginPlatform mockPlatform;
  late CxFlutterPluginPlatform originalPlatform;

  setUp(() {
    originalPlatform = CxFlutterPluginPlatform.instance;
    mockPlatform = MockCxFlutterPluginPlatform();
    CxFlutterPluginPlatform.instance = mockPlatform;
    CxInteractionTracker.shutdown();
  });

  tearDown(() {
    CxInteractionTracker.shutdown();
    mockPlatform.reset();
    CxFlutterPluginPlatform.instance = originalPlatform;
  });

  group('CxInteractionTracker userActions configuration', () {
    test('does not initialize tracker when userActions is false', () async {
      final options = CXExporterOptions(
        userContext: null,
        environment: 'test',
        application: 'test-app',
        version: '1.0.0',
        publicKey: 'test-key',
        coralogixDomain: CXDomain.us2,
        enableSwizzling: false,
        instrumentations: {
          CXInstrumentationType.userActions.value: false,
        },
      );

      await CxFlutterPlugin.initSdk(options);

      // Tracker should not be initialized
      expect(CxInteractionTracker.isInitialized, isFalse);
    });

    test('initializes tracker when userActions is true', () async {
      final options = CXExporterOptions(
        userContext: null,
        environment: 'test',
        application: 'test-app',
        version: '1.0.0',
        publicKey: 'test-key',
        coralogixDomain: CXDomain.us2,
        enableSwizzling: false,
        instrumentations: {
          CXInstrumentationType.userActions.value: true,
        },
      );

      await CxFlutterPlugin.initSdk(options);

      // Tracker should be initialized
      expect(CxInteractionTracker.isInitialized, isTrue);
    });

    test('does not initialize tracker when instrumentations is null',
        () async {
      final options = CXExporterOptions(
        userContext: null,
        environment: 'test',
        application: 'test-app',
        version: '1.0.0',
        publicKey: 'test-key',
        coralogixDomain: CXDomain.us2,
        enableSwizzling: false,
        instrumentations: null,
      );

      await CxFlutterPlugin.initSdk(options);

      // Tracker should not be initialized
      expect(CxInteractionTracker.isInitialized, isFalse);
    });

    test('does not initialize tracker when userActions key is missing',
        () async {
      final options = CXExporterOptions(
        userContext: null,
        environment: 'test',
        application: 'test-app',
        version: '1.0.0',
        publicKey: 'test-key',
        coralogixDomain: CXDomain.us2,
        enableSwizzling: false,
        instrumentations: {
          CXInstrumentationType.network.value: true,
        },
      );

      await CxFlutterPlugin.initSdk(options);

      // Tracker should not be initialized (userActions not explicitly true)
      expect(CxInteractionTracker.isInitialized, isFalse);
    });
  });
}
