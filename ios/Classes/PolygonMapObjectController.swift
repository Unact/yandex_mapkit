import YandexMapsMobile

class PolygonMapObjectController: NSObject, MapObjectController, YMKMapObjectTapListener {
  public let polygon: YMKPolygonMapObject
  private var consumeTapEvents: Bool = false
  public weak var controller: YandexMapController?
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    let polygon = parent.addPolygon(with: Utils.polygonFromJson(params["polygon"] as! [String: Any]))

    self.polygon = polygon
    self.id = params["id"] as! String
    self.controller = controller

    super.init()

    polygon.userData = self.id
    polygon.addTapListener(with: self)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    polygon.geometry = Utils.polygonFromJson(params["polygon"] as! [String: Any])
    polygon.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    polygon.zIndex = (params["zIndex"] as! NSNumber).floatValue
    polygon.isVisible = (params["isVisible"] as! NSNumber).boolValue
    polygon.strokeColor = Utils.uiColor(fromInt: (params["strokeColor"] as! NSNumber).int64Value)
    polygon.strokeWidth = (params["strokeWidth"] as! NSNumber).floatValue
    polygon.fillColor = Utils.uiColor(fromInt: (params["fillColor"] as! NSNumber).int64Value)

    consumeTapEvents = (params["consumeTapEvents"] as! NSNumber).boolValue
  }

  public func remove() {
    polygon.parent.remove(with: polygon)
  }

  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    controller!.mapObjectTap(id: id, point: point)

    return consumeTapEvents
  }
}
