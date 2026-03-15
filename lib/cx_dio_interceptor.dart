import 'dart:math';
import 'package:dio/dio.dart' as dio;
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_utils.dart';

class CxDioInterceptor extends dio.Interceptor {
  static const _kStartTimeKey = '_cx_start_time';

  // Single secure RNG instance — Random.secure() allocates an OS-backed source
  // so it must not be created on every request.
  final _random = Random.secure();

  String _generateHex(int length) {
    const chars = '0123456789abcdef';
    return List.generate(length, (_) => chars[_random.nextInt(16)]).join();
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

    final allReqHeaders =
        options.headers.map((k, v) => MapEntry(k, v.toString())).cast<String, String>();

    final captureContext = Utils.buildCaptureContext(
      url: options.uri.toString(),
      rules: CxFlutterPlugin.globalOptions?.networkCaptureConfig ?? [],
      reqHeaders: allReqHeaders,
      resHeaders: responseHeaders != null ? _flattenHeaders(responseHeaders) : null,
      requestPayload: _serializeBody(options.data),
      responsePayload: _serializeBody(responseData),
    );

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
      ...captureContext,
      if (error?.message?.isNotEmpty == true) 'error_message': error!.message,
      if (traceId != null) 'traceId': traceId,
      if (spanId != null) 'spanId': spanId,
    };

    // Fire-and-forget: the interceptor API is synchronous so we cannot await.
    // Telemetry delivery failures are non-fatal.
    CxFlutterPlugin.setNetworkRequestContext(context);
  }
}
