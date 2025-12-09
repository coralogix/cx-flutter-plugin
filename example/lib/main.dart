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
import 'session_replay.dart';

const channel = MethodChannel('example.flutter.coralogix.io');

void main() {
  runZonedGuarded(() async {
    await dotenv.load();

    runApp(const MaterialApp(
      title: 'Navigation Basics',
      home: MyApp(),
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
  String? _sessionId;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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
      application: 'demo-app-ios-flutter',
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
        CXInstrumentationType.userActions.value: true,
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

    // Fetch session ID
    final sessionId = await CxFlutterPlugin.getSessionId();
    if (mounted) {
      setState(() {
        _sessionId = sessionId;
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _copySessionIdToClipboard(BuildContext context) async {
    if (_sessionId == null) return;
    
    await Clipboard.setData(ClipboardData(text: _sessionId!));
    
    // Use the GlobalKey if available, otherwise fall back to context
    final messenger = _scaffoldMessengerKey.currentState ?? 
                      (context.mounted ? ScaffoldMessenger.of(context) : null);
    
    if (messenger != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Session ID copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      debugPrint('Session ID copied to clipboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
          title: const Text(
            'Coralogix SDK Demo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            if (_sessionId != null)
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy Session ID',
                onPressed: () => _copySessionIdToClipboard(context),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_sessionId != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.fingerprint,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Session ID',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _sessionId!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        fontFamily: 'monospace',
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_sessionId != null) const SizedBox(height: 16),
                _buildSection(
                  context,
                  'Network Operations',
                  Icons.cloud,
                  [
                    _ModernButton(
                      icon: Icons.check_circle,
                      label: 'Success Network Request',
                      description: 'Send successful network request',
                      onPressed: () => sendNetworkRequest('https://jsonplaceholder.typicode.com/posts/'),
                      color: Colors.green,
                    ),
                    _ModernButton(
                      icon: Icons.error,
                      label: 'Failed Network Request',
                      description: 'Send failed network request',
                      onPressed: () => sendNetworkRequest('https://coralogix.com/404'),
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  'User & Context',
                  Icons.person,
                  [
                    const _ModernButton(
                      icon: Icons.account_circle,
                      label: 'Set User Context',
                      description: 'Update user metadata',
                      onPressed: sendUserContext,
                      color: Colors.blue,
                    ),
                    const _ModernButton(
                      icon: Icons.label,
                      label: 'Set Labels',
                      description: 'Add custom labels',
                      onPressed: setLabels,
                      color: Colors.purple,
                    ),
                    const _ModernButton(
                      icon: Icons.label_outline,
                      label: 'Get Labels',
                      description: 'Retrieve current labels',
                      onPressed: getLabels,
                      color: Colors.purple,
                    ),
                    const _ModernButton(
                      icon: Icons.apps,
                      label: 'Set Application Context',
                      description: 'Update app context',
                      onPressed: setApplicationContext,
                      color: Colors.indigo,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  'Errors & Logging',
                  Icons.bug_report,
                  [
                    const _ModernButton(
                      icon: Icons.report_problem,
                      label: 'Report Error',
                      description: 'Manually report an error',
                      onPressed: reportError,
                      color: Colors.orange,
                    ),
                    const _ModernButton(
                      icon: Icons.description,
                      label: 'Send Log',
                      description: 'Send custom log message',
                      onPressed: sendLog,
                      color: Colors.teal,
                    ),
                    _ModernButton(
                      icon: Icons.warning,
                      label: 'Assert Exception',
                      description: 'Trigger assert failure',
                      onPressed: () {
                        assert(false, 'assert failure');
                      },
                      color: Colors.deepOrange,
                    ),
                    const _ModernButton(
                      icon: Icons.error_outline,
                      label: 'Throw Exception',
                      description: 'Throw caught exception',
                      onPressed: throwTryCatchInDart,
                      color: Colors.red,
                    ),
                    const _ModernButton(
                      icon: Icons.flash_on,
                      label: 'Throw onPressed',
                      description: 'Throw uncaught exception',
                      onPressed: throwEcexpotionInDart,
                      color: Colors.redAccent,
                    ),
                    _ModernButton(
                      icon: Icons.smartphone,
                      label: 'Swift Fatal Error',
                      description: 'Trigger native fatal error',
                      onPressed: () => platformExecute('fatalError'),
                      color: Colors.pink,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  'SDK Operations',
                  Icons.settings,
                  [
                    const _ModernButton(
                      icon: Icons.power_settings_new,
                      label: 'SDK Shutdown',
                      description: 'Shutdown the SDK',
                      onPressed: sdkShutdown,
                      color: Colors.grey,
                    ),
                    const _ModernButton(
                      icon: Icons.check_circle_outline,
                      label: 'Is Initialized',
                      description: 'Check SDK status',
                      onPressed: isInitialized,
                      color: Colors.cyan,
                    ),
                    const _ModernButton(
                      icon: Icons.fingerprint,
                      label: 'Get Session Id',
                      description: 'Retrieve current session',
                      onPressed: getSessionId,
                      color: Colors.amber,
                    ),
                    const _ModernButton(
                      icon: Icons.analytics,
                      label: 'Custom Measurement',
                      description: 'Send custom metric',
                      onPressed: sendCustomMeasurement,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  'Navigation',
                  Icons.navigation,
                  [
                    _ModernButton(
                      icon: Icons.arrow_forward,
                      label: 'Navigate to New Screen',
                      description: 'Open new screen',
                      onPressed: () => navigateToNewScreen(context),
                      color: Colors.blueGrey,
                    ),
                    _ModernButton(
                      icon: Icons.video_library,
                      label: 'Session Replay Options',
                      description: 'Open Session Replay settings',
                      onPressed: () => navigateToSessionReplay(context),
                      color: Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: child,
                )),
          ],
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

Future<void> navigateToSessionReplay(BuildContext context) async {
  try {
    debugPrint('Navigating to Session Replay page...');
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SessionReplayOptionsPage(),
      ),
    );
    debugPrint('Navigation completed');
  } catch (e, stackTrace) {
    debugPrint('Navigation error: $e');
    debugPrint('Stack trace: $stackTrace');
  }
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

class _ModernButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onPressed;
  final Color color;

  const _ModernButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: description,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color.withOpacity(0.5),
                size: 20,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Screen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.layers,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Screen Actions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ModernButton(
                        icon: Icons.cloud_done,
                        label: 'Success Network Request',
                        description: 'Send successful network request',
                        onPressed: () => sendNetworkRequest('https://jsonplaceholder.typicode.com/todos/1'),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _ModernButton(
                        icon: Icons.error_outline,
                        label: 'Show Scaffold Error',
                        description: 'Trigger scaffold error',
                        onPressed: () => Scaffold.of(context)
                            .showBottomSheet((context) => Container(
                                  padding: const EdgeInsets.all(24),
                                  child: const Text(
                                    'Scaffold error',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
