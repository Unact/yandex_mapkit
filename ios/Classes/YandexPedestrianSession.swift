import Foundation
import YandexMapsMobile

public class YandexPedestrianSession: NSObject {
  private var id: Int
  private var session: YMKMasstransitSession
  private let methodChannel: FlutterMethodChannel!
  private var onClose: (Int) -> ()

  public required init(
    id: Int,
    session: YMKMasstransitSession,
    registrar: FlutterPluginRegistrar,
    onClose: @escaping ((Int) -> ())
  ) {
    self.id = id
    self.session = session
    self.onClose = onClose

    methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_pedestrian_session_\(id)",
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
      session.retry(routeHandler: {(pedestrianResponse: [YMKMasstransitRoute]?, error: Error?) -> Void in
      self.handleResponse(pedestrianResponse: pedestrianResponse, error: error, result: result)
    })
  }

  public func close() {
    session.cancel()

    onClose(id)
  }

  public func handleResponse(pedestrianResponse: [YMKMasstransitRoute]?, error: Error?, result: @escaping FlutterResult) {
    if let response = pedestrianResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }

  private func onSuccess(_ res: [YMKMasstransitRoute], _ result: @escaping FlutterResult) {
    let routes = res.map { (route) -> [String: Any] in
      let weight = route.metadata.weight

      return [
        "geometry": route.geometry.points.map {
          (point) -> [String: Any] in Utils.pointToJson(point)
        },
        "metadata": [
          "weight": [
            "time": Utils.localizedValueToJson(weight.time),
            "distance": Utils.localizedValueToJson(weight.walkingDistance)
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

      let arguments: [String: Any?] = [
        "error": errorMessage
      ]

      result(arguments)
    }
  }
