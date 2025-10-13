import Foundation
import YandexMapsMobile

public class YandexPedestrianSession: NSObject {
  private var id: Int
  private var session: YMKMasstransitSession!
  private let methodChannel: FlutterMethodChannel!
  private let pedestrianRouter: YMKPedestrianRouter!
  private static var pedestrianSessions: [Int: YandexPedestrianSession] = [:]

  public static func initSession(id: Int, registrar: FlutterPluginRegistrar, pedestrianRouter: YMKPedestrianRouter) {
    pedestrianSessions[id] = YandexPedestrianSession(id: id, registrar: registrar, pedestrianRouter: pedestrianRouter)
  }

  public required init(id: Int, registrar: FlutterPluginRegistrar, pedestrianRouter: YMKPedestrianRouter) {
    self.id = id
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_pedestrian_session_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.pedestrianRouter = pedestrianRouter

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

    session = pedestrianRouter.requestRoutes(
      with: requestPoints,
      timeOptions: UtilsFull.timeOptionsFromJson(params["timeOptions"] as! [String: Any]),
      routeOptions: YMKRouteOptions(
        fitnessOptions: UtilsFull.fitnessOptionsFromJson(params["fitnessOptions"] as! [String : Any])
      ),
      routeHandler: {(pedestrianResponse: [YMKMasstransitRoute]?, error: Error?) -> Void in
        self.handleResponse(pedestrianResponse: pedestrianResponse, error: error, result: result)
      }
    )
  }

  public func cancel() {
    session.cancel()
  }

  public func retry(_ result: @escaping FlutterResult) {
    session.retry(routeHandler: {(pedestrianResponse: [YMKMasstransitRoute]?, error: Error?) -> Void in
      self.handleResponse(pedestrianResponse: pedestrianResponse, error: error, result: result)
    })
  }

  public func close() {
    session.cancel()

    YandexPedestrianSession.pedestrianSessions.removeValue(forKey: id)
  }

  public func handleResponse(pedestrianResponse: [YMKMasstransitRoute]?, error: Error?, result: @escaping FlutterResult) {
    if let response = pedestrianResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }

  private func onSuccess(_ res: [YMKMasstransitRoute], _ result: @escaping FlutterResult) {
    let routes = res.map { (route) -> [String: Any?] in
      let weight = route.metadata.weight
      let estimation = route.metadata.estimation

      return [
        "geometry": UtilsFull.polylineToJson(route.geometry),
        "metadata": [
          "estimation": estimation == nil ? nil : [
            "departureTime": estimation!.departureTime.value * 1000,
            "arrivalTime": estimation!.arrivalTime.value * 1000
          ] as Any,
          "weight": [
            "time": UtilsFull.localizedValueToJson(weight.time),
            "walkingDistance": UtilsFull.localizedValueToJson(weight.walkingDistance),
            "transfersCount": weight.transfersCount
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
