import 'dart:async';

import 'package:cx_flutter_plugin/cx_domain.dart';
import 'package:cx_flutter_plugin/cx_exporter_options.dart';
import 'package:cx_flutter_plugin/cx_http_client.dart';
import 'package:cx_flutter_plugin/cx_instrumentation_type.dart';
import 'package:cx_flutter_plugin/cx_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';

const channel = MethodChannel('example.flutter.coralogix.io');

void main() {
  runZonedGuarded(() {
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
      application: 'demoApp-flutter',
      version: '1.0.0',
      publicKey: 'cxtp_3EBvvOiDcFwgutlSBX507UsXvrSQts',
      ignoreUrls: [],
      ignoreErrors: [],
      customDomainUrl: 'https://ingress.staging.rum-ingress-coralogix.com',
      labels: {'item': 'playstation 5', 'itemPrice': 1999},
      sdkSampler: 100,
      mobileVitalsFPSSamplingRate: 150,
      instrumentations: { CXInstrumentationType.anr.value: true,
                          CXInstrumentationType.custom.value: true,
                          CXInstrumentationType.errors.value: true,
                          CXInstrumentationType.lifeCycle.value: true,
                          CXInstrumentationType.mobileVitals.value: true,
                          CXInstrumentationType.network.value: true,
                          CXInstrumentationType.userActions.value: true},
      collectIPData: true,
      beforeSend: (event) {
        if (event.sessionContext?.userEmail?.endsWith('@company.com') ?? false) {
          return null;
        }
        event.sessionContext?.userEmail = '***@***';
        return event;
      },
      debug: true,
    );

    await CxFlutterPlugin.initSdk(options);
    await CxFlutterPlugin.setView("Main screen");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo'),
        ),
        body: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
          child: Column(
            children: [
            TooltipButton(
              onPressed: () => sendNetworkRequest('https://coralogix.com'),
              text: 'Send Network Request',
              buttonTitle: 'Send Successed Network Request',
            ),
            TooltipButton(
              onPressed: () => sendNetworkRequest('https://coralogix.com/404'),
              text: 'Send Failure Network Request',
              buttonTitle: 'Send Failure Network Request',
            ),
            TooltipButton(
              onPressed: () => sendUserContext(),
              text: 'Set User Context',
              buttonTitle: 'Set User Context',
            ),
            TooltipButton(
              onPressed: () => setLabels(),
              text: 'Set Labels',
              buttonTitle: 'Set Labels',
            ),
            TooltipButton(
              onPressed: () => sdkShutdown(),
              text: 'Sdk shutdown',
              buttonTitle: 'Sdk shutdown',
            ),
            TooltipButton(
              onPressed: () => reportError(),
              text: 'Dart: Report Error',
              buttonTitle: 'Dart: Report Error',
            ),
            TooltipButton(
              onPressed: () => sendLog(),
              text: 'Dart: Send Log',
              buttonTitle: 'Dart: Send Log',
            ),
            TooltipButton(
              onPressed: () => navigateToNewScreen(context),
              text: 'Navigate To NewScreen',
              buttonTitle: 'Navigate To NewScreen',
            ),
            TooltipButton(
              onPressed: () {
                assert(false, 'assert failure');
              },
              text: 'Dart: Assert Exception',
              buttonTitle: 'Dart: Assert Exception',
            ),
            TooltipButton(
              onPressed: () => throwTryCatchInDart(),
              text: 'Dart: Throw Exception',
              buttonTitle: 'Dart: Throw Exception',
            ),
            TooltipButton(
              onPressed: () => throwEcexpotionInDart(),
              text: 'Dart: throw onPressed',
              buttonTitle: 'Dart: throw onPressed',
            ),
            TooltipButton(
              onPressed: () => platformExecute('fatalError'),
              text: 'Swift fatalError',
              buttonTitle: 'Swift fatalError',
            ),
          ]),
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
      CxFlutterPlugin.reportError(error.message, {}, stackTrace.toString());
    }
  }
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
  await CxFlutterPlugin.reportError(
      'this is an error', {'fruit': 'banna', 'price': 1.30}, "");
}

Future<void> sdkShutdown() async {
  await CxFlutterPlugin.shutdown();
}

Future<void> setLabels() async {
  final labels = {'stock': 'NVDA', 'price': 104};
  await CxFlutterPlugin.setLabels(labels);
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

Future<void> sendNetworkRequest(String url) async {
  final client = CxHttpClient(http.Client());
  await client.get(Uri.parse(url));
}

class TooltipButton extends StatelessWidget {
  final String text;
  final String buttonTitle;
  final void Function()? onPressed;

  const TooltipButton({
    required this.onPressed,
    required this.buttonTitle,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      child: ElevatedButton(
        onPressed: onPressed,
        key: key,
        child: Text(buttonTitle),
      ),
    );
  }
}

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Screen'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          TooltipButton(
            onPressed: () => sendNetworkRequest('https://coralogix.com'),
            text: 'Send Network Request',
            buttonTitle: 'Send Successed Network Request',
          ),
          TooltipButton(
            onPressed: () => Scaffold.of(context)
                .showBottomSheet((context) => const Text('Scaffold error')),
            text: 'Show Scaffold error',
            buttonTitle: 'Show Scaffold error',
          ),
        ]),
      ),
    );
  }
}
