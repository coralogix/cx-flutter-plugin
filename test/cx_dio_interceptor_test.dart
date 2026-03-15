import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:cx_flutter_plugin/cx_dio_interceptor.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin_platform_interface.dart';
import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_domain.dart';

import 'mock_platform.dart';

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
    // request_headers / response_headers are only present when a NetworkCaptureRule matches;
    // those cases are covered in cx_network_capture_rule_test.dart.
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
  // Payload capture requires a matching NetworkCaptureRule with collectReqPayload /
  // collectResPayload set to true. Without any rules configured, payloads are always
  // absent. Full payload capture behaviour is tested in cx_network_capture_rule_test.dart.

  test('request_payload is absent without a capture rule even when data is present', () async {
    final ctx = await simulateSuccess(method: 'POST', requestData: '{"name":"test"}');
    expect(ctx.containsKey('request_payload'), isFalse);
  });

  test('response_payload is absent without a capture rule even when data is present', () async {
    final ctx = await simulateSuccess(responseData: '{"id":1}');
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