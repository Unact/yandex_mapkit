import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexSearch: NSObject, FlutterPlugin {
  
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager!
  
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
