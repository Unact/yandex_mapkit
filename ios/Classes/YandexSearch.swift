import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexSearch: NSObject, FlutterPlugin {
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager!
  private var searchSessions: [Int: YandexSearchSession] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_search",
      binaryMessenger: registrar.messenger()
    )

    let plugin = YandexSearch(channel: channel, registrar: registrar)

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
    case "searchByText":
      searchByText(call, result)
    case "searchByPoint":
      searchByPoint(call, result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func searchByText(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]
    let sessionId  = params["sessionId"] as! Int
    let session = searchManager.submit(
      withText: params["searchText"] as! String,
      geometry: Utils.geometryFromJson(params["geometry"] as! [String: Any]),
      searchOptions: Utils.searchOptionsFromJson(params["searchOptions"] as! [String: Any]),
      responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
        self.searchSessions[sessionId]?.handleResponse(searchResponse: searchResponse, error: error, result: result)
      }
    )

    searchSessions[sessionId] = YandexSearchSession(
      id: sessionId,
      session: session,
      registrar: pluginRegistrar,
      onClose: { (id) in self.searchSessions.removeValue(forKey: id) }
    )
  }

  public func searchByPoint(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]
    let sessionId = params["sessionId"] as! Int
    let session = searchManager.submit(
      with: Utils.pointFromJson(params["point"] as! [String: NSNumber]),
      zoom: params["zoom"] as? NSNumber,
      searchOptions: Utils.searchOptionsFromJson(params["searchOptions"] as! [String: Any]),
      responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
        self.searchSessions[sessionId]?.handleResponse(searchResponse: searchResponse, error: error, result: result)
      }
    )

    searchSessions[sessionId] = YandexSearchSession(
      id: sessionId,
      session: session,
      registrar: pluginRegistrar,
      onClose: { (id) in self.searchSessions.removeValue(forKey: id) }
    )
  }
}
