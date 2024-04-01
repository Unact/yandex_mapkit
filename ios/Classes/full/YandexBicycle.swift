import Flutter
import UIKit
import YandexMapsMobile

public class YandexBicycle: NSObject, FlutterPlugin {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let bicycleRouter: YMKBicycleRouter!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_bicycle",
      binaryMessenger: registrar.messenger()
    )

    let plugin = YandexBicycle(channel: channel, registrar: registrar)

    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.methodChannel = channel
    self.bicycleRouter = YMKTransport.sharedInstance().createBicycleRouter()

    super.init()

    self.methodChannel.setMethodCallHandler(self.handle)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initSession":
      initSession(call)
      result(nil)
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func initSession(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let id  = params["id"] as! Int

    YandexBicycleSession.initSession(id: id, registrar: pluginRegistrar, bicycleRouter: bicycleRouter)
  }
}
