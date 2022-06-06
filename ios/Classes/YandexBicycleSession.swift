import Foundation
import YandexMapsMobile

public class YandexBicycleSession: NSObject {
  private var id: Int
  private var session: YMKBicycleSession
  private let methodChannel: FlutterMethodChannel!
  private var onClose: (Int) -> ()

  public required init(
    id: Int,
    session: YMKBicycleSession,
    registrar: FlutterPluginRegistrar,
    onClose: @escaping ((Int) -> ())
  ) {
    self.id = id
    self.session = session
    self.onClose = onClose

    methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_bicycle_session_\(id)",
      binaryMessenger: registrar.messenger()
    )

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
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

    onClose(id)
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
        "polyline": Utils.polylineToJson(route.geometry),
        "weight": [
          "time": Utils.localizedValueToJson(weight.time),
          "distance": Utils.localizedValueToJson(weight.distance)
        ]
      ]
    }

    let arguments: [String: Any] = [
      "routes": routes
    ]

    result(arguments)
  }

  private func onError(_ error: Error, _ result: @escaping FlutterResult) {
    result(Utils.errorToJson(error))
  }
}
