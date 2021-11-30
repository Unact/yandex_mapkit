import YandexMapsMobile

class YandexPolylineController: NSObject, YandexMapObjectController {
  public let polyline: YMKPolylineMapObject
  private let tapListener: YandexMapObjectTapListener
  private unowned var controller: YandexMapController
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    let polyline = parent.addPolyline(with: Utils.polylineFromJson(params))

    self.polyline = polyline
    self.id = params["id"] as! String
    self.controller = controller
    self.tapListener = YandexMapObjectTapListener(id: id, controller: controller)

    super.init()

    polyline.userData = self.id
    polyline.addTapListener(with: tapListener)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    polyline.geometry = Utils.polylineFromJson(params)
    polyline.zIndex = (params["zIndex"] as! NSNumber).floatValue
    polyline.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    polyline.isVisible = (params["isVisible"] as! NSNumber).boolValue
    polyline.strokeColor = Utils.uiColor(fromInt: (params["strokeColor"] as! NSNumber).int64Value)
    polyline.outlineColor = Utils.uiColor(fromInt: (params["outlineColor"] as! NSNumber).int64Value)
    polyline.outlineWidth = (params["outlineWidth"] as! NSNumber).floatValue
    polyline.strokeWidth = (params["strokeWidth"] as! NSNumber).floatValue
    polyline.dashLength = (params["dashLength"] as! NSNumber).floatValue
    polyline.dashOffset = (params["dashOffset"] as! NSNumber).floatValue
    polyline.gapLength = (params["gapLength"] as! NSNumber).floatValue
  }

  public func remove() {
    polyline.parent.remove(with: polyline)
  }
}
