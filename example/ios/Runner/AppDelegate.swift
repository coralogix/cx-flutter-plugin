import Flutter
import UIKit


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }

    let channel = FlutterMethodChannel(name: "example.flutter.coralogix.io",
                            binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler(handleMessage)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleMessage(call: FlutterMethodCall, result: FlutterResult) {
    if call.method == "fatalError" {
      fatalError("fatalError")
    } 
  }
}
