import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_utils.dart';
import 'package:http/http.dart' as http;

class CxHttpClient extends http.BaseClient {
  final http.Client _inner;

  CxHttpClient(this._inner);

  String generateTraceParent(String traceId, String spanId) {
    const version = '00';
    const traceFlags = '01';
    return '$version-$traceId-$spanId-$traceFlags';
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var stopwatch = Stopwatch()..start();
     String generateHex(int length) {
      const chars = '0123456789abcdef';
      return List.generate(length, (_) => chars[Random().nextInt(16)]).join();
    }
    
    final traceId = generateHex(32); // 16 bytes
    final spanId = generateHex(16);  // 8 bytes
    
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

    final responseBody = await response.stream.bytesToString();

    Map<String, dynamic> networkRequestContext = {
      'url': request.url.toString(),
      'host': request.url.host,
      'method': request.method,
      'status_code': response.statusCode,
      'duration': duration.inMilliseconds,
      'http_response_body_size': responseBody.length,
      'fragments': request.url.fragment,
      'schema': request.url.scheme,
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
}
