
import 'package:http/http.dart' as http;
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'dart:convert';
import 'dart:async';

class CxHttpClient extends http.BaseClient {
  final http.Client _inner;

  CxHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var stopwatch = Stopwatch()..start();

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
