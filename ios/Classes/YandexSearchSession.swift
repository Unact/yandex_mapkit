//
//  YandexSearchSession.swift
//  yandex_mapkit
//
//  Created by CreamCheeze on 7/28/21.
//

import Foundation
import YandexMapsMobile

public class YandexSearchSession: NSObject {
  
  private var id: String
  
  private let searchManager: YMKSearchManager!
  
  private var session: YMKSearchSession?
  
  Stream<int> stream
  
  private let pluginRegistrar: FlutterPluginRegistrar!
  
  private let methodChannel:  FlutterMethodChannel!
  private let eventChannel:   FlutterEventChannel!
  
  
  public required init(session: YMKSearchSession, registrar: FlutterPluginRegistrar) {
    
    id = UUID().uuidString
    
    self.session = session
    
    methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_search_session_\(id)",
      binaryMessenger: registrar.messenger()
    )
    methodChannel.setMethodCallHandler(handle)
    
    eventChannel = FlutterEventChannel(
      name: "yandex_mapkit/yandex_search_session_results_\(id)",
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(self)
    
    super.init()
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
      switch call.method {
      case "cancelSearch":
        cancelSearch(call)
        result(nil)
      case "retrySearch":
        retrySearch(call)
        result(nil)
      case "fetchSearchNextPage":
        fetchSearchNextPage(call)
        result(nil)
      case "closeSearchSession":
        closeSearchSession()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
  }
  
  private func getResponseHandler(_ sessionId: Int) -> YMKSearchSessionResponseHandler {
    
    let responseHandler = {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
      if let response = searchResponse {
          self.onSearchResponse(response, sessionId: sessionId)
      } else {
          self.onSearchError(error!, sessionId: sessionId)
      }
    }
    
    return responseHandler
  }
  
  public func closeSearchSession() {
      session?.cancel()
      session = nil
    }
  }
  
  public func cancelSearch(_ call: FlutterMethodCall) {
    
    let params = call.arguments as! [String: Any]
    
    let sessionId  = params["sessionId"] as! Int
    
    if let session = searchSessions[sessionId] {
      session.cancel()
    }
  }
  
  public func retrySearch(_ call: FlutterMethodCall) {
    
    let params = call.arguments as! [String: Any]
    
    let sessionId  = params["sessionId"] as! Int
    
    guard let session = searchSessions[sessionId] else {
      return
    }
    
    let responseHandler = getResponseHandler(sessionId)
    
    session.retry(responseHandler: responseHandler)
  }
  
  public func fetchSearchNextPage(_ call: FlutterMethodCall) {
    
    let params = call.arguments as! [String: Any]
    
    let sessionId  = params["sessionId"] as! Int
    
    guard let session = searchSessions[sessionId], session.hasNextPage() else {
      return
    }
    
    let responseHandler = getResponseHandler(sessionId)
    
    session.fetchNextPage(responseHandler: responseHandler)
  }
  
  private func onSearchResponse(_ res: YMKSearchResponse, sessionId: Int) {
    
    guard let session = self.se else {
      return
    }
    
    var data = [String : Any]()
      
    data["found"]       = res.metadata.found
    data["hasNextPage"] = session.hasNextPage() ? true : false
    
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
      "response": data,
      "sessionId": sessionId
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
  
  private func onSearchError(_ error: Error, sessionId: Int) {
    
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
      "sessionId": sessionId,
    ]
    
    self.methodChannel.invokeMethod("onSearchListenerError", arguments: arguments)

    return
  }
  
}

extension YandexSearchSession: FlutterStreamHandler {
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    <#code#>
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    <#code#>
  }
}
