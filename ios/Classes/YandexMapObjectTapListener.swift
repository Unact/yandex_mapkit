import YandexMapsMobile

class YandexMapObjectTapListener: NSObject, YMKMapObjectTapListener {
  private let methodChannel: FlutterMethodChannel
  public let id: String

  public required init(id: String, methodChannel: FlutterMethodChannel) {
    self.id = id
    self.methodChannel = methodChannel
  }

  internal func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    let arguments: [String: Any?] = [
      "id": id,
      "point": Utils.pointToJson(point)
    ]
    methodChannel.invokeMethod("onMapObjectTap", arguments: arguments)

    return true
  }
}
