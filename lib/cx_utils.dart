import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_network_capture_rule.dart';

// Missing classes that should be in cx_types.dart
class TraceParentInHeader {
  final bool enable;
  final List<String>? allowedTracingUrls;

  TraceParentInHeader({
    required this.enable,
    this.allowedTracingUrls,
  });

  static TraceParentInHeader params(Map<String, dynamic>? params) {
    if (params == null) {
      return TraceParentInHeader(enable: false);
    }
    
    final enable = params['enable'] ?? false;
    final options = params['options'] as Map<String, dynamic>?;
    
    List<String>? allowedTracingUrls;
    if (options != null && options['allowedTracingUrls'] != null) {
      allowedTracingUrls = List<String>.from(options['allowedTracingUrls']);
    }
    
    return TraceParentInHeader(
      enable: enable,
      allowedTracingUrls: allowedTracingUrls,
    );
  }
}

class Global {
  static bool isHostMatchesRegexPattern(String url, List<String> patterns) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      
      for (final pattern in patterns) {
        if (pattern.contains('*')) {
          // Simple wildcard matching
          final regexPattern = pattern.replaceAll('*', '.*');
          final regex = RegExp(regexPattern);
          if (regex.hasMatch(host)) {
            return true;
          }
        } else if (host == pattern) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class Utils {
  /// Returns the first [CxNetworkCaptureRule] whose [url] exactly matches or
  /// whose [urlPattern] regex matches [url]. Returns null if no rule matches.
  static CxNetworkCaptureRule? resolveNetworkCaptureRule(
      String url, List<CxNetworkCaptureRule> rules) {
    for (final rule in rules) {
      if (rule.url != null && rule.url == url) return rule;
      if (rule.urlPattern != null && RegExp(rule.urlPattern!).hasMatch(url)) return rule;
    }
    return null;
  }

  /// Filters [headers] to only those whose name (case-insensitive) appears in [allowlist].
  /// Output keys use the casing from [allowlist] (mirrors Android SDK behaviour).
  static Map<String, String> filterHeaders(
      Map<String, String> headers, List<String> allowlist) {
    final result = <String, String>{};
    for (final entry in headers.entries) {
      final configKey = allowlist.firstWhere(
        (k) => k.toLowerCase() == entry.key.toLowerCase(),
        orElse: () => '',
      );
      if (configKey.isNotEmpty) result[configKey] = entry.value;
    }
    return result;
  }

  static bool shouldAddTraceParent(String? requestURLString, CXExporterOptions options) {
    if (requestURLString == null) {
      return false;
    }

    final traceParentDict = options.traceParentInHeader;
    if (traceParentDict == null) {
      return false;
    }

    final traceParent = TraceParentInHeader.params(traceParentDict);

    if (!traceParent.enable) {
      return false;
    }

    final allowedUrls = traceParent.allowedTracingUrls;

    if (allowedUrls != null && allowedUrls.isNotEmpty) {
      if (allowedUrls.contains(requestURLString)) {
        return true;
      }

      return Global.isHostMatchesRegexPattern(requestURLString, allowedUrls);
    }

    return true;
  }
}
