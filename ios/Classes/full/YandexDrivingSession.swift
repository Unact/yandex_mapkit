import Foundation
import YandexMapsMobile

public class YandexDrivingSession: NSObject {
  private var id: Int
  private var session: YMKDrivingSession!
  private let methodChannel: FlutterMethodChannel!
  private let drivingRouter: YMKDrivingRouter!
  private static var drivingSessions: [Int: YandexDrivingSession] = [:]

  public static func initSession(id: Int, registrar: FlutterPluginRegistrar, drivingRouter: YMKDrivingRouter) {
    drivingSessions[id] = YandexDrivingSession(id: id, registrar: registrar, drivingRouter: drivingRouter)
  }

  public required init(id: Int, registrar: FlutterPluginRegistrar, drivingRouter: YMKDrivingRouter) {
    self.id = id
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_driving_session_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.drivingRouter = drivingRouter

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestRoutes":
      requestRoutes(call, result)
    case "cancel":
      cancel()
      result(nil)
    case "retry":
      retry(result)
    case "close":
      close()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestRoutes(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]
    let requestPoints = (params["points"] as! [[String: Any]]).map {
      (pointParams) -> YMKRequestPoint in UtilsFull.requestPointFromJson(pointParams)
    }

    session = drivingRouter.requestRoutes(
      with: requestPoints,
      drivingOptions: UtilsFull.drivingOptionsFromJson(params["drivingOptions"] as! [String: Any]),
      vehicleOptions: YMKDrivingVehicleOptions(),
      routeHandler: {(drivingResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
        self.handleResponse(drivingResponse: drivingResponse, error: error, result: result)
      }
    )
  }

  public func cancel() {
    session.cancel()
  }

  public func retry(_ result: @escaping FlutterResult) {
    session.retry(routeHandler: {(drivingResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
      self.handleResponse(drivingResponse: drivingResponse, error: error, result: result)
    })
  }

  public func close() {
    session.cancel()

    YandexDrivingSession.drivingSessions.removeValue(forKey: id)
  }

  public func handleResponse(drivingResponse: [YMKDrivingRoute]?, error: Error?, result: @escaping FlutterResult) {
    if let response = drivingResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }

  private func onSuccess(_ res: [YMKDrivingRoute], _ result: @escaping FlutterResult) {
    let routes = res.map { (route) -> [String: Any] in
      let weight = route.metadata.weight

      return [
        "geometry": UtilsFull.polylineToJson(route.geometry),
        "metadata": [
          "weight": [
            "time": UtilsFull.localizedValueToJson(weight.time),
            "timeWithTraffic": UtilsFull.localizedValueToJson(weight.timeWithTraffic),
            "distance": UtilsFull.localizedValueToJson(weight.distance)
          ]
        ]
      ]
    }

    let arguments: [String: Any] = [
      "routes": routes
    ]

    result(arguments)
  }

  private func onError(_ error: Error, _ result: @escaping FlutterResult) {
    result(UtilsFull.errorToJson(error))
  }
}
