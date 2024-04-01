import Foundation
import YandexMapsMobile

public class YandexSuggestSession: NSObject {
  private var id: Int
  private var session: YMKSearchSuggestSession!
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager
  private static var suggestSessions: [Int: YandexSuggestSession] = [:]

  public static func initSession(id: Int, registrar: FlutterPluginRegistrar, searchManager: YMKSearchManager) {
    suggestSessions[id] = YandexSuggestSession(id: id, registrar: registrar, searchManager: searchManager)
  }

  public required init(id: Int, registrar: FlutterPluginRegistrar, searchManager: YMKSearchManager) {
    self.id = id
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_suggest_session_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.searchManager = searchManager

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSuggestions":
      getSuggestions(call, result)
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

  public func getSuggestions(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]

    session = self.searchManager.createSuggestSession()
    session.suggest(
      withText: params["text"] as! String,
      window: UtilsFull.boundingBoxFromJson(params["boundingBox"] as! [String: Any]),
      suggestOptions: UtilsFull.suggestOptionsFromJson(params["suggestOptions"] as! [String: Any]),
      responseHandler: {(suggestResponse: YMKSuggestResponse?, error: Error?) -> Void in
        self.handleResponse(suggestResponse: suggestResponse, error: error, result: result)
      }
    )

  }

  public func reset() {
    session.reset()
  }

  public func close() {
    session.reset()

    YandexSuggestSession.suggestSessions.removeValue(forKey: id)
  }

  public func handleResponse(suggestResponse: YMKSuggestResponse?, error: Error?, result: @escaping FlutterResult) {
    if let response = suggestResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }

  private func onSuccess(_ res: YMKSuggestResponse, _ result: @escaping FlutterResult) {
    let items = res.items.map { (suggestItem) -> [String: Any?] in
      return [
        "title": suggestItem.title.text,
        "subtitle": suggestItem.subtitle?.text,
        "displayText": suggestItem.displayText,
        "searchText": suggestItem.searchText,
        "type": suggestItem.type.rawValue,
        "tags": suggestItem.tags,
        "center": suggestItem.center != nil ? UtilsFull.pointToJson(suggestItem.center!) : nil
      ]
    }

    let arguments: [String: Any] = [
      "items": items
    ]

    result(arguments)
  }

  private func onError(_ error: Error, _ result: @escaping FlutterResult) {
    result(UtilsFull.errorToJson(error))
  }
}
