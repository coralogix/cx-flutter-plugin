import 'dart:math';
import 'package:dio/dio.dart' as dio;
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_utils.dart';

class CxDioInterceptor extends dio.Interceptor {
  static const _kStartTimeKey = '_cx_start_time';

  String _generateHex(int length) {
    const chars = '0123456789abcdef';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(16)]).join();
  }

  String _generateTraceParent(String traceId, String spanId) {
    return '00-$traceId-$spanId-01';
  }

  String? _serializeBody(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.isEmpty ? null : data;
    return data.toString();
  }

  int _responseBodySize(dynamic data) {
    if (data == null) return 0;
    if (data is String) return data.length;
    if (data is List) return data.length;
    return data.toString().length;
  }

  Map<String, String> _flattenHeaders(dio.Headers headers) {
    final result = <String, String>{};
    headers.forEach((name, values) {
      result[name] = values.join(', ');
    });
    return result;
  }

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    options.extra[_kStartTimeKey] = DateTime.now().millisecondsSinceEpoch;

    final globalOptions = CxFlutterPlugin.globalOptions;
    if (globalOptions != null && Utils.shouldAddTraceParent(options.uri.toString(), globalOptions)) {
      final traceId = _generateHex(32);
      final spanId = _generateHex(16);
      options.headers['traceparent'] = _generateTraceParent(traceId, spanId);
      options.extra['_cx_trace_id'] = traceId;
      options.extra['_cx_span_id'] = spanId;
    }

    handler.next(options);
  }

  @override
  void onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) {
    _report(response.requestOptions, response: response);
    handler.next(response);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    _report(err.requestOptions, error: err);
    handler.next(err);
  }

  void _report(
    dio.RequestOptions options, {
    dio.Response? response,
    dio.DioException? error,
  }) {
    final startTime = options.extra[_kStartTimeKey] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    final traceId = options.extra['_cx_trace_id'] as String?;
    final spanId = options.extra['_cx_span_id'] as String?;

    final statusCode = response?.statusCode ?? error?.response?.statusCode ?? 0;
    final statusText = response?.statusMessage ?? error?.response?.statusMessage ?? '';
    final responseData = response?.data ?? error?.response?.data;
    final responseHeaders = response?.headers ?? error?.response?.headers;

    final Map<String, dynamic> context = {
      'url': options.uri.toString(),
      'host': options.uri.host,
      'method': options.method,
      'status_code': statusCode,
      'status_text': statusText,
      'duration': duration,
      'http_response_body_size': _responseBodySize(responseData),
      'fragments': options.uri.fragment,
      'schema': options.uri.scheme,
      'request_headers': options.headers.map((k, v) => MapEntry(k, v.toString())),
      if (responseHeaders != null) 'response_headers': _flattenHeaders(responseHeaders),
      if (options.data != null) 'request_payload': _serializeBody(options.data),
      if (responseData != null) 'response_payload': _serializeBody(responseData),
      if (error != null) 'error_message': error.message,
      if (traceId != null) 'traceId': traceId,
      if (spanId != null) 'spanId': spanId,
    };

    CxFlutterPlugin.setNetworkRequestContext(context);
  }
}
