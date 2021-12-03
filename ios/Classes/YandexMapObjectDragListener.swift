import YandexMapsMobile

class YandexMapObjectDragListener: NSObject, YMKMapObjectDragListener {
  private unowned var controller: YandexMapController
  public let id: String

  public required init(id: String, controller: YandexMapController) {
    self.id = id
    self.controller = controller
  }

  internal func onMapObjectDragStart(with mapObject: YMKMapObject) {
    let arguments: [String: Any?] = [
      "id": id
    ]

    controller.methodChannel.invokeMethod("onMapObjectDragStart", arguments: arguments)
  }

  internal func onMapObjectDrag(with mapObject: YMKMapObject, point: YMKPoint) {
    let arguments: [String: Any?] = [
      "id": id,
      "point": Utils.pointToJson(point)
    ]
    controller.methodChannel.invokeMethod("onMapObjectDrag", arguments: arguments)
  }

  internal func onMapObjectDragEnd(with mapObject: YMKMapObject) {
    let arguments: [String: Any?] = [
      "id": id
    ]

    controller.methodChannel.invokeMethod("onMapObjectDragEnd", arguments: arguments)
  }
}
