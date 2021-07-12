import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexSearch: NSObject, FlutterPlugin {
  
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager!
  private var suggestSessionsById: [Int:YMKSearchSuggestSession] = [:]
  
  private var searchSession: YMKSearchSession?
  

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_search",
      binaryMessenger: registrar.messenger()
    )
    let plugin = YandexSearch(channel: channel)
    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required init(channel: FlutterMethodChannel) {
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
      searchByText(call)
      result(nil)
    case "cancelSearchSession":
      cancelSearchSession(call)
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
  
  public func searchByText(_ call: FlutterMethodCall) {
    
    let params = call.arguments as! [String: Any]
    
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
      
    } else if
      let geometryBoundingBox = geometry["boundingBox"] as? [String:Any],
      let southWest = geometryBoundingBox["southWest"] as? [String:Any],
      let northEast = geometryBoundingBox["northEast"] as? [String:Any] {
      
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
    } else {
      onSearchError(NSError(domain: "", code: 0, userInfo: ["message" : "Invalid geometry"]))
      return
    }
    
    let searchTypeOption           = (options["searchType"] as! NSNumber).uintValue
    let resultPageSizeOption       = options["resultPageSize"] as? NSNumber
    let snippetsOption             = options["snippets"] as! [NSNumber]
    let experimentalSnippetsOption = options["experimentalSnippets"] as! [String]
    let userPositionOption         = options["userPosition"] as? [String:Any]
    
    let searchType = YMKSearchType.init(rawValue: searchTypeOption)
    
    let snippet = YMKSearchSnippet(
      rawValue: snippetsOption
        .map({ val in
          return val.uintValue
        })
        .reduce(0, |)
    )
    
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
      snippets: snippet,
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
    
    let responseHandler = {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
      if let response = searchResponse {
          self.onSearchResponse(response)
      } else {
          self.onSearchError(error!)
      }
    }
    
    searchSession = searchManager.submit(
      withText: searchText,
      geometry: geometryObj,
      searchOptions: searchOptions,
      responseHandler: responseHandler)
  }
  
  private func onSearchResponse(_ res: YMKSearchResponse) {
    
    var data = [String : Any]()
      
    data["found"] = res.metadata.found
    
    var dataItems = [[String : Any]]()
    
    for searchItem in res.collection.children {
      
      guard let obj = searchItem.obj else {
        continue
      }
      
      var dataItem = [String : Any]()
      
      dataItem["name"] = obj.name
      
      var geometry = [[String : Any]]()
      
      obj.geometry.forEach {
        
        if let point = $0.point {
          geometry.append([
            "point": [
              "latitude": point.latitude,
              "longitude": point.longitude,
            ]
          ])
        }
        
        if let boundingBox = $0.boundingBox {
          geometry.append([
            "boundingBox": [
              "southWest": [
                "latitude": boundingBox.southWest.latitude,
                "longitude": boundingBox.southWest.longitude,
              ],
              "northEast": [
                "latitude": boundingBox.northEast.latitude,
                "longitude": boundingBox.northEast.longitude,
              ],
            ]
          ])
        }
      }
      
      dataItem["geometry"] = geometry;
      
      if let toponymMeta = obj.metadataContainer.getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata {
        dataItem["toponymMetadata"] = getToponymMetadata(meta: toponymMeta)
      }
      
      if let businessMeta = obj.metadataContainer.getItemOf(YMKSearchBusinessObjectMetadata.self) as? YMKSearchBusinessObjectMetadata {
        dataItem["businessMetadata"] = getBusinessMetadata(meta: businessMeta)
      }
      
      dataItems.append(dataItem)
    }
    
    data["items"] = dataItems
    
    let arguments: [String:Any?] = [
      "response": data
    ]
    
    self.methodChannel.invokeMethod("onSearchListenerResponse", arguments: arguments)
  }
  
  private func getToponymMetadata(meta: YMKSearchToponymObjectMetadata) -> [String : Any] {
    
    var toponymMetadata = [String : Any]()
    
    var balloonPoint = [String : Double]()
    
    balloonPoint["latitude"]  = meta.balloonPoint.latitude
    balloonPoint["longitude"] = meta.balloonPoint.longitude
    
    toponymMetadata["balloonPoint"] = balloonPoint

    var address = [String : Any]()
    
    address["formattedAddress"] = meta.address.formattedAddress
    address["addressComponents"] = getAddressComponents(address: meta.address)
    
    toponymMetadata["address"] = address
    
    return toponymMetadata
  }
  
  private func getBusinessMetadata(meta: YMKSearchBusinessObjectMetadata) -> [String : Any] {
    
    var businessMetadata = [String : Any]()
    
    businessMetadata["name"] = meta.name
    
    if (meta.shortName != nil) {
      businessMetadata["shortName"] = meta.shortName
    }
    
    var address = [String : Any]()
    
    let addressComponents = getAddressComponents(address: meta.address)
    
    address["formattedAddress"]  = meta.address.formattedAddress
    address["addressComponents"] = addressComponents;
    
    businessMetadata["address"] = address
    
    return businessMetadata
  }
  
  private func getAddressComponents(address: YMKSearchAddress) -> [Int : String] {
   
    var addressComponents = [Int : String]()
    
    address.components.forEach {
      
      var flutterKind: Int = 0
      
      let value = $0.name

      $0.kinds.forEach {
        
        let kind = YMKSearchComponentKind(rawValue: UInt(truncating: $0))

        // Map kind to enum value in flutter
        switch kind {
        case .none, .some(.unknown):
          flutterKind = 0
        case .country:
          flutterKind = 1
        case .some(.region):
          flutterKind = 2
        case .some(.province):
          flutterKind = 3
        case .some(.area):
          flutterKind = 4
        case .some(.locality):
          flutterKind = 5
        case .some(.district):
          flutterKind = 6
        case .some(.street):
          flutterKind = 7
        case .some(.house):
          flutterKind = 8
        case .some(.entrance):
          flutterKind = 9
        case .some(.route):
          flutterKind = 10
        case .some(.station):
          flutterKind = 11
        case .some(.metroStation):
          flutterKind = 12
        case .some(.railwayStation):
          flutterKind = 13
        case .some(.vegetation):
          flutterKind = 14
        case .some(.hydro):
          flutterKind = 15
        case .some(.airport):
          flutterKind = 16
        case .some(.other):
          flutterKind = 17
        }
        
        addressComponents[flutterKind] = value
      }
    }
    
    return addressComponents
  }
  
  private func onSearchError(_ error: Error) {
    
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
    
    let arguments: [String:Any?] = [
      "error": errorMessage,
    ]
    
    self.methodChannel.invokeMethod("onSearchListenerError", arguments: arguments)

    return
  }
  
  public func cancelSearchSession(_ call: FlutterMethodCall) {
    
    searchSession?.cancel()

    searchSession = nil
  }
}
