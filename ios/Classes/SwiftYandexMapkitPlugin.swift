import CoreLocation
import Flutter
import UIKit
import YandexMapKit

public class SwiftYandexMapkitPlugin: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel!
  static var controller: YandexMapController!
  static var pluginRegistrar: FlutterPluginRegistrar!

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "yandex_mapkit", binaryMessenger: registrar.messenger())
    pluginRegistrar = registrar

    pluginRegistrar.addMethodCallDelegate(SwiftYandexMapkitPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setApiKey":
      setApiKey(call)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setApiKey(_ call: FlutterMethodCall) {
    let appDelegate = UIApplication.shared.delegate!
    let viewController = appDelegate.window?!.rootViewController

    YMKMapKit.setApiKey(call.arguments as! String?)
    SwiftYandexMapkitPlugin.controller?.reset()
    SwiftYandexMapkitPlugin.controller = YandexMapController(
      viewController: viewController!,
      pluginRegistrar: SwiftYandexMapkitPlugin.pluginRegistrar
    )
  }
}
