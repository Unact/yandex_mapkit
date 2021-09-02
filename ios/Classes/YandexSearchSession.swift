import Foundation
import YandexMapsMobile

public class YandexSearchSession: NSObject {
  
  private var id: Int
  private var session: YMKSearchSession?
  private var page = 0
  
  private let methodChannel: FlutterMethodChannel!
  
  private var onClose: (Int) -> ()
  
  
  public required init(
    id: Int,
    session: YMKSearchSession,
    registrar: FlutterPluginRegistrar,
    onClose: @escaping ((Int) -> ())) {
    
    self.id       = id
    self.session  = session
    self.onClose  = onClose
    
    methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_search_session_\(id)",
      binaryMessenger: registrar.messenger()
    )
    
    super.init()
    
    methodChannel.setMethodCallHandler(handle)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
      switch call.method {
      case "cancelSearch":
        cancelSearch()
        result(nil)
      case "retrySearch":
        retrySearch(result)
      case "hasNextPage":
        let value = hasNextPage()
        result(value)
      case "fetchNextPage":
        fetchNextPage(result)
      case "close":
        close()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
  }
  
  public func cancelSearch() {
    
    session?.cancel()
  }
  
  public func retrySearch(_ result: @escaping FlutterResult) {
    
    page = 0
    
    session?.retry(responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
      self.handleResponse(searchResponse: searchResponse, error: error, result: result)
    })
  }
  
  public func hasNextPage() -> Bool {
    
    return session?.hasNextPage() ?? false
  }
  
  public func fetchNextPage(_ result: @escaping FlutterResult) {
    
    guard let session = self.session else {
      return
    }
    
    if (session.hasNextPage()) {
      
      page += 1
      
      session.fetchNextPage(responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
        self.handleResponse(searchResponse: searchResponse, error: error, result: result)
      })
    }
  }
  
  public func close() {
    
    session?.cancel()
    session = nil
    
    methodChannel.setMethodCallHandler(nil)
    
    onClose(id)
  }
  
  public func handleResponse(searchResponse: YMKSearchResponse?, error: Error?, result: @escaping FlutterResult) {
    
    if let response = searchResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }
  
  private func onSuccess(_ res: YMKSearchResponse, _ result: @escaping FlutterResult) {
    
    var data = [String : Any]()
      
    data["found"] = res.metadata.found
    data["page"]  = page
    
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
    
    result(arguments)
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
    
    let arguments: [String:Any?] = [
      "error": errorMessage
    ]
    
    result(arguments)
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
}
