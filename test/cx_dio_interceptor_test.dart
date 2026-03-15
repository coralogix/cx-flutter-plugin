import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:cx_flutter_plugin/cx_dio_interceptor.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin_platform_interface.dart';
import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_domain.dart';
import 'package:cx_flutter_plugin/cx_session_replay_options.dart';
import 'package:cx_flutter_plugin/cx_types.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// ─── Mock platform ────────────────────────────────────────────────────────────

class MockPlatform with MockPlatformInterfaceMixin implements CxFlutterPluginPlatform {
  final List<Map<String, dynamic>> capturedNetworkCalls = [];

  @override
  Future<String?> setNetworkRequestContext(Map<String, dynamic> ctx) async {
    capturedNetworkCalls.add(Map<String, dynamic>.from(ctx));
    return 'ok';
  }

  // ── unused stubs ──────────────────────────────────────────────────────────
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

CXExporterOptions _makeExporterOptions({List<String> allowedTracingUrls = const []}) {
  return CXExporterOptions(
    coralogixDomain: CXDomain.eu2,
    publicKey: 'test-key',
    application: 'test',
    version: '1.0',
    environment: 'test',
    enableSwizzling: false,
    traceParentInHeader: {
      'enable': allowedTracingUrls.isNotEmpty,
      'options': {'allowedTracingUrls': allowedTracingUrls},
    },
  );
}

dio.RequestOptions _makeOptions({
  String method = 'GET',
  String url = 'https://example.com/api/items?foo=bar#section',
  dynamic data,
  Map<String, dynamic>? headers,
}) {
  final uri = Uri.parse(url);
  return dio.RequestOptions(
    path: url,
    method: method,
    data: data,
    headers: headers ?? {'Accept': 'application/json'},
    baseUrl: '${uri.scheme}://${uri.host}',
  );
}

dio.Response _makeResponse(
  dio.RequestOptions options, {
  int statusCode = 200,
  String statusMessage = 'OK',
  dynamic data = '{"id":1}',
  Map<String, List<String>>? headers,
}) {
  return dio.Response(
    requestOptions: options,
    statusCode: statusCode,
    statusMessage: statusMessage,
    data: data,
    headers: dio.Headers.fromMap(headers ?? {'content-type': ['application/json']}),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockPlatform mock;
  late CxDioInterceptor interceptor;

  setUp(() {
    mock = MockPlatform();
    CxFlutterPluginPlatform.instance = mock;
    interceptor = CxDioInterceptor();
  });

  // Helper: run onRequest then onResponse and return the reported context.
  Future<Map<String, dynamic>> simulateSuccess({
    String method = 'GET',
    String url = 'https://example.com/api/items',
    dynamic requestData,
    dynamic responseData = '{"id":1}',
    int statusCode = 200,
    String statusMessage = 'OK',
  }) async {
    final options = _makeOptions(method: method, url: url, data: requestData);

    interceptor.onRequest(options, dio.RequestInterceptorHandler());

    final response = _makeResponse(options, statusCode: statusCode, statusMessage: statusMessage, data: responseData);
    interceptor.onResponse(response, dio.ResponseInterceptorHandler());

    await Future.delayed(Duration.zero);
    return mock.capturedNetworkCalls.last;
  }

  Future<Map<String, dynamic>> simulateError({
    String url = 'https://example.com/api/missing',
    int? statusCode,
    String errorMessage = 'Connection refused',
  }) async {
    final options = _makeOptions(url: url);
    interceptor.onRequest(options, dio.RequestInterceptorHandler());

    dio.Response? errResponse;
    if (statusCode != null) {
      errResponse = _makeResponse(options, statusCode: statusCode, statusMessage: 'Error');
    }

    final err = dio.DioException(
      requestOptions: options,
      message: errorMessage,
      response: errResponse,
    );
    // ErrorInterceptorHandler.next completes a Completer with error in isolation.
    // Use runZonedGuarded to prevent the unhandled zone error from failing the test.
    final done = Completer<void>();
    runZonedGuarded(() {
      interceptor.onError(err, dio.ErrorInterceptorHandler());
      Future.delayed(Duration.zero).then((_) {
        if (!done.isCompleted) done.complete();
      });
    }, (e, s) {
      if (!done.isCompleted) done.complete();
    });
    await done.future;
    return mock.capturedNetworkCalls.last;
  }

  // ── Core fields ─────────────────────────────────────────────────────────────

  test('onResponse reports required network context keys', () async {
    final ctx = await simulateSuccess(url: 'https://example.com/api/items');

    expect(ctx['url'], 'https://example.com/api/items');
    expect(ctx['host'], 'example.com');
    expect(ctx['method'], 'GET');
    expect(ctx['status_code'], 200);
    expect(ctx['status_text'], 'OK');
    expect(ctx['schema'], 'https');
    expect(ctx['fragments'], '');
    expect(ctx.containsKey('duration'), isTrue);
    expect(ctx.containsKey('http_response_body_size'), isTrue);
    expect(ctx.containsKey('request_headers'), isTrue);
    expect(ctx.containsKey('response_headers'), isTrue);
  });

  test('duration is non-negative', () async {
    final ctx = await simulateSuccess();
    expect(ctx['duration'], greaterThanOrEqualTo(0));
  });

  test('url fragment is captured', () async {
    final ctx = await simulateSuccess(url: 'https://example.com/page#section');
    expect(ctx['fragments'], 'section');
  });

  // ── onRequest stores start time ──────────────────────────────────────────────

  test('onRequest stamps _cx_start_time in extra', () {
    final before = DateTime.now().millisecondsSinceEpoch;
    final options = _makeOptions();
    interceptor.onRequest(options, dio.RequestInterceptorHandler());
    final after = DateTime.now().millisecondsSinceEpoch;

    final stamp = options.extra['_cx_start_time'] as int?;
    expect(stamp, isNotNull);
    expect(stamp, greaterThanOrEqualTo(before));
    expect(stamp, lessThanOrEqualTo(after));
  });

  // ── Body size calculation ────────────────────────────────────────────────────

  test('http_response_body_size is 0 for null response data', () async {
    final ctx = await simulateSuccess(responseData: null);
    expect(ctx['http_response_body_size'], 0);
  });

  test('http_response_body_size uses string length', () async {
    final ctx = await simulateSuccess(responseData: 'hello');
    expect(ctx['http_response_body_size'], 5);
  });

  test('http_response_body_size uses list length', () async {
    final ctx = await simulateSuccess(responseData: [1, 2, 3]);
    expect(ctx['http_response_body_size'], 3);
  });

  // ── Request / response payload ───────────────────────────────────────────────

  test('request_payload is included when request has data', () async {
    final ctx = await simulateSuccess(method: 'POST', requestData: '{"name":"test"}');
    expect(ctx['request_payload'], '{"name":"test"}');
  });

  test('request_payload is absent when request data is null', () async {
    final ctx = await simulateSuccess(requestData: null);
    expect(ctx.containsKey('request_payload'), isFalse);
  });

  test('response_payload is included when response has data', () async {
    final ctx = await simulateSuccess(responseData: '{"id":1}');
    expect(ctx['response_payload'], '{"id":1}');
  });

  test('response_payload is absent when response data is null', () async {
    final ctx = await simulateSuccess(responseData: null);
    expect(ctx.containsKey('response_payload'), isFalse);
  });

  // ── onError path ─────────────────────────────────────────────────────────────

  test('onError reports status 0 when no response', () async {
    final ctx = await simulateError(statusCode: null);
    expect(ctx['status_code'], 0);
  });

  test('onError reports response status code when available', () async {
    final ctx = await simulateError(statusCode: 404);
    expect(ctx['status_code'], 404);
  });

  test('onError includes error_message', () async {
    final ctx = await simulateError(errorMessage: 'Connection refused');
    expect(ctx['error_message'], 'Connection refused');
  });

  test('onError error_message is absent on success path', () async {
    final ctx = await simulateSuccess();
    expect(ctx.containsKey('error_message'), isFalse);
  });

  // ── W3C Traceparent ───────────────────────────────────────────────────────────

  test('traceparent header and traceId/spanId injected when options allow', () async {
    // Set global options with traceParentInHeader enabled for this URL.
    await CxFlutterPlugin.initSdk(_makeExporterOptions(
      allowedTracingUrls: ['example.com'],
    ));

    final ctx = await simulateSuccess(url: 'https://example.com/api/items');

    expect(ctx.containsKey('traceId'), isTrue);
    expect(ctx.containsKey('spanId'), isTrue);
    expect((ctx['traceId'] as String).length, 32);
    expect((ctx['spanId'] as String).length, 16);
  });

  test('traceId/spanId absent when URL not in allowedTracingUrls', () async {
    await CxFlutterPlugin.initSdk(_makeExporterOptions(
      allowedTracingUrls: ['https://other.com/'],
    ));

    final ctx = await simulateSuccess(url: 'https://example.com/api/items');

    expect(ctx.containsKey('traceId'), isFalse);
    expect(ctx.containsKey('spanId'), isFalse);
  });
}