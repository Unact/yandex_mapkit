import Foundation
import YandexMapsMobile

public class YandexSuggestSession: NSObject {
  private var id: Int
  private var session: YMKSearchSuggestSession
  private let methodChannel: FlutterMethodChannel!
  private var onClose: (Int) -> ()

  public required init(
    id: Int,
    session: YMKSearchSuggestSession,
    registrar: FlutterPluginRegistrar,
    onClose: @escaping ((Int) -> ())
  ) {
    self.id = id
    self.session = session
    self.onClose = onClose

    methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_suggest_session_\(id)",
      binaryMessenger: registrar.messenger()
    )

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "reset":
      reset()
      result(nil)
    case "close":
      close()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func reset() {
    session.reset()
  }

  public func close() {
    session.reset()

    onClose(id)
  }

  public func handleResponse(suggestResponse: [YMKSuggestItem]?, error: Error?, result: @escaping FlutterResult) {
    if let response = suggestResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }

  private func onSuccess(_ res: [YMKSuggestItem], _ result: @escaping FlutterResult) {
    let suggestItems = res.map({ (suggestItem) -> [String : Any] in
      var dict = [String : Any]()

      dict["title"] = suggestItem.title.text
      dict["subtitle"] = suggestItem.subtitle?.text
      dict["displayText"] = suggestItem.displayText
      dict["searchText"] = suggestItem.searchText
      dict["type"] = suggestItem.type.rawValue
      dict["tags"] = suggestItem.tags

      return dict
    })

    result(["items":suggestItems])
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
}
