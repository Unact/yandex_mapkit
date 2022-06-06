import Flutter
import UIKit
import YandexMapsMobile

public class YandexBicycle: NSObject, FlutterPlugin {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let bicycleRouter: YMKBicycleRouter!
  private var bicycleSessions: [Int: YandexBicycleSession] = [:]

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
    case "requestRoutes":
      requestRoutes(call, result)
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestRoutes(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]
    let sessionId = params["sessionId"] as! Int
    let requestPoints = (params["points"] as! [[String: Any]]).map {
      (pointParams) -> YMKRequestPoint in Utils.requestPointFromJson(pointParams)
    }
    let session = bicycleRouter.requestRoutes(
      with: requestPoints,
      type: YMKBicycleVehicleType(rawValue: (params["bicycleVehicleType"] as! NSNumber).uintValue)!,
      routeListener: {(bicycleResponse: [YMKBicycleRoute]?, error: Error?) -> Void in
        self.bicycleSessions[sessionId]?.handleResponse(bicycleResponse: bicycleResponse, error: error, result: result)
      }
    )

    bicycleSessions[sessionId] = YandexBicycleSession(
      id: sessionId,
      session: session,
      registrar: pluginRegistrar,
      onClose: { (id) in self.bicycleSessions.removeValue(forKey: id) }
    )
  }
}
