import Foundation
import YandexMapsMobile

public class YandexBicycleSession: NSObject {
  private var id: Int
  private var session: YMKBicycleSession!
  private let methodChannel: FlutterMethodChannel!
  private let bicycleRouter: YMKBicycleRouter!
  private static var bicycleSessions: [Int: YandexBicycleSession] = [:]

  public static func initSession(id: Int, registrar: FlutterPluginRegistrar, bicycleRouter: YMKBicycleRouter) {
    bicycleSessions[id] = YandexBicycleSession(id: id, registrar: registrar, bicycleRouter: bicycleRouter)
  }

  public required init(id: Int, registrar: FlutterPluginRegistrar, bicycleRouter: YMKBicycleRouter) {
    self.id = id
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_bicycle_session_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.bicycleRouter = bicycleRouter

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

    session = bicycleRouter.requestRoutes(
      with: requestPoints,
      type: YMKBicycleVehicleType(rawValue: (params["bicycleVehicleType"] as! NSNumber).uintValue)!,
      routeListener: {(bicycleResponse: [YMKBicycleRoute]?, error: Error?) -> Void in
        self.handleResponse(bicycleResponse: bicycleResponse, error: error, result: result)
      }
    )
  }

  public func cancel() {
    session.cancel()
  }

  public func retry(_ result: @escaping FlutterResult) {
    session.retry(routeListener: {(bicycleResponse: [YMKBicycleRoute]?, error: Error?) -> Void in
      self.handleResponse(bicycleResponse: bicycleResponse, error: error, result: result)
    })
  }

  public func close() {
    session.cancel()

    YandexBicycleSession.bicycleSessions.removeValue(forKey: id)
  }

  public func handleResponse(bicycleResponse: [YMKBicycleRoute]?, error: Error?, result: @escaping FlutterResult) {
    if let response = bicycleResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }

  private func onSuccess(_ res: [YMKBicycleRoute], _ result: @escaping FlutterResult) {
    let routes = res.map { (route) -> [String: Any] in
      let weight = route.weight

      return [
        "geometry": UtilsFull.polylineToJson(route.geometry),
        "weight": [
          "time": UtilsFull.localizedValueToJson(weight.time),
          "distance": UtilsFull.localizedValueToJson(weight.distance)
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
