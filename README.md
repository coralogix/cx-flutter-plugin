# Official Coralogix SDK for Flutter.
The Coralogix RUM Mobile SDK is lirary (plugin) for Flutter
The SDK provides mobile Telemetry instrumentation that captures:

1. HTTP requests
2. Unhandled / handled exceptions
3. Custom Log ()
4. Crashes / (iOS Native - using PLCrashReporter)
5. Views

Coralogix captures data by using an SDK within your application's runtime. 
These are platform-specific and allow Coralogix to have a deep understanding of how your application works.

## Installaion 
### Step 1 :Add Coralogix dependency
In the root folder of your flutter app add the Coralogix package: flutter pub add ```cx_flutter_plugin```.

### Step 2 :Integration
Inorder to initailized the RUM SDK, please supply both ```CXExporterOptions``` and ```CXDomain```.
```Dart
import 'package:cx_flutter_plugin/cx_http_client.dart';

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var coralogixDomain = **< Coralogix Domain >**;

    var options = CXExporterOptions(
      coralogixDomain: <CXDomain>,
      userContext: null,
      environment: '<Environment>',
      application: '<App Name>',
      version: '<App Version>',
      publicKey: '<PublicKey>',
      ignoreUrls: [],
      ignoreErrors: [],
      customDomainUrl: '',
      labels: {'item': 'playstation 5', 'itemPrice': 1999},
      debug: false,
    );

    await CxFlutterPlugin.initSdk(options);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }
```
### Network Requests
By Using ```CxHttpClient``` The RUM SDK can catch / monitor the http traffic.
```Dart
  final client = CxHttpClient(http.Client());
  await client.get(Uri.parse(url));
```
### Unhandled / handled exceptions
#### For handled exceptions Use Try / Catch scheme with the reportError API.
If you have Stack Trace you can route it as follow
```Dart
  try {
    throw StateError('state error try catch');
  } catch (error, stackTrace) {
    if (error is StateError) {
      // Handle the StateError
      CxFlutterPlugin.reportError(error.message, {}, stackTrace.toString());
    }
  }
```
or
```Dart
 await CxFlutterPlugin.reportError('this is an error', {'fruit': 'banna', 'price': 1.30}, "");
```
#### For Unhandled exceptions
you need to wrap you runAPP function ad follow
```Dart
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
```

#### Custom Log
```Dart
  await CxFlutterPlugin.log(CxLogSeverity.error, 'this is an error', {'fruit': 'banna', 'price': 1.30});
```
#### Views
To monitor page / views use the following API
```Dart
   await CxFlutterPlugin.setView(viewName);
```

#### Set Labels
Sets the labels for the Coralogix exporter.
```Dart
   final labels = {'stock': 'NVDA', 'price': 104};
   await CxFlutterPlugin.setLabels(labels);
```
#### Set User Context
Setting User Context
```Dart
 var userContext = UserContext(
    userId: '456',
    userName: 'Robert Davis',
    userEmail: 'robert.davis@example.com',
    userMetadata: {'car': 'tesla'},
  );

  await CxFlutterPlugin.setUserContext(userContext);
```
#### Shutdown
Shuts down the Coralogix exporter and marks it as uninitialized.
```Dart
  await CxFlutterPlugin.shutdown();
```

For more info check https://github.com/coralogix/cx-ios-sdk/tree/master/Coralogix/Docs. 

