import 'package:flutter_test/flutter_test.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin_platform_interface.dart';
import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_domain.dart';
import 'package:cx_flutter_plugin/cx_instrumentation_type.dart';
import 'package:cx_flutter_plugin/cx_interaction_tracker.dart';
import 'package:cx_flutter_plugin/cx_interaction_types.dart';
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

  group('CxInteractionData schema validation', () {
    test('click event has required fields', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'ElevatedButton',
        elementClasses: 'ElevatedButton',
        targetElementInnerText: 'Submit',
        attributes: {'x': 100.0, 'y': 200.0},
      );

      final map = data.toMap();

      // Required fields
      expect(map['event_name'], equals('click'));
      expect(map['target_element'], equals('ElevatedButton'));
      
      // Optional fields that are present
      expect(map['element_classes'], equals('ElevatedButton'));
      expect(map['target_element_inner_text'], equals('Submit'));
      expect(map['attributes'], isA<Map>());
      expect(map['attributes']['x'], equals(100.0));
      expect(map['attributes']['y'], equals(200.0));
      
      // Should not have scroll_direction for click
      expect(map.containsKey('scroll_direction'), isFalse);
    });

    test('scroll event has required fields', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.scroll,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.up,
      );

      final map = data.toMap();

      // Required fields
      expect(map['event_name'], equals('scroll'));
      expect(map['target_element'], equals('Screen'));
      expect(map['scroll_direction'], equals('up'));
      
      // Should not have click-specific fields
      expect(map.containsKey('attributes'), isFalse);
      expect(map.containsKey('target_element_inner_text'), isFalse);
    });

    test('swipe event has required fields', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.swipe,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.left,
      );

      final map = data.toMap();

      // Required fields
      expect(map['event_name'], equals('swipe'));
      expect(map['target_element'], equals('Screen'));
      expect(map['scroll_direction'], equals('left'));
    });

    test('empty elementClasses is not included in map', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'Button',
        elementClasses: '',
      );

      final map = data.toMap();
      expect(map.containsKey('element_classes'), isFalse);
    });

    test('empty elementId is not included in map', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'Button',
        elementId: '',
      );

      final map = data.toMap();
      expect(map.containsKey('element_id'), isFalse);
    });

    test('icon font characters are filtered from targetElementInnerText', () {
      // Icon font character (Material Icons use Private Use Area)
      final iconChar = String.fromCharCode(0xE87C); // home icon
      
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'IconButton',
        targetElementInnerText: iconChar,
      );

      final map = data.toMap();
      expect(map.containsKey('target_element_inner_text'), isFalse);
    });

    test('real text is preserved in targetElementInnerText', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'TextButton',
        targetElementInnerText: 'Click Me',
      );

      final map = data.toMap();
      expect(map['target_element_inner_text'], equals('Click Me'));
    });

    test('whitespace-only targetElementInnerText is not included', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'Button',
        targetElementInnerText: '   ',
      );

      final map = data.toMap();
      expect(map.containsKey('target_element_inner_text'), isFalse);
    });
  });

  group('ScrollDirection enum', () {
    test('up direction has correct value', () {
      expect(ScrollDirection.up.value, equals('up'));
    });

    test('down direction has correct value', () {
      expect(ScrollDirection.down.value, equals('down'));
    });

    test('left direction has correct value', () {
      expect(ScrollDirection.left.value, equals('left'));
    });

    test('right direction has correct value', () {
      expect(ScrollDirection.right.value, equals('right'));
    });
  });

  group('InteractionEventName enum', () {
    test('click event has correct value', () {
      expect(InteractionEventName.click.value, equals('click'));
    });

    test('scroll event has correct value', () {
      expect(InteractionEventName.scroll.value, equals('scroll'));
    });

    test('swipe event has correct value', () {
      expect(InteractionEventName.swipe.value, equals('swipe'));
    });
  });

  group('CxInteractionData toString', () {
    test('toString includes all relevant fields', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'Card',
        elementClasses: 'Card',
        scrollDirection: null,
      );

      final str = data.toString();
      expect(str, contains('eventName: InteractionEventName.click'));
      expect(str, contains('targetElement: Card'));
      expect(str, contains('elementClasses: Card'));
    });
  });

  group('Click event schema validation', () {
    test('click event with all optional fields', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'ElevatedButton',
        elementClasses: 'ElevatedButton',
        elementId: 'submit-button',
        targetElementInnerText: 'Submit Form',
        attributes: {'x': 150.5, 'y': 300.25},
      );

      final map = data.toMap();

      expect(map['event_name'], equals('click'));
      expect(map['target_element'], equals('ElevatedButton'));
      expect(map['element_classes'], equals('ElevatedButton'));
      expect(map['element_id'], equals('submit-button'));
      expect(map['target_element_inner_text'], equals('Submit Form'));
      expect(map['attributes']['x'], equals(150.5));
      expect(map['attributes']['y'], equals(300.25));
    });

    test('click event with minimal fields', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: 'Screen',
      );

      final map = data.toMap();

      expect(map['event_name'], equals('click'));
      expect(map['target_element'], equals('Screen'));
      expect(map.length, equals(2)); // Only required fields
    });
  });

  group('Scroll event schema validation', () {
    test('scroll up event', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.scroll,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.up,
      );

      final map = data.toMap();

      expect(map['event_name'], equals('scroll'));
      expect(map['target_element'], equals('Screen'));
      expect(map['scroll_direction'], equals('up'));
    });

    test('scroll down event', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.scroll,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.down,
      );

      final map = data.toMap();
      expect(map['scroll_direction'], equals('down'));
    });

    test('scroll left event', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.scroll,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.left,
      );

      final map = data.toMap();
      expect(map['scroll_direction'], equals('left'));
    });

    test('scroll right event', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.scroll,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.right,
      );

      final map = data.toMap();
      expect(map['scroll_direction'], equals('right'));
    });
  });

  group('Swipe event schema validation', () {
    test('swipe up event', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.swipe,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.up,
      );

      final map = data.toMap();

      expect(map['event_name'], equals('swipe'));
      expect(map['target_element'], equals('Screen'));
      expect(map['scroll_direction'], equals('up'));
    });

    test('swipe down event', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.swipe,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.down,
      );

      final map = data.toMap();
      expect(map['scroll_direction'], equals('down'));
    });

    test('swipe left event', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.swipe,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.left,
      );

      final map = data.toMap();
      expect(map['scroll_direction'], equals('left'));
    });

    test('swipe right event', () {
      final data = CxInteractionData(
        eventName: InteractionEventName.swipe,
        targetElement: 'Screen',
        scrollDirection: ScrollDirection.right,
      );

      final map = data.toMap();
      expect(map['scroll_direction'], equals('right'));
    });
  });
}
