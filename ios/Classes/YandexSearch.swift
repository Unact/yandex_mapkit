import CoreLocation
import Flutter
import UIKit
import YandexMapKit
import YandexMapKitSearch

public class YandexSearch: NSObject, FlutterPlugin {
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager!
  private var suggestSessionsById: [Int:YMKSearchSuggestSession] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "yandex_mapkit/yandex_search",
                                       binaryMessenger: registrar.messenger())
    let plugin = YandexSearch(channel: channel)
    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required init(channel: FlutterMethodChannel) {
    self.methodChannel = channel
    self.searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    super.init()
    
    self.methodChannel.setMethodCallHandler(self.handle)
  }
  
  public func cancelSuggestSession(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let listenerId = params["listenerId"] as! Int
    self.suggestSessionsById.removeValue(forKey: listenerId)
  }

  public func getSuggestions(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    
    let listenerId = params["listenerId"] as! Int
    
    let formattedAddress = params["formattedAddress"] as! String
    let boundingBox = YMKBoundingBox.init(
      southWest: YMKPoint.init(latitude: params["southWestLatitude"] as! Double,
                               longitude: params["southWestLongitude"] as! Double),
      northEast: YMKPoint.init(latitude: params["northEastLatitude"] as! Double,
                               longitude: params["northEastLongitude"] as! Double))
    let responseHandler = {(searchResponse: [YMKSuggestItem]?, error: Error?) -> Void in
      let thisListenerId = listenerId
      if searchResponse != nil {
        let suggestItems = searchResponse?.map({ (suggestItem) -> [String : Any] in
          var dict = [String : Any]()
          dict["title"] = suggestItem.title.text
          dict["subtitle"] = suggestItem.subtitle?.text
          dict["displayText"] = suggestItem.displayText
          dict["searchText"] = suggestItem.searchText
          dict["tags"] = suggestItem.tags
          switch suggestItem.type {
          case .toponym:
            dict["type"] = "TOPONYM"
          case .business:
            dict["type"] = "BUSINESS"
          case .transit:
            dict["type"] = "TRANSIT"
          default:
            dict["type"] = "UNKNOWN"
          }
          return dict
        })
        let arguments: [String:Any?] = [
          "listenerId": thisListenerId,
          "response": suggestItems
        ]
        self.methodChannel.invokeMethod("onSuggestListenerResponse", arguments: arguments)
      } else if error != nil {
        let arguments: [String:Any?] = [
          "listenerId": thisListenerId
        ]
        self.methodChannel.invokeMethod("onSuggestListenerError", arguments: arguments)
      }
    }

    let suggestSession = self.searchManager!.createSuggestSession()
    var suggestType = YMKSuggestType()
    switch params["suggestType"] as! String {
    case "GEO":
      suggestType = YMKSuggestType.geo
    case "BIZ":
      suggestType = YMKSuggestType.biz
    case "TRANSIT":
      suggestType = YMKSuggestType.transit
    default:
      suggestType = YMKSuggestType.init(rawValue: 0)
    }
    let suggestOptions =
      YMKSuggestOptions.init(suggestTypes: suggestType,
                             userPosition: nil,
                             suggestWords: params["suggestWords"] as! Bool)
    suggestSession.suggest(withText: formattedAddress,
                           window: boundingBox,
                           suggestOptions: suggestOptions,
                           responseHandler: responseHandler)
    self.suggestSessionsById[listenerId] = suggestSession;
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
}
