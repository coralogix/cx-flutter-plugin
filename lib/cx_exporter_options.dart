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

  // Number between 0-100 as a precentage of SDK should be init.
  final int sdkSampler;

  // The timeinterval the SDK will run the FPS sampling in an hour. default is every 1 minute.
  final int mobileVitalsFPSSamplingRate;

  // A list of instruments that you wish to switch off during runtime. all instrumentations are active by default.
  Map<String, bool>? instrumentations;

  // Determines whether the SDK should collect the user's IP address and corresponding geolocation data. Defaults to true.
  final bool collectIPData;

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
    this.sdkSampler = 100,
    this.mobileVitalsFPSSamplingRate = 300,
    this.instrumentations,
    this.collectIPData = true,
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
      'sdkSampler': sdkSampler,
      'mobileVitalsFPSSamplingRate': mobileVitalsFPSSamplingRate,
      'instrumentations': instrumentations,
      'collectIPData': collectIPData,
    };
  }
}