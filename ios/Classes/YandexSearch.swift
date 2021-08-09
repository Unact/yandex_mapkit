import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexSearch: NSObject, FlutterPlugin {
  
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager!
  private var suggestSessionsById: [Int:YMKSearchSuggestSession] = [:]
  
  private var searchSessions: [Int:YandexSearchSession] = [:]
  
  
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
    case "getSuggestions":
      getSuggestions(call)
      result(nil)
    case "cancelSuggestSession":
      cancelSuggestSession(call)
      result(nil)
    case "searchByText":
      searchByText(call, result)
    case "searchByPoint":
      searchByPoint(call, result)
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
  
  public func searchByText(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    
    let params = call.arguments as! [String: Any]
    
    let sessionId  = params["sessionId"] as! Int
    let searchText = params["searchText"] as! String
    let geometry   = params["geometry"] as! [String:Any]
    let options    = params["options"] as! [String:Any]
    
    var geometryObj: YMKGeometry
    
    if let geometryPoint = geometry["point"] as? [String:Any] {
      
      geometryObj = YMKGeometry(
        point: YMKPoint(
          latitude: (geometryPoint["latitude"] as! NSNumber).doubleValue,
          longitude: (geometryPoint["longitude"] as! NSNumber).doubleValue
        )
      )
      
    } else {
      
      let geometryBoundingBox = geometry["boundingBox"] as! [String:Any]
      let southWest = geometryBoundingBox["southWest"] as! [String:Any]
      let northEast = geometryBoundingBox["northEast"] as! [String:Any]
      
      geometryObj = YMKGeometry(
        boundingBox: YMKBoundingBox(
          southWest: YMKPoint(
            latitude: (southWest["latitude"] as! NSNumber).doubleValue,
            longitude: (southWest["longitude"] as! NSNumber).doubleValue
          ),
          northEast: YMKPoint(
            latitude: (northEast["latitude"] as! NSNumber).doubleValue,
            longitude: (northEast["longitude"] as! NSNumber).doubleValue
          )
        )
      )
    }
    
    let searchOptions = getSearchOptions(options)
    
    let searchSession = searchManager.submit(
      withText: searchText,
      geometry: geometryObj,
      searchOptions: searchOptions,
      responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
        if let s = self.searchSessions[sessionId] {
          s.handleResponse(searchResponse: searchResponse, error: error, result: result)
        }
      }
    )
    
    let session = YandexSearchSession(id: sessionId, session: searchSession, registrar: pluginRegistrar, onClose: { (sessionId) in
      self.searchSessions.removeValue(forKey: sessionId)
    })
    
    searchSessions[sessionId] = session
  }
  
  public func searchByPoint(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    
    let params = call.arguments as! [String: Any]
    
    let sessionId = params["sessionId"] as! Int
    let point     = params["point"] as! [String:Any]
    let zoom      = params["zoom"] as? NSNumber
    let options   = params["options"] as! [String:Any]
    
    let searchOptions = getSearchOptions(options)
    
    let searchSession = searchManager.submit(
      with: YMKPoint(
        latitude: (point["latitude"] as! NSNumber).doubleValue,
        longitude: (point["longitude"] as! NSNumber).doubleValue
      ),
      zoom: zoom,
      searchOptions: searchOptions,
      responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
        if let s = self.searchSessions[sessionId] {
          s.handleResponse(searchResponse: searchResponse, error: error, result: result)
        }
      }
    )
    
    let session = YandexSearchSession(id: sessionId, session: searchSession, registrar: pluginRegistrar, onClose: { (sessionId) in
      self.searchSessions.removeValue(forKey: sessionId)
    })
    
    searchSessions[sessionId] = session
  }
  
  private func getSearchOptions(_ options: [String:Any]) -> YMKSearchOptions {
    
    let searchTypeOption     = (options["searchType"] as! NSNumber).uintValue
    let resultPageSizeOption = options["resultPageSize"] as? NSNumber
    let userPositionOption   = options["userPosition"] as? [String:Any]
    
    let searchType = YMKSearchType.init(rawValue: searchTypeOption)
    
    // Theses params are not implemented on the flutter side yet
    let snippetsOption             = YMKSearchSnippet(rawValue: 0) // None
    let experimentalSnippetsOption = [String]()
    
    let userPosition = userPositionOption != nil
      ? YMKPoint.init(
          latitude: (userPositionOption!["latitude"] as! NSNumber).doubleValue,
          longitude: (userPositionOption!["longitude"] as! NSNumber).doubleValue
        )
      : nil
      
    let originOption                    = options["origin"] as? String
    let directPageIdOption              = options["directPageId"] as? String
    let appleCtxOption                  = options["appleCtx"] as? String
    let geometryOption                  = (options["geometry"] as! NSNumber).boolValue
    let advertPageIdOption              = options["advertPageId"] as? String
    let suggestWordsOption              = (options["suggestWords"] as! NSNumber).boolValue
    let disableSpellingCorrectionOption = (options["disableSpellingCorrection"] as! NSNumber).boolValue
    
    let searchOptions = YMKSearchOptions.init(
      searchTypes: searchType,
      resultPageSize: resultPageSizeOption,
      snippets: snippetsOption,
      experimentalSnippets: experimentalSnippetsOption,
      userPosition: userPosition,
      origin: originOption,
      directPageId: directPageIdOption,
      appleCtx: appleCtxOption,
      geometry: geometryOption,
      advertPageId: advertPageIdOption,
      suggestWords: suggestWordsOption,
      disableSpellingCorrection: disableSpellingCorrectionOption
    )
    
    return searchOptions
  }
}
