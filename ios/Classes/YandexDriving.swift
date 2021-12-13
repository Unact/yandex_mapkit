import Flutter
import UIKit
import YandexMapsMobile

public class YandexDriving: NSObject, FlutterPlugin {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let drivingRouter: YMKDrivingRouter!
  private var drivingSessions: [Int: YandexDrivingSession] = [:]

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
    self.drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()

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
    let session = drivingRouter.requestRoutes(
      with: requestPoints,
      drivingOptions: Utils.drivingOptionsFromJson(params["drivingOptions"] as! [String: Any]),
      vehicleOptions: YMKDrivingVehicleOptions(),
      routeHandler: {(drivingResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
        self.drivingSessions[sessionId]?.handleResponse(drivingResponse: drivingResponse, error: error, result: result)
      }
    )

    drivingSessions[sessionId] = YandexDrivingSession(
      id: sessionId,
      session: session,
      registrar: pluginRegistrar,
      onClose: { (id) in self.drivingSessions.removeValue(forKey: id) }
    )
  }
}
