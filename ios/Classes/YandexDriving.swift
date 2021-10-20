import Flutter
import UIKit
import YandexMapsMobile

public class YandexDriving: NSObject, FlutterPlugin {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let drivingRouter: YMKDrivingRouter!
  private var drivingSessions: [Int:YandexDrivingSession] = [:]

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
    let pointsParams = params["points"] as! [[String: Any]]
    let requestPoints = pointsParams.map { (pointParams) ->YMKRequestPoint in requestPoint(pointParams) }
    let drivingOptions = YMKDrivingDrivingOptions()
    let vehicleOptions = YMKDrivingVehicleOptions()

    let session = drivingRouter.requestRoutes(
      with: requestPoints,
      drivingOptions: drivingOptions,
      vehicleOptions: vehicleOptions,
      routeHandler: {(drivingResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
        if let s = self.drivingSessions[sessionId] {
          s.handleResponse(drivingResponse: drivingResponse, error: error, result: result)
        }
      }
    )

    let drivingSession = YandexDrivingSession(
      id: sessionId,
      session: session,
      registrar: pluginRegistrar,
      onClose: { (id) in self.drivingSessions.removeValue(forKey: id) }
    )

    drivingSessions[sessionId] = drivingSession
  }

  private func requestPoint(_ data: [String: Any]) -> YMKRequestPoint {
    let paramsPoint = data["point"] as! [String: Any]
    let point = YMKPoint(
      latitude: (paramsPoint["latitude"] as! NSNumber).doubleValue,
      longitude: (paramsPoint["longitude"] as! NSNumber).doubleValue
    )
    let pointType = YMKRequestPointType(rawValue: (data["requestPointType"] as! NSNumber).uintValue)!

    return YMKRequestPoint(point: point, type: pointType, pointContext: nil)
  }
}
