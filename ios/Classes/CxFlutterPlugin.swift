import Flutter
import UIKit
import Coralogix

public class CxFlutterPlugin: NSObject, FlutterPlugin {
    var coralogixRum: CoralogixRum?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cx_flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = CxFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initSdk":
            self.initSdk(call: call, result: result)
        case "setNetworkRequestContext":
            self.setNetworkRequestContext(call: call, result: result)
        case "setUserContext":
            self.setUserContext(call: call, result: result)
        case "setLabels":
            self.setLabels(call: call, result: result)
        case "shutdown":
            self.shutdown(call: call, result: result)
        case "log":
            self.log(call: call, result: result)
        case "reportError":
            self.reportError(call: call, result: result)
        case "setView":
            self.setView(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initSdk(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        
        let userContextDict = arguments["userContext"] as? [String: Any] ?? [String: Any]()
        let userContext = UserContext(userId: userContextDict["userId"] as? String ?? "",
                                      userName: userContextDict["userName"] as? String ?? "",
                                      userEmail: userContextDict["userEmail"] as? String ?? "",
                                      userMetadata: userContextDict["userMetadata"] as? [String: String] ?? [String: String]())
        
        let lablesDict = arguments["labels"] as? [String: Any] ?? [String: Any]()
        let instrumentations = arguments["instrumentations"] as? [String: Bool] ?? [String: Bool]()
        var instrumentationDict: [CoralogixExporterOptions.InstrumentationType: Bool] = [:]

        for (key, value) in instrumentations {
            if let instrumentationKey = instrumentationType(from: key) {
                instrumentationDict[instrumentationKey] = value
            }
        }

        guard let domain = arguments["coralogixDomain"] as? String,
              let coralogixDomain = CoralogixDomain(rawValue: domain) else {
            result(FlutterError(code: "4", message: "Failed to parse coralogix domain", details: nil))
            return
        }
        
        let options = CoralogixExporterOptions(coralogixDomain: coralogixDomain,
                                               userContext: userContext,
                                               environment: arguments["environment"] as? String ?? "",
                                               application: arguments["application"] as? String ?? "",
                                               version: arguments["version"] as? String ?? "",
                                               publicKey: arguments["publicKey"] as? String ?? "",
                                               ignoreUrls: arguments["ignoreUrls"] as? [String] ?? [String](),
                                               ignoreErrors: arguments["ignoreErrors"] as? [String] ?? [String](),
                                               customDomainUrl: arguments["customDomainUrl"] as? String ?? "",
                                               labels: lablesDict,
                                               sampleRate: arguments["sdkSampler"] as? Int ?? 100,
                                               mobileVitalsFPSSamplingRate: arguments["mobileVitalsFPSSamplingRate"] as? Int ?? 300,
                                               instrumentations: instrumentationDict,
                                               collectIPData: arguments["collectIPData"] as? Bool ?? true,
                                               debug: arguments["debug"] as? Bool ?? false)
        
        self.coralogixRum = CoralogixRum.init(options: options, sdkFramework: .flutter)
        result("")
    }
    
    private func setNetworkRequestContext(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        self.coralogixRum?.setNetworkRequestContext(dictionary: arguments)
        result("")
    }
    
    private func setUserContext(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        
        let userContext = UserContext(userId: arguments["userId"] as? String ?? "",
                                      userName: arguments["userName"] as? String ?? "",
                                      userEmail: arguments["userEmail"] as? String ?? "",
                                      userMetadata: arguments["userMetadata"] as? [String: String] ?? [String: String]())
        
        self.coralogixRum?.setUserContext(userContext: userContext)
        result("")
    }
    
    private func setLabels(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        self.coralogixRum?.setLabels(labels: arguments)
        result("")
    }
    
    private func log(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty,
              let severity = arguments["severity"] as? String,
              let cxLogSeverity = CoralogixLogSeverity(rawValue: Int(severity) ?? 5) else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        let data = arguments["data"] as? [String: Any] ?? [String: Any]()
        let message = arguments["message"] as? String ?? ""
        
        self.coralogixRum?.log(severity:cxLogSeverity, message: message, data: data)
        result("")
    }
    
    private func reportError(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        
        let message = arguments["message"] as? String ?? ""
        let stackTrace = arguments["stackTrace"] as? String ?? ""
        self.coralogixRum?.reportError(message: message, stackTrace: stackTrace)
        result("")
    }
    
    private func setView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        
        let viewName = arguments["viewName"] as? String ?? ""
        self.coralogixRum?.setView(name: viewName)
        result("")
    }

    private func shutdown(call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.coralogixRum?.shutdown()
        result("")
    }
    
    private func instrumentationType(from string: String) -> CoralogixExporterOptions.InstrumentationType? {
        switch string {
        case "mobileVitals":
            return .mobileVitals
        case "navigation":
            return .navigation
        case "custom":
            return .custom
        case "errors":
            return .errors
        case "network":
            return .network
        case "userActions":
            return .userActions
        case "anr":
            return .anr
        case "lifeCycle":
            return .lifeCycle
        default:
            return nil
        }
    }
}
