import 'dart:async';

import 'package:cx_flutter_plugin/cx_domain.dart';
import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_http_client.dart';
import 'package:cx_flutter_plugin/cx_instrumentation_type.dart';
import 'package:cx_flutter_plugin/cx_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
//import 'package:http/io_client.dart';

const channel = MethodChannel('example.flutter.coralogix.io');

void main() {
  runZonedGuarded(() async {
    await dotenv.load();

    runApp(MaterialApp(
      title: 'Coralogix SDK Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MyApp(),
    ));
  }, (error, stackTrace) {
    CxFlutterPlugin.reportError(error.toString(), {}, stackTrace.toString());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Setup the cx SDK
    var userContext = UserMetadata(
      userId: 'user123',
      userName: 'John Doe',
      userEmail: 'john@example.com',
      userMetadata: {'role': 'admin'},
    );

    var coralogixDomain = CXDomain.eu2;

    var options = CXExporterOptions(
      coralogixDomain: coralogixDomain,
      userContext: userContext,
      environment: 'production',
      application: 'demo-app-flutter',
      version: '1.0.0',
      publicKey: dotenv.env['CORALOGIX_PUBLIC_KEY_EU2']!,
      ignoreUrls: [],
      ignoreErrors: [],
      //proxyUrl: 'https:127.0.0.1:8888',
      labels: {'item': 'playstation 5', 'itemPrice': 1999},
      sdkSampler: 100,
      mobileVitalsFPSSamplingRate: 150,
      instrumentations: {
        CXInstrumentationType.network.value: true,
        CXInstrumentationType.custom.value: true,
        CXInstrumentationType.errors.value: true,
        CXInstrumentationType.anr.value: false,
        CXInstrumentationType.lifeCycle.value: false,
        CXInstrumentationType.mobileVitals.value: false,
        CXInstrumentationType.userActions.value: false,
      },
      collectIPData: true,
      enableSwizzling: true,
      traceParentInHeader: { 'enable': true, 
                            'options': {
                                'allowedTracingUrls': ['https://jsonplaceholder.typicode.com/posts/']
                              }
                          },
      debug: true,
    );

    final isInitialize = await CxFlutterPlugin.initSdk(options);
    debugPrint('SDK: $isInitialize');
    await CxFlutterPlugin.setView("Main screen");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coralogix SDK Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Network Operations Section
              _SectionHeader(
                icon: Icons.cloud_outlined,
                title: 'Network Operations',
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.check_circle_outline,
                title: 'Successful Request',
                subtitle: 'Send a successful network request',
                color: Colors.green,
                onTap: () => sendNetworkRequest('https://jsonplaceholder.typicode.com/posts/'),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.error_outline,
                title: 'Failed Request',
                subtitle: 'Send a failed network request',
                color: Colors.red,
                onTap: () => sendNetworkRequest('https://coralogix.com/404'),
              ),
              const SizedBox(height: 24),

              // User & Context Section
              _SectionHeader(
                icon: Icons.person_outline,
                title: 'User & Context',
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.account_circle_outlined,
                title: 'Set User Context',
                subtitle: 'Update user metadata',
                color: colorScheme.secondary,
                onTap: sendUserContext,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.label_outline,
                title: 'Set Labels',
                subtitle: 'Add custom labels',
                color: colorScheme.tertiary,
                onTap: setLabels,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.label,
                title: 'Get Labels',
                subtitle: 'Retrieve current labels',
                color: colorScheme.tertiary,
                onTap: getLabels,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.app_settings_alt_outlined,
                title: 'Set Application Context',
                subtitle: 'Update app name and version',
                color: colorScheme.secondary,
                onTap: setApplicationContext,
              ),
              const SizedBox(height: 24),

              // Errors & Logging Section
              _SectionHeader(
                icon: Icons.bug_report_outlined,
                title: 'Errors & Logging',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.report_problem_outlined,
                title: 'Report Error',
                subtitle: 'Send an error report',
                color: Colors.red,
                onTap: reportError,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.description_outlined,
                title: 'Send Log',
                subtitle: 'Send a custom log message',
                color: Colors.blue,
                onTap: sendLog,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.rule_outlined,
                title: 'Assert Exception',
                subtitle: 'Trigger an assert failure',
                color: Colors.red,
                onTap: () {
                  assert(false, 'assert failure');
                },
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.warning_amber_outlined,
                title: 'Throw Exception',
                subtitle: 'Throw and catch an exception',
                color: Colors.orange,
                onTap: throwTryCatchInDart,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.error_outline,
                title: 'Throw on Pressed',
                subtitle: 'Throw exception on button press',
                color: Colors.red,
                onTap: throwEcexpotionInDart,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.dangerous_outlined,
                title: 'Swift Fatal Error',
                subtitle: 'Trigger native fatal error',
                color: Colors.deepPurple,
                onTap: () => platformExecute('fatalError'),
              ),
              const SizedBox(height: 24),

              // SDK Management Section
              _SectionHeader(
                icon: Icons.settings_outlined,
                title: 'SDK Management',
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.power_settings_new_outlined,
                title: 'SDK Shutdown',
                subtitle: 'Shutdown the SDK',
                color: Colors.grey,
                onTap: sdkShutdown,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.check_circle,
                title: 'Is Initialized',
                subtitle: 'Check SDK initialization status',
                color: Colors.green,
                onTap: isInitialized,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.fingerprint_outlined,
                title: 'Get Session ID',
                subtitle: 'Retrieve current session ID',
                color: colorScheme.primary,
                onTap: getSessionId,
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.analytics_outlined,
                title: 'Custom Measurement',
                subtitle: 'Send a custom measurement',
                color: Colors.teal,
                onTap: sendCustomMeasurement,
              ),
              const SizedBox(height: 24),

              // Navigation Section
              _SectionHeader(
                icon: Icons.navigation_outlined,
                title: 'Navigation',
                color: colorScheme.tertiary,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.open_in_new_outlined,
                title: 'Navigate to New Screen',
                subtitle: 'Open a new screen',
                color: colorScheme.tertiary,
                onTap: () => navigateToNewScreen(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> platformExecute(String method) async {
  await channel.invokeMethod(method);
}

Future<void> throwEcexpotionInDart() async {
  throw Exception('Throws onPressed');
}

Future<void> throwTryCatchInDart() async {
  try {
    throw StateError('state error try catch');
  } catch (error, stackTrace) {
    if (error is StateError) {
      // Handle the StateError
      var result = await CxFlutterPlugin.reportError(error.message, {}, stackTrace.toString());
      debugPrint('$result');
    }
  }
}

Future<void> setApplicationContext() async {
  await CxFlutterPlugin.setApplicationContext('demoApp-flutter2', '8.0.0');
}

Future<void> getSessionId() async {
  final sessionId = await CxFlutterPlugin.getSessionId();
  debugPrint('Session Id: $sessionId');
}

Future<void> setView(String name) async {
  await CxFlutterPlugin.setView(name);
}

Future<void> navigateToNewScreen(BuildContext context) async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const NewScreen()),
  );
}

Future<void> sendLog() async {
  await CxFlutterPlugin.log(CxLogSeverity.error, 'this is an error',
      {'fruit': 'banna', 'price': 1.30});
}

Future<void> reportError() async {
  var result = await CxFlutterPlugin.reportError(
      'this is an error', {'fruit': 'banna', 'price': 1.30}, "");
  debugPrint('$result');
}

Future<void> sdkShutdown() async {
  await CxFlutterPlugin.shutdown();
}

Future<void> setLabels() async {
  final labels = {'stock': 'NVDA', 'price': 104};
  await CxFlutterPlugin.setLabels(labels);
}

Future<void> sendCustomMeasurement() async {
  await CxFlutterPlugin.sendCustomMeasurement('test', 1.0);
}

Future<void> sendUserContext() async {
  var userContext = UserMetadata(
    userId: 'user123',
    userName: 'John Doe',
    userEmail: 'john@example.com',
    userMetadata: {'role': 'admin'},
  );

  await CxFlutterPlugin.setUserContext(userContext);
}

Future<void> getLabels() async {
  try {
    final labels = await CxFlutterPlugin.getLabels();
    if (labels != null) {
      debugPrint('Current labels: $labels');
    } else {
      debugPrint('No labels found');
    }
  } catch (e, stackTrace) {
    debugPrint('Error getting labels: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

Future<void> isInitialized() async {
  final isInitialized = await CxFlutterPlugin.isInitialized();
  debugPrint('Is Initialized: $isInitialized');
}

Future<void> sendNetworkRequest(String url) async {
  final client = CxHttpClient();
   await client.get(
    Uri.parse(url),
    headers: {
      'Accept': 'application/json',
      'User-Agent': 'FlutterApp/1.0', // Many APIs require this!
    },
  );
}

//  Future<void> sendNetworkRequest(String url) async {
//   final client = await createCxHttpClientWithProxy(); // ✅ await here

//   try {
//     final response = await client.get(
//       Uri.parse(url),
//       headers: {
//        'Accept': 'application/json',
//        'User-Agent': 'FlutterApp/1.0', // Many APIs require this!
//       },
//    );

//   } catch (e) {
//     debugPrint('Request error: $e');
//   } finally {
//     client.close();
//   }
//  }

// Future<CxHttpClient> createCxHttpClientWithProxy() async {
//   // Use 10.0.2.2 for Android emulator, localhost for iOS simulator
//   final proxy = Platform.isAndroid ? '10.0.2.2:9090' : 'localhost:9090';

//   final httpClient = HttpClient();
//   httpClient.findProxy = (uri) => "PROXY $proxy";
//   httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//   final ioClient = IOClient(httpClient);

//   return CxHttpClient(ioClient);
// }

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CxFlutterPlugin.setView('New Screen');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Screen'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                icon: Icons.cloud_outlined,
                title: 'Network Operations',
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.check_circle_outline,
                title: 'Successful Request',
                subtitle: 'Send a successful network request',
                color: Colors.green,
                onTap: () => sendNetworkRequest('https://jsonplaceholder.typicode.com/todos/1'),
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.bug_report_outlined,
                title: 'Error Testing',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.error_outline,
                title: 'Show Scaffold Error',
                subtitle: 'Trigger a scaffold error',
                color: Colors.red,
                onTap: () => Scaffold.of(context)
                    .showBottomSheet(
                      (context) => Container(
                        padding: const EdgeInsets.all(24),
                        child: const Text('Scaffold error'),
                      ),
                    ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
