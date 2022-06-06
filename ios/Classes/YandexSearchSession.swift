import Foundation
import YandexMapsMobile

public class YandexSearchSession: NSObject {
  private var id: Int
  private var session: YMKSearchSession
  private var page = 0
  private let methodChannel: FlutterMethodChannel!
  private var onClose: (Int) -> ()

  public required init(
    id: Int,
    session: YMKSearchSession,
    registrar: FlutterPluginRegistrar,
    onClose: @escaping ((Int) -> ())
  ) {
    self.id = id
    self.session = session
    self.onClose = onClose

    methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_search_session_\(id)",
      binaryMessenger: registrar.messenger()
    )

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
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
    let items: [[String: Any?]] = res.collection.children.compactMap { item in
      let obj = item.obj

      if (obj == nil) {
        return nil
      }

      return [
        "name": obj!.name,
        "geometry": obj!.geometry.map { Utils.geometryToJson($0) },
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
    result(Utils.errorToJson(error))
  }

  private func getToponymMetadata(metadataContainer: YRTCollection) -> [String: Any]? {
    let meta = metadataContainer.getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata

    if (meta == nil) {
      return nil
    }

    return [
      "balloonPoint": Utils.pointToJson(meta!.balloonPoint),
      "address": [
        "formattedAddress": meta!.address.formattedAddress,
        "addressComponents": getAddressComponents(address: meta!.address)
      ]
    ]
  }

  private func getBusinessMetadata(metadataContainer: YRTCollection) -> [String: Any?]? {
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
