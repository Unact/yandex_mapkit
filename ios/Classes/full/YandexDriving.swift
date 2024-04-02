import Flutter
import UIKit
import YandexMapsMobile

public class YandexDriving: NSObject, FlutterPlugin {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let drivingRouter: YMKDrivingRouter!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_driving",
      binaryMessenger: registrar.messenger()
    )

    let plugin = YandexDriving(channel: channel, registrar: registrar)

    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.methodChannel = channel
    self.drivingRouter = YMKDirections.sharedInstance().createDrivingRouter(withType: YMKDrivingRouterType.combined)

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

    YandexDrivingSession.initSession(id: id, registrar: pluginRegistrar, drivingRouter: drivingRouter)
  }
}
