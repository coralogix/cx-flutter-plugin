
import 'package:cx_flutter_plugin/cx_domain.dart';
import 'package:cx_flutter_plugin/cx_user_context.dart';

class CXExporterOptions {
  // Configuration for user context
  UserContext? userContext;

  // Turns on/off internal debug logging
  final bool debug;

  // Applies for Fetch URLs. URLs that match that regex will not be traced.
  final List<String>? ignoreUrls;

  // A pattern for error messages which should not be sent to Coralogix. By default, all errors will be sent.
  final List<String>? ignoreErrors;

  // Coralogix account domain
  final CXDomain coralogixDomain;

  // Coralogix token
  String publicKey;

  // Environment
  final String environment;

  // Application name
  final String application;

  // Application version
  final String version;

  final String? customDomainUrl;

  Map<String, dynamic>? labels;

  CXExporterOptions({
    required this.coralogixDomain,
    this.userContext,
    required this.environment,
    required this.application,
    required this.version,
    required this.publicKey,
    this.ignoreUrls,
    this.ignoreErrors,
    this.customDomainUrl,
    this.labels,
    this.debug = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userContext': userContext?.toMap(),
      'debug': debug,
      'ignoreUrls': ignoreUrls,
      'ignoreErrors': ignoreErrors,
      'coralogixDomain': coralogixDomain.url,
      'publicKey': publicKey,
      'environment': environment,
      'application': application,
      'version': version,
      'customDomainUrl': customDomainUrl,
      'labels': labels,
    };
  }
}