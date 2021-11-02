import YandexMapsMobile

class YandexMapObjectTapListener: NSObject, YMKMapObjectTapListener {
  private unowned var controller: YandexMapController
  public let id: String

  public required init(id: String, controller: YandexMapController) {
    self.id = id
    self.controller = controller
  }

  internal func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    let arguments: [String: Any?] = [
      "id": id,
      "point": Utils.pointToJson(point)
    ]
    controller.methodChannel.invokeMethod("onMapObjectTap", arguments: arguments)

    return false
  }
}
