import Coralogix
import Flutter
import UIKit

enum CxSdkError: Error {
    case invalidPublicKey
    case missingParameter
}

public class CxFlutterPlugin: NSObject, FlutterPlugin {
    var coralogixRum: CoralogixRum?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "cx_flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = CxFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // Initialize event channel
        instance.eventChannel = FlutterEventChannel(
            name: "cx_flutter_plugin/onBeforeSend",
            binaryMessenger: registrar.messenger())
        instance.eventChannel?.setStreamHandler(instance)
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
        case "sendCxSpanData":
            self.sendCxSpanData(call: call, result: result)
        case "getLabels":
            self.getLabels(call: call, result: result)
        case "isInitialized":
            self.isInitialized(call: call, result: result)
        case "getSessionId":
            self.getSessionId(call: call, result: result)
        case "setApplicationContext":
            self.setApplicationContext(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getSessionId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let sessionId = self.coralogixRum?.getSessionId()
        result(sessionId)
    }

    private func setApplicationContext(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        let applicationContext = arguments["applicationName"] as? String ?? ""
        let applicationVersion = arguments["applicationVersion"] as? String ?? ""
        self.coralogixRum?.setApplicationContext(application: applicationContext, version: applicationVersion)
        result("setApplicationContext success")
    }

    private func isInitialized(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isInitialized = self.coralogixRum?.isInitialized()
        result(isInitialized)
    }

    private func sendCxSpanData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let beforeSendResults = call.arguments as? [[String: Any]], !beforeSendResults.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        self.coralogixRum?.sendBeforeSendData(data: beforeSendResults)
        result("sendCxSpanData success")
    }

    private func initSdk(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let parameters = call.arguments as? [String: Any], !parameters.isEmpty else {
            result(FlutterError(code: "4", message: "parameters is null or empty", details: nil))
            return
        }

        do {
            // Create beforeSendCallback only if parameter["beforeSend"] is not null
            let beforeSendCallBack: (([[String: Any]]) -> Void)? =
                parameters["beforeSend"] != nil
                ? { [weak self] (event: [[String: Any]]) -> Void in
                    print("event: \(event)")
                    let safePayload = self?.makeJSONSafe(event)
                    DispatchQueue.main.async {
                        self?.eventSink?(safePayload)
                    }
                  } : nil

            var options = try self.toCoralogixOptions(parameter: parameters)
            options.beforeSendCallBack = beforeSendCallBack
            self.coralogixRum = CoralogixRum(options: options, sdkFramework: .flutter)
            result("initialize success")
            return
        } catch let error as CxSdkError {
            result(
                FlutterError(
                    code: "CX_SDK_ERROR", message: error.localizedDescription, details: error))
            return
        } catch {
            result(
                FlutterError(
                    code: "UNEXPECTED_ERROR",
                    message: "An unexpected error occurred: \(error.localizedDescription)",
                    details: error))
            return
        }
    }

    private func setNetworkRequestContext(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        self.coralogixRum?.setNetworkRequestContext(dictionary: arguments)
        result("setNetworkRequestContext success")
    }

    private func setUserContext(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }

        let userContext = UserContext(
            userId: arguments["userId"] as? String ?? "",
            userName: arguments["userName"] as? String ?? "",
            userEmail: arguments["userEmail"] as? String ?? "",
            userMetadata: arguments["userMetadata"] as? [String: String] ?? [String: String]())

        self.coralogixRum?.setUserContext(userContext: userContext)
        result("setUserContext success")
    }

    private func setLabels(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        self.coralogixRum?.setLabels(labels: arguments)
        result("setLabels success")
    }

    private func log(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty,
            let severity = arguments["severity"] as? String,
            let cxLogSeverity = self.getCoralogixLogSeverity(rawValue: severity)
        else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }
        let data = arguments["data"] as? [String: Any] ?? [String: Any]()
        let message = arguments["message"] as? String ?? ""

        self.coralogixRum?.log(severity: cxLogSeverity, message: message, data: data)
        result("log success")
    }

    private func reportError(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }

        let message = arguments["message"] as? String ?? ""
        let stackTrace = arguments["stackTrace"] as? String ?? ""
        self.coralogixRum?.reportError(message: message, stackTrace: stackTrace)
        result("reportError success")
    }

    private func setView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], !arguments.isEmpty else {
            result(FlutterError(code: "4", message: "Arguments is null or empty", details: nil))
            return
        }

        let viewName = arguments["viewName"] as? String ?? ""
        self.coralogixRum?.setView(name: viewName)
        result("setView success")
    }

    private func shutdown(call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.coralogixRum?.shutdown()
        result("shutdown success")
    }

    private func getLabels(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let lables = self.coralogixRum?.getLabels()
        result(lables)
    }

    private func getCoralogixLogSeverity(rawValue: String) -> CoralogixLogSeverity? {
        switch rawValue.lowercased() {
        case "debug": return CoralogixLogSeverity.debug
        case "verbose": return CoralogixLogSeverity.verbose
        case "info": return CoralogixLogSeverity.info
        case "warn": return CoralogixLogSeverity.warn
        case "error": return CoralogixLogSeverity.error
        case "critical": return CoralogixLogSeverity.critical
        default: return nil
        }
    }

    private func instrumentationType(from string: String) -> CoralogixExporterOptions
        .InstrumentationType?
    {
        switch string {
        case "mobileVitals":
            return .mobileVitals
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

    private func toCoralogixOptions(parameter: [String: Any]) throws -> CoralogixExporterOptions {
        let userContextDict = parameter["userContext"] as? [String: Any] ?? [String: Any]()
        let userContext = UserContext(
            userId: userContextDict["userId"] as? String ?? "",
            userName: userContextDict["userName"] as? String ?? "",
            userEmail: userContextDict["userEmail"] as? String ?? "",
            userMetadata: userContextDict["userMetadata"] as? [String: String] ?? [String: String]()
        )

        let lablesDict = parameter["labels"] as? [String: Any] ?? [String: Any]()
        let instrumentations = parameter["instrumentations"] as? [String: Bool] ?? [String: Bool]()
        var instrumentationDict: [CoralogixExporterOptions.InstrumentationType: Bool] = [:]

        for (key, value) in instrumentations {
            if let instrumentationKey = instrumentationType(from: key) {
                instrumentationDict[instrumentationKey] = value
            }
        }

        guard let domain = parameter["coralogixDomain"] as? String,
            let coralogixDomain = CoralogixDomain(rawValue: domain)
        else {
            throw CxSdkError.invalidPublicKey
        }

        let options = CoralogixExporterOptions(
            coralogixDomain: coralogixDomain,
            userContext: userContext,
            environment: parameter["environment"] as? String ?? "",
            application: parameter["application"] as? String ?? "",
            version: parameter["version"] as? String ?? "",
            publicKey: parameter["publicKey"] as? String ?? "",
            ignoreUrls: parameter["ignoreUrls"] as? [String] ?? [String](),
            ignoreErrors: parameter["ignoreErrors"] as? [String] ?? [String](),
            labels: lablesDict,
            sampleRate: parameter["sdkSampler"] as? Int ?? 100,
            mobileVitalsFPSSamplingRate: parameter["mobileVitalsFPSSamplingRate"] as? Int ?? 300,
            instrumentations: instrumentationDict,
            collectIPData: parameter["collectIPData"] as? Bool ?? true,
            enableSwizzling: parameter["enableSwizzling"] as? Bool ?? true,
            debug: parameter["debug"] as? Bool ?? false)
        return options
    }
    
    func makeJSONSafe(_ input: Any) -> Any {
        if let dict = input as? [String: Any] {
            return dict.mapValues { makeJSONSafe($0) }
        } else if let array = input as? [Any] {
            return array.map { makeJSONSafe($0) }
        } else if input is String || input is Int || input is Double || input is Bool || input is NSNull {
            return input
        } else {
            return "\(input)" // fallback: convert to string
        }
    }
}

extension CxFlutterPlugin: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
