import YandexMapsMobile

class YandexPolygonController: NSObject, YandexMapObjectController {
  public let polygon: YMKPolygonMapObject
  private let tapListener: YandexMapObjectTapListener
  private unowned var controller: YandexMapController
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    let polygon = parent.addPolygon(with: Utils.polygonFromJson(params))

    self.polygon = polygon
    self.id = params["id"] as! String
    self.controller = controller
    self.tapListener = YandexMapObjectTapListener(id: id, controller: controller)

    super.init()

    polygon.userData = self.id
    polygon.addTapListener(with: tapListener)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    let style = params["style"] as! [String: Any]

    polygon.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    polygon.zIndex = (params["zIndex"] as! NSNumber).floatValue
    polygon.strokeColor = Utils.uiColor(fromInt: (style["strokeColor"] as! NSNumber).int64Value)
    polygon.strokeWidth = (style["strokeWidth"] as! NSNumber).floatValue
    polygon.fillColor = Utils.uiColor(fromInt: (style["fillColor"] as! NSNumber).int64Value)
    polygon.geometry = Utils.polygonFromJson(params)
    polygon.isVisible = (params["isVisible"] as! NSNumber).boolValue
  }

  public func remove() {
    polygon.parent.remove(with: polygon)
  }
}
