import 'dart:async';
import 'dart:convert';

import 'package:cx_flutter_plugin/cx_dio_interceptor.dart';
import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin_platform_interface.dart';
import 'package:cx_flutter_plugin/cx_http_client.dart';
import 'package:cx_flutter_plugin/cx_network_capture_rule.dart';
import 'package:cx_flutter_plugin/cx_domain.dart';
import 'package:cx_flutter_plugin/cx_session_replay_options.dart';
import 'package:cx_flutter_plugin/cx_types.dart';
import 'package:cx_flutter_plugin/cx_utils.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// ─── Shared mock platform ─────────────────────────────────────────────────────

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

// ─── Mock http.Client ─────────────────────────────────────────────────────────

class _MockHttpClient extends http.BaseClient {
  final int statusCode;
  final String body;
  final Map<String, String> responseHeaders;

  _MockHttpClient({
    this.statusCode = 200,
    this.body = '{"id":1}',
    this.responseHeaders = const {'content-type': 'application/json'},
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.fromIterable([utf8.encode(body)]),
      statusCode,
      headers: responseHeaders,
      reasonPhrase: 'OK',
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

CXExporterOptions _makeOptions({List<CxNetworkCaptureRule>? rules}) {
  return CXExporterOptions(
    coralogixDomain: CXDomain.eu2,
    publicKey: 'test-key',
    application: 'test',
    version: '1.0',
    environment: 'test',
    enableSwizzling: false,
    networkCaptureConfig: rules,
  );
}

Future<Map<String, dynamic>> _doHttpRequest({
  String url = 'https://example.com/api/items',
  String method = 'GET',
  String? body,
  Map<String, String> requestHeaders = const {
    'Accept': 'application/json',
    'Authorization': 'Bearer tok',
  },
  List<CxNetworkCaptureRule>? rules,
  MockPlatform? mock,
}) async {
  mock ??= MockPlatform();
  CxFlutterPluginPlatform.instance = mock;
  await CxFlutterPlugin.initSdk(_makeOptions(rules: rules));

  final client = CxHttpClient.withClient(_MockHttpClient());
  final uri = Uri.parse(url);
  final request = http.Request(method, uri)
    ..headers.addAll(requestHeaders);
  if (body != null) request.body = body;
  await client.send(request);
  return mock.capturedNetworkCalls.last;
}

// Dio helpers reused from cx_dio_interceptor_test pattern.

dio.RequestOptions _makeDioOptions({
  String method = 'GET',
  String url = 'https://example.com/api/items',
  dynamic data,
}) {
  final uri = Uri.parse(url);
  return dio.RequestOptions(
    path: url,
    method: method,
    data: data,
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer tok'},
    baseUrl: '${uri.scheme}://${uri.host}',
  );
}

dio.Response _makeDioResponse(
  dio.RequestOptions options, {
  int statusCode = 200,
  dynamic data = '{"id":1}',
}) {
  return dio.Response(
    requestOptions: options,
    statusCode: statusCode,
    statusMessage: 'OK',
    data: data,
    headers: dio.Headers.fromMap({
      'content-type': ['application/json'],
      'x-request-id': ['abc123'],
    }),
  );
}

Future<Map<String, dynamic>> _simulateDioSuccess({
  String url = 'https://example.com/api/items',
  String method = 'GET',
  dynamic requestData,
  dynamic responseData = '{"id":1}',
  List<CxNetworkCaptureRule>? rules,
  required MockPlatform mock,
}) async {
  CxFlutterPluginPlatform.instance = mock;
  await CxFlutterPlugin.initSdk(_makeOptions(rules: rules));

  final interceptor = CxDioInterceptor();
  final options = _makeDioOptions(method: method, url: url, data: requestData);
  interceptor.onRequest(options, dio.RequestInterceptorHandler());

  final response = _makeDioResponse(options, data: responseData);
  interceptor.onResponse(response, dio.ResponseInterceptorHandler());

  await Future.delayed(Duration.zero);
  return mock.capturedNetworkCalls.last;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── Utils.resolveNetworkCaptureRule ──────────────────────────────────────────

  group('resolveNetworkCaptureRule', () {
    test('returns null for empty rules list', () {
      expect(
        Utils.resolveNetworkCaptureRule('https://example.com/api', []),
        isNull,
      );
    });

    test('returns null when no rules match', () {
      final rule = CxNetworkCaptureRule(url: 'https://other.com');
      expect(
        Utils.resolveNetworkCaptureRule('https://example.com/api', [rule]),
        isNull,
      );
    });

    test('matches exact URL', () {
      final rule = CxNetworkCaptureRule(url: 'https://example.com/api');
      expect(
        Utils.resolveNetworkCaptureRule('https://example.com/api', [rule]),
        same(rule),
      );
    });

    test('does not match partial URL with url field (exact only)', () {
      final rule = CxNetworkCaptureRule(url: 'https://example.com/api');
      expect(
        Utils.resolveNetworkCaptureRule('https://example.com/api/v2', [rule]),
        isNull,
      );
    });

    test('first match wins when multiple rules match', () {
      final rule1 = CxNetworkCaptureRule(url: 'https://example.com/api');
      final rule2 = CxNetworkCaptureRule(urlPattern: r'example\.com');
      expect(
        Utils.resolveNetworkCaptureRule(
            'https://example.com/api', [rule1, rule2]),
        same(rule1),
      );
    });

    test('skips non-matching rule and returns second match', () {
      final rule1 = CxNetworkCaptureRule(url: 'https://other.com');
      final rule2 = CxNetworkCaptureRule(urlPattern: r'example\.com');
      expect(
        Utils.resolveNetworkCaptureRule(
            'https://example.com/api', [rule1, rule2]),
        same(rule2),
      );
    });

    test('domain-only pattern matches full URL with scheme and path', () {
      final rule = CxNetworkCaptureRule(urlPattern: r'example\.com');
      expect(
        Utils.resolveNetworkCaptureRule(
            'https://example.com/api/v1', [rule]),
        same(rule),
      );
    });

    test('path-only pattern matches full URL', () {
      final rule = CxNetworkCaptureRule(urlPattern: r'/api/v2/users');
      expect(
        Utils.resolveNetworkCaptureRule(
            'https://example.com/api/v2/users', [rule]),
        same(rule),
      );
    });

    test('domain-only pattern does not match different domain', () {
      final rule = CxNetworkCaptureRule(urlPattern: r'example\.com');
      expect(
        Utils.resolveNetworkCaptureRule('https://other.com/api', [rule]),
        isNull,
      );
    });

    test('wildcard pattern matches multiple URLs', () {
      final rule = CxNetworkCaptureRule(urlPattern: r'.*\.example\.com.*');
      expect(Utils.resolveNetworkCaptureRule('https://api.example.com/v1', [rule]), same(rule));
      expect(Utils.resolveNetworkCaptureRule('https://cdn.example.com/img', [rule]), same(rule));
    });
  });

  // ── Utils.filterHeaders ──────────────────────────────────────────────────────

  group('filterHeaders', () {
    test('returns empty map for empty allowlist', () {
      final headers = {'Content-Type': 'application/json', 'Accept': 'text/html'};
      expect(Utils.filterHeaders(headers, []), isEmpty);
    });

    test('returns empty map when no headers match allowlist', () {
      final headers = {'Authorization': 'Bearer token'};
      expect(Utils.filterHeaders(headers, ['Content-Type']), isEmpty);
    });

    test('output key uses allowlist casing, not input header casing', () {
      // Header arrives as 'content-type', allowlist has 'Content-Type' →
      // output key should be 'Content-Type' (mirrors Android SDK behaviour).
      final headers = {'content-type': 'application/json'};
      final result = Utils.filterHeaders(headers, ['Content-Type']);
      expect(result, {'Content-Type': 'application/json'});
    });

    test('allowlist with different casing still matches and normalises key', () {
      final headers = {'ACCEPT': 'text/html'};
      expect(Utils.filterHeaders(headers, ['accept']), {'accept': 'text/html'});
    });

    test('returns multiple matching headers using allowlist key casing', () {
      final headers = {
        'content-type': 'application/json',
        'accept': 'text/html',
        'authorization': 'Bearer token',
      };
      final result = Utils.filterHeaders(headers, ['Content-Type', 'Accept']);
      // Output keys come from the allowlist, not from the input map.
      expect(result.keys, containsAll(['Content-Type', 'Accept']));
      expect(result.containsKey('authorization'), isFalse);
    });

    test('preserves header values exactly and uses allowlist key casing', () {
      final headers = {'X-Custom': 'foo=bar; baz=qux'};
      final result = Utils.filterHeaders(headers, ['x-custom']);
      // Output key comes from allowlist, value is preserved.
      expect(result['x-custom'], 'foo=bar; baz=qux');
    });
  });

  // ── CxHttpClient with NetworkCaptureRule ─────────────────────────────────────

  group('CxHttpClient – NetworkCaptureRule', () {
    late MockPlatform mock;

    setUp(() {
      mock = MockPlatform();
    });

    test('no rules configured: headers and payloads not captured', () async {
      final ctx = await _doHttpRequest(
        method: 'POST',
        body: 'hello',
        rules: null,
        mock: mock,
      );
      expect(ctx.containsKey('request_headers'), isFalse);
      expect(ctx.containsKey('response_headers'), isFalse);
      expect(ctx.containsKey('request_payload'), isFalse);
      expect(ctx.containsKey('response_payload'), isFalse);
    });

    test('matching rule applies reqHeaders allowlist', () async {
      final ctx = await _doHttpRequest(
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            reqHeaders: ['Accept'],
            resHeaders: ['content-type'],
          ),
        ],
        mock: mock,
      );
      final reqH = ctx['request_headers'] as Map?;
      expect(reqH, isNotNull);
      expect(reqH!.keys.map((k) => (k as String).toLowerCase()), contains('accept'));
      // Authorization header must be filtered out.
      expect(reqH.keys.map((k) => (k as String).toLowerCase()), isNot(contains('authorization')));
    });

    test('matching rule with null reqHeaders: request_headers absent', () async {
      final ctx = await _doHttpRequest(
        rules: [
          CxNetworkCaptureRule(urlPattern: r'example\.com'),
        ],
        mock: mock,
      );
      expect(ctx.containsKey('request_headers'), isFalse);
      expect(ctx.containsKey('response_headers'), isFalse);
    });

    test('collectReqPayload=false: request_payload absent', () async {
      final ctx = await _doHttpRequest(
        method: 'POST',
        body: 'data',
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            collectReqPayload: false,
            collectResPayload: true,
          ),
        ],
        mock: mock,
      );
      expect(ctx.containsKey('request_payload'), isFalse);
      expect(ctx.containsKey('response_payload'), isTrue);
    });

    test('collectResPayload=false: response_payload absent', () async {
      final ctx = await _doHttpRequest(
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            collectReqPayload: true,
            collectResPayload: false,
          ),
        ],
        mock: mock,
      );
      expect(ctx.containsKey('response_payload'), isFalse);
    });

    test('collectReqPayload=true and collectResPayload=true: both payloads present', () async {
      final ctx = await _doHttpRequest(
        method: 'POST',
        body: 'payload',
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            collectReqPayload: true,
            collectResPayload: true,
          ),
        ],
        mock: mock,
      );
      expect(ctx['request_payload'], 'payload');
      expect(ctx.containsKey('response_payload'), isTrue);
    });

    test('no matching rule: headers and payloads suppressed', () async {
      final ctx = await _doHttpRequest(
        method: 'POST',
        body: 'secret',
        rules: [
          CxNetworkCaptureRule(url: 'https://other.com/endpoint'),
        ],
        mock: mock,
      );
      expect(ctx.containsKey('request_headers'), isFalse);
      expect(ctx.containsKey('response_headers'), isFalse);
      expect(ctx.containsKey('request_payload'), isFalse);
      expect(ctx.containsKey('response_payload'), isFalse);
    });
  });

  // ── CxDioInterceptor with NetworkCaptureRule ──────────────────────────────────

  group('CxDioInterceptor – NetworkCaptureRule', () {
    late MockPlatform mock;

    setUp(() {
      mock = MockPlatform();
    });

    test('no rules configured: headers and payloads not captured', () async {
      final ctx = await _simulateDioSuccess(
        method: 'POST',
        requestData: '{"name":"test"}',
        rules: null,
        mock: mock,
      );
      expect(ctx.containsKey('request_headers'), isFalse);
      expect(ctx.containsKey('response_headers'), isFalse);
      expect(ctx.containsKey('request_payload'), isFalse);
      expect(ctx.containsKey('response_payload'), isFalse);
    });

    test('matching rule applies reqHeaders allowlist', () async {
      final ctx = await _simulateDioSuccess(
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            reqHeaders: ['accept'],
            resHeaders: ['content-type'],
          ),
        ],
        mock: mock,
      );
      final reqH = ctx['request_headers'] as Map?;
      expect(reqH, isNotNull);
      expect(reqH!.keys.map((k) => (k as String).toLowerCase()), contains('accept'));
      expect(reqH.keys.map((k) => (k as String).toLowerCase()), isNot(contains('authorization')));

      final resH = ctx['response_headers'] as Map?;
      expect(resH, isNotNull);
      expect(resH!.keys.map((k) => (k as String).toLowerCase()), contains('content-type'));
      expect(resH.keys.map((k) => (k as String).toLowerCase()), isNot(contains('x-request-id')));
    });

    test('matching rule with null reqHeaders: request_headers absent', () async {
      final ctx = await _simulateDioSuccess(
        rules: [
          CxNetworkCaptureRule(urlPattern: r'example\.com'),
        ],
        mock: mock,
      );
      expect(ctx.containsKey('request_headers'), isFalse);
      expect(ctx.containsKey('response_headers'), isFalse);
    });

    test('collectReqPayload=true: request_payload present', () async {
      final ctx = await _simulateDioSuccess(
        method: 'POST',
        requestData: '{"key":"val"}',
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            collectReqPayload: true,
          ),
        ],
        mock: mock,
      );
      expect(ctx['request_payload'], '{"key":"val"}');
    });

    test('collectReqPayload=false: request_payload absent', () async {
      final ctx = await _simulateDioSuccess(
        method: 'POST',
        requestData: '{"key":"val"}',
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            collectReqPayload: false,
          ),
        ],
        mock: mock,
      );
      expect(ctx.containsKey('request_payload'), isFalse);
    });

    test('collectResPayload=true: response_payload present', () async {
      final ctx = await _simulateDioSuccess(
        responseData: '{"id":42}',
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            collectResPayload: true,
          ),
        ],
        mock: mock,
      );
      expect(ctx['response_payload'], '{"id":42}');
    });

    test('collectResPayload=false: response_payload absent', () async {
      final ctx = await _simulateDioSuccess(
        responseData: '{"id":42}',
        rules: [
          CxNetworkCaptureRule(
            urlPattern: r'example\.com',
            collectResPayload: false,
          ),
        ],
        mock: mock,
      );
      expect(ctx.containsKey('response_payload'), isFalse);
    });

    test('no matching rule: headers and payloads suppressed', () async {
      final ctx = await _simulateDioSuccess(
        method: 'POST',
        requestData: 'secret',
        rules: [
          CxNetworkCaptureRule(url: 'https://other.com/endpoint'),
        ],
        mock: mock,
      );
      expect(ctx.containsKey('request_headers'), isFalse);
      expect(ctx.containsKey('response_headers'), isFalse);
      expect(ctx.containsKey('request_payload'), isFalse);
      expect(ctx.containsKey('response_payload'), isFalse);
    });
  });
}
