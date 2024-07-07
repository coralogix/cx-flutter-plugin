// import 'package:flutter_test/flutter_test.dart';
// import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
// import 'package:cx_flutter_plugin/cx_flutter_plugin_platform_interface.dart';
// import 'package:cx_flutter_plugin/cx_flutter_plugin_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockCxFlutterPluginPlatform
//     with MockPlatformInterfaceMixin
//     implements CxFlutterPluginPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
  
//   @override
//   Future<String?> setUserContext(String userID, String userName, String userEmail, Map<String, dynamic>? userMetadata) => Future.value('42');

//   @override
//   Future<String?> initSdk() => Future.value(' ');
// }

// void main() {
//   final CxFlutterPluginPlatform initialPlatform = CxFlutterPluginPlatform.instance;

//   test('$MethodChannelCxFlutterPlugin is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelCxFlutterPlugin>());
//   });

//   test('getPlatformVersion', () async {
//     CxFlutterPlugin cxFlutterPlugin = CxFlutterPlugin();
//     MockCxFlutterPluginPlatform fakePlatform = MockCxFlutterPluginPlatform();
//     CxFlutterPluginPlatform.instance = fakePlatform;

//     expect(await cxFlutterPlugin.getPlatformVersion(), '42');
//   });
// }
