import YandexMapsMobile

class CircleMapObjectController: NSObject, MapObjectController, YMKMapObjectTapListener {
  private let internallyControlled: Bool
  public let circle: YMKCircleMapObject
  private var consumeTapEvents: Bool = false
  public weak var controller: YandexMapController?
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    let circle = parent.addCircle(with: Utils.circleFromJson(params["circle"] as! [String: Any]))

    self.circle = circle
    self.id = params["id"] as! String
    self.controller = controller
    self.internallyControlled = false

    super.init()

    circle.userData = self.id
    circle.addTapListener(with: self)
    update(params)
  }

  public required init(
    circle: YMKCircleMapObject,
    params: [String: Any],
    controller: YandexMapController
  ) {
    self.circle = circle
    self.id = params["id"] as! String
    self.controller = controller
    self.internallyControlled = true

    super.init()

    circle.userData = self.id
    circle.addTapListener(with: self)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    if (!internallyControlled) {
      circle.geometry = Utils.circleFromJson(params["circle"] as! [String: Any])
      circle.isVisible = (params["isVisible"] as! NSNumber).boolValue
    }

    circle.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    circle.zIndex = (params["zIndex"] as! NSNumber).floatValue
    circle.strokeColor = Utils.uiColor(fromInt: (params["strokeColor"] as! NSNumber).int64Value)
    circle.strokeWidth = (params["strokeWidth"] as! NSNumber).floatValue
    circle.fillColor = Utils.uiColor(fromInt: (params["fillColor"] as! NSNumber).int64Value)

    consumeTapEvents = (params["consumeTapEvents"] as! NSNumber).boolValue
  }

  public func remove() {
    if (internallyControlled) {
      return
    }

    circle.parent.remove(with: circle)
  }

  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    controller!.mapObjectTap(id: id, point: point)

    return consumeTapEvents
  }
}
