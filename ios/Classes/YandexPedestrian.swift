import Flutter
import UIKit
import YandexMapsMobile

public class YandexPedestrian: NSObject, FlutterPlugin {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let pedestrianRouter: YMKPedestrianRouter!
  private var pedestrianSessions: [Int: YandexPedestrianSession] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_pedestrian",
      binaryMessenger: registrar.messenger()
    )

    let plugin = YandexPedestrian(channel: channel, registrar: registrar)

    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.methodChannel = channel
      self.pedestrianRouter = YMKTransport.sharedInstance().createPedestrianRouter()

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
      let session = pedestrianRouter.requestRoutes(
    with: requestPoints, timeOptions:YMKTimeOptions(),
    routeHandler: {(pedestrianResponse: [YMKMasstransitRoute]?, error: Error?) -> Void in
        self.pedestrianSessions[sessionId]?.handleResponse(pedestrianResponse: pedestrianResponse, error: error, result: result)
      }
    )

      pedestrianSessions[sessionId] = YandexPedestrianSession(
      id: sessionId,
      session: session,
      registrar: pluginRegistrar,
      onClose: { (id) in self.pedestrianSessions.removeValue(forKey: id) }
    )
  }
}
