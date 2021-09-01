import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile


public class YandexSuggest: NSObject, FlutterPlugin {
  
  private let searchManager: YMKSearchManager!
  private var suggestSessionsById: [Int:YMKSearchSuggestSession] = [:]
  
  private var searchSessions: [Int:YandexSearchSession] = [:]
  
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_suggest",
      binaryMessenger: registrar.messenger()
    )

    let plugin = YandexSuggest()
    
    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required override init() {
    
    self.searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    
    super.init()
  }
  
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch call.method {
    case "getSuggestions":
      getSuggestions(call, result: result)
    case "cancelSuggestSession":
      cancelSuggestSession(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func cancelSuggestSession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    let params = call.arguments as! [String: Any]
    let listenerId = (params["listenerId"] as! NSNumber).intValue
    
    if let session = suggestSessionsById[listenerId] {
        session.reset()
        suggestSessionsById.removeValue(forKey: listenerId)
    }
    
    result(nil)
  }

  public func getSuggestions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
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
      responseHandler: buildResponseHandler(listenerId: listenerId, result: result)
    )
    
    self.suggestSessionsById[listenerId] = suggestSession;
  }

  private func buildResponseHandler(listenerId: Int, result: @escaping FlutterResult) -> ([YMKSuggestItem]?, Error?) -> Void {

    return { (searchResponse: [YMKSuggestItem]?, error: Error?) -> Void in
      
      self.suggestSessionsById.removeValue(forKey: listenerId)
      
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
        
        result(["items":suggestItems])
        return
      }

      if error != nil {
        result(["error": "YMKSearchManager error"])
        return
      }
    }
  }
}
