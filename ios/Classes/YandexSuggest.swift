import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile


public class YandexSuggest: NSObject, FlutterPlugin {
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager!
  private var suggestSessions: [Int:YandexSuggestSession] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_suggest",
      binaryMessenger: registrar.messenger()
    )

    let plugin = YandexSuggest(channel: channel, registrar: registrar)

    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.methodChannel = channel
    self.searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)

    super.init()

    self.methodChannel.setMethodCallHandler(self.handle)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSuggestions":
      getSuggestions(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func getSuggestions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]
    let sessionId = (params["sessionId"] as! NSNumber).intValue
    let formattedAddress = params["formattedAddress"] as! String

    let boundingBox = YMKBoundingBox.init(
      southWest: YMKPoint.init(
        latitude: (params["southWestLatitude"] as! NSNumber).doubleValue,
        longitude: (params["southWestLongitude"] as! NSNumber).doubleValue
      ),
      northEast: YMKPoint.init(
        latitude: (params["northEastLatitude"] as! NSNumber).doubleValue,
        longitude: (params["northEastLongitude"] as! NSNumber).doubleValue
      )
    )

    let session = self.searchManager!.createSuggestSession()
    let suggestType = YMKSuggestType.init(rawValue: (params["suggestType"] as! NSNumber).uintValue)
    let suggestOptions = YMKSuggestOptions.init(
      suggestTypes: suggestType,
      userPosition: nil,
      suggestWords: (params["suggestWords"] as! NSNumber).boolValue
    )

    session.suggest(
      withText: formattedAddress,
      window: boundingBox,
      suggestOptions: suggestOptions,
      responseHandler: {(suggestResponse: [YMKSuggestItem]?, error: Error?) -> Void in
        if let s = self.suggestSessions[sessionId] {
          s.handleResponse(suggestResponse: suggestResponse, error: error, result: result)
        }
      }
    )

    let suggestSession = YandexSuggestSession(
      id: sessionId,
      session: session,
      registrar: pluginRegistrar,
      onClose: { (id) in self.suggestSessions.removeValue(forKey: id) }
    )

    suggestSessions[sessionId] = suggestSession
  }
}
