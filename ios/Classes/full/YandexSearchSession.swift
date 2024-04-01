import Foundation
import YandexMapsMobile

public class YandexSearchSession: NSObject {
  private var id: Int
  private var session: YMKSearchSession!
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager
  private var page = 0
  private static var searchSessions: [Int: YandexSearchSession] = [:]

  public static func initSession(id: Int, registrar: FlutterPluginRegistrar, searchManager: YMKSearchManager) {
    searchSessions[id] = YandexSearchSession(id: id, registrar: registrar, searchManager: searchManager)
  }

  public required init(id: Int, registrar: FlutterPluginRegistrar, searchManager: YMKSearchManager) {
    self.id = id
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_search_session_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.searchManager = searchManager

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "searchByText":
      searchByText(call, result)
    case "searchByPoint":
      searchByPoint(call, result)
    case "cancel":
      cancel()
      result(nil)
    case "retry":
      retry(result)
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

  public func searchByText(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]

    session = searchManager.submit(
      withText: params["searchText"] as! String,
      geometry: UtilsFull.geometryFromJson(params["geometry"] as! [String: Any]),
      searchOptions: UtilsFull.searchOptionsFromJson(params["searchOptions"] as! [String: Any]),
      responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
        self.handleResponse(searchResponse: searchResponse, error: error, result: result)
      }
    )
  }

  public func searchByPoint(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]

    session = searchManager.submit(
      with: UtilsFull.pointFromJson(params["point"] as! [String: NSNumber]),
      zoom: params["zoom"] as? NSNumber,
      searchOptions: UtilsFull.searchOptionsFromJson(params["searchOptions"] as! [String: Any]),
      responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
        self.handleResponse(searchResponse: searchResponse, error: error, result: result)
      }
    )
  }

  public func cancel() {
    session.cancel()
  }

  public func retry(_ result: @escaping FlutterResult) {
    page = 0

    session.retry(responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
      self.handleResponse(searchResponse: searchResponse, error: error, result: result)
    })
  }

  public func hasNextPage() -> Bool {
    return session.hasNextPage()
  }

  public func fetchNextPage(_ result: @escaping FlutterResult) {
    if (session.hasNextPage()) {
      page += 1

      session.fetchNextPage(responseHandler: {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
        self.handleResponse(searchResponse: searchResponse, error: error, result: result)
      })
    }
  }

  public func close() {
    session.cancel()

    YandexSearchSession.searchSessions.removeValue(forKey: id)
  }

  public func handleResponse(searchResponse: YMKSearchResponse?, error: Error?, result: @escaping FlutterResult) {
    if let response = searchResponse {
      onSuccess(response, result)
    } else {
      onError(error!, result)
    }
  }

  private func onSuccess(_ res: YMKSearchResponse, _ result: @escaping FlutterResult) {
    let items: [[String: Any?]] = res.collection.children.compactMap { item in
      let obj = item.obj

      if (obj == nil) {
        return nil
      }

      return [
        "name": obj!.name,
        "geometry": obj!.geometry.map { UtilsFull.geometryToJson($0) },
        "toponymMetadata": getToponymMetadata(metadataContainer: obj!.metadataContainer),
        "businessMetadata": getBusinessMetadata(metadataContainer: obj!.metadataContainer)
      ]
    }

    let arguments: [String: Any] = [
      "found": res.metadata.found,
      "page": page,
      "items": items
    ]

    result(arguments)
  }

  private func onError(_ error: Error, _ result: @escaping FlutterResult) {
    result(UtilsFull.errorToJson(error))
  }

  private func getToponymMetadata(metadataContainer: YRTTypeDictionary<YMKBaseMetadata>) -> [String: Any]? {
    let meta = metadataContainer.getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata

    if (meta == nil) {
      return nil
    }

    return [
      "balloonPoint": UtilsFull.pointToJson(meta!.balloonPoint),
      "address": [
        "formattedAddress": meta!.address.formattedAddress,
        "addressComponents": getAddressComponents(address: meta!.address)
      ]
    ]
  }

  private func getBusinessMetadata(metadataContainer: YRTTypeDictionary<YMKBaseMetadata>) -> [String: Any?]? {
    let meta = metadataContainer.getItemOf(YMKSearchBusinessObjectMetadata.self) as? YMKSearchBusinessObjectMetadata

    if (meta == nil) {
      return nil
    }

    return [
      "name": meta!.name,
      "shortName": meta!.shortName,
      "address": [
        "formattedAddress": meta!.address.formattedAddress,
        "addressComponents": getAddressComponents(address: meta!.address)
      ]
    ]
  }

  private func getAddressComponents(address: YMKSearchAddress) -> [Int: String] {
    var addressComponents = [Int : String]()

    address.components.forEach {
      let value = $0.name

      $0.kinds.forEach {
        var flutterKind: Int = 0
        let kind = YMKSearchComponentKind(rawValue: UInt(truncating: $0))

        switch kind {
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
        default:
          flutterKind = 0
        }

        addressComponents[flutterKind] = value
      }
    }

    return addressComponents
  }
}
