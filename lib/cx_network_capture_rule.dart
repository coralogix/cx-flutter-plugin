/// Defines when and what network data to capture for a matching request.
///
/// Rules are evaluated in list order — the **first matching rule wins**.
/// Exactly one of [url] or [urlPattern] should be supplied per rule.
/// When both are provided, [url] is checked first as an exact match;
/// [urlPattern] is only evaluated if the exact match does not succeed.
class CxNetworkCaptureRule {
  /// Exact URL string to match against the full request URL.
  final String? url;

  /// Regex pattern matched against the full request URL.
  final String? urlPattern;

  /// Allowlist of request header names to capture (case-insensitive).
  /// When null, no request headers are captured for matching requests.
  final List<String>? reqHeaders;

  /// Allowlist of response header names to capture (case-insensitive).
  /// When null, no response headers are captured for matching requests.
  final List<String>? resHeaders;

  /// When true, captures the request body.
  final bool collectReqPayload;

  /// When true, captures the response body.
  final bool collectResPayload;

  const CxNetworkCaptureRule({
    this.url,
    this.urlPattern,
    this.reqHeaders,
    this.resHeaders,
    this.collectReqPayload = false,
    this.collectResPayload = false,
  }) : assert(url != null || urlPattern != null,
            'CxNetworkCaptureRule: at least one of url or urlPattern must be provided');

  Map<String, dynamic> toMap() => {
    if (url != null) 'url': url,
    if (urlPattern != null) 'urlPattern': urlPattern,
    if (reqHeaders != null) 'reqHeaders': reqHeaders,
    if (resHeaders != null) 'resHeaders': resHeaders,
    'collectReqPayload': collectReqPayload,
    'collectResPayload': collectResPayload,
  };
}
