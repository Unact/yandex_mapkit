import Foundation
import YandexMapsMobile

public class YandexDrivingSession: NSObject {
  private var id: Int
  private var session: YMKDrivingSession
  private let methodChannel: FlutterMethodChannel!
  private var onClose: (Int) -> ()

  public required init(
    id: Int,
    session: YMKDrivingSession,
    registrar: FlutterPluginRegistrar,
    onClose: @escaping ((Int) -> ())
  ) {
    self.id = id
    self.session = session
    self.onClose = onClose

    methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_driving_session_\(id)",
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
    session.retry(routeHandler: {(drivingResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
      self.handleResponse(drivingResponse: drivingResponse, error: error, result: result)
    })
  }

  public func close() {
    session.cancel()

    onClose(id)
  }

  public func handleResponse(drivingResponse: [YMKDrivingRoute]?, error: Error?, result: @escaping FlutterResult) {
    if let response = drivingResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }

  private func onSuccess(_ res: [YMKDrivingRoute], _ result: @escaping FlutterResult) {
    let resultRoutes = res.map { (route) -> [String: Any] in
      let resultpoints: [[String: Any]] = route.geometry.points.map { (point) -> [String: Any] in
        return ["latitude": point.latitude, "longitude": point.longitude]
      }
      let weight: [String: Any] = [
        "time": self.localizedValueData(route.metadata.weight.time),
        "timeWithTraffic": self.localizedValueData(route.metadata.weight.timeWithTraffic),
        "distance": self.localizedValueData(route.metadata.weight.distance)
      ]
      let metadata: [String: Any] = ["weight": weight]
      let resultRoute: [String: Any] = ["geometry": resultpoints, "metadata": metadata]
      return resultRoute
    }

    result(["routes": resultRoutes])
  }

  private func onError(_ error: Error, _ result: @escaping FlutterResult) {
    var errorMessage = "Unknown error"

    if let underlyingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as? YRTError {
      if underlyingError.isKind(of: YRTNetworkError.self) {
        errorMessage = "Network error"
      } else if underlyingError.isKind(of: YRTRemoteError.self) {
        errorMessage = "Remote server error"
      }
    } else if let msg = (error as NSError).userInfo["message"] {
      errorMessage = msg as! String
    }

    let arguments: [String:Any?] = ["error": errorMessage]

    result(arguments)
  }

  private func localizedValueData(_ value: YMKLocalizedValue) -> [String: Any?] {
    ["value": value.value, "text": value.text]
  }
}
