import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexSuggest: NSObject, FlutterPlugin {
  
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager!
  private var suggestSessionsById: [Int:YMKSearchSuggestSession] = [:]
  
  private var searchSessions: [Int:YandexSearchSession] = [:]
  
  
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
      getSuggestions(call)
      result(nil)
    case "cancelSuggestSession":
      cancelSuggestSession(call)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func cancelSuggestSession(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let listenerId = (params["listenerId"] as! NSNumber).intValue

    self.suggestSessionsById.removeValue(forKey: listenerId)
  }

  public func getSuggestions(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let listenerId = (params["listenerId"] as! NSNumber).intValue
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
    let suggestSession = self.searchManager!.createSuggestSession()
    let suggestType = YMKSuggestType.init(rawValue: (params["suggestType"] as! NSNumber).uintValue)
    let suggestOptions = YMKSuggestOptions.init(
      suggestTypes: suggestType,
      userPosition: nil,
      suggestWords: (params["suggestWords"] as! NSNumber).boolValue
    )

    suggestSession.suggest(
      withText: formattedAddress,
      window: boundingBox,
      suggestOptions: suggestOptions,
      responseHandler: buildResponseHandler(listenerId: listenerId)
    )
    self.suggestSessionsById[listenerId] = suggestSession;
  }

  private func buildResponseHandler(listenerId: Int) -> ([YMKSuggestItem]?, Error?) -> Void {
    return { (searchResponse: [YMKSuggestItem]?, error: Error?) -> Void in
      if searchResponse != nil {
        let suggestItems = searchResponse!.map({ (suggestItem) -> [String : Any] in
          var dict = [String : Any]()

          dict["title"] = suggestItem.title.text
          dict["subtitle"] = suggestItem.subtitle?.text
          dict["displayText"] = suggestItem.displayText
          dict["searchText"] = suggestItem.searchText
          dict["type"] = suggestItem.type.rawValue
          dict["tags"] = suggestItem.tags

          return dict
        })
        let arguments: [String:Any?] = [
          "listenerId": listenerId,
          "response": suggestItems
        ]
        self.methodChannel.invokeMethod("onSuggestListenerResponse", arguments: arguments)

        return
      }

      if error != nil {
        let arguments: [String:Any?] = [
          "listenerId": listenerId
        ]
        self.methodChannel.invokeMethod("onSuggestListenerError", arguments: arguments)

        return
      }
    }
  }
}
