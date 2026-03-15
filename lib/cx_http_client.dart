import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_utils.dart';
import 'package:http/http.dart' as http;

class CxHttpClient extends http.BaseClient {
  final http.Client _inner;

  // Single secure RNG instance — Random.secure() allocates an OS-backed source
  // so it must not be created on every request.
  final _random = Random.secure();

  // Default constructor that creates its own http.Client
  CxHttpClient() : _inner = http.Client();

  // Constructor that accepts a custom http.Client (for testing or custom configuration)
  CxHttpClient.withClient(this._inner);

  String _generateHex(int length) {
    const chars = '0123456789abcdef';
    return List.generate(length, (_) => chars[_random.nextInt(16)]).join();
  }

  String generateTraceParent(String traceId, String spanId) {
    const version = '00';
    const traceFlags = '01';
    return '$version-$traceId-$spanId-$traceFlags';
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var stopwatch = Stopwatch()..start();
    final traceId = _generateHex(32); // 16 bytes
    final spanId = _generateHex(16);  // 8 bytes
    
    // Get options from global storage
    final options = CxFlutterPlugin.globalOptions;
    final shouldAddTraceParent = options != null && Utils.shouldAddTraceParent(request.url.toString(), options);
  
    if (shouldAddTraceParent) { 
      var traceparent = generateTraceParent(traceId, spanId);
      request.headers['traceparent'] = traceparent;
    }
    final response = await _inner.send(request);

    stopwatch.stop();
    var duration = stopwatch.elapsed;

    // bytesToString() decodes the stream as UTF-8. Binary or pre-compressed
    // responses will be garbled here, but that matches the Android SDK behaviour
    // for dart:http and is acceptable for RUM telemetry purposes.
    final responseBody = await response.stream.bytesToString();

    String? requestPayload;
    if (request is http.Request) {
      requestPayload = request.body.isEmpty ? null : request.body;
    }

    final captureContext = Utils.buildCaptureContext(
      url: request.url.toString(),
      rules: options?.networkCaptureConfig ?? [],
      reqHeaders: Map<String, String>.from(request.headers),
      resHeaders: Map<String, String>.from(response.headers),
      requestPayload: requestPayload,
      responsePayload: responseBody.isNotEmpty ? responseBody : null,
    );

    Map<String, dynamic> networkRequestContext = {
      'url': request.url.toString(),
      'host': request.url.host,
      'method': request.method,
      'status_code': response.statusCode,
      'status_text': response.reasonPhrase ?? '',
      'duration': duration.inMilliseconds,
      'http_response_body_size': responseBody.length,
      'fragments': request.url.fragment,
      'schema': request.url.scheme,
      ...captureContext,
    };

    if (shouldAddTraceParent) {
      networkRequestContext['traceId'] = traceId;
      networkRequestContext['spanId'] = spanId;
    }

    await CxFlutterPlugin.setNetworkRequestContext(networkRequestContext);

    // Return the response with a new stream
    return http.StreamedResponse(
      Stream.fromIterable([utf8.encode(responseBody)]),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  // Close the underlying http client
  @override
  void close() {
    _inner.close();
  }
}
