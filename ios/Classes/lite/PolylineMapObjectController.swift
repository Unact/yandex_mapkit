import YandexMapsMobile

class PolylineMapObjectController: NSObject, MapObjectController, YMKMapObjectTapListener {
  public let polyline: YMKPolylineMapObject
  private var consumeTapEvents: Bool = false
  public weak var controller: YandexMapController?
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    let polyline = parent.addPolyline(with: UtilsLite.polylineFromJson(params["polyline"] as! [String: Any]))

    self.polyline = polyline
    self.id = params["id"] as! String
    self.controller = controller

    super.init()

    polyline.userData = self.id
    polyline.addTapListener(with: self)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    polyline.geometry = UtilsLite.polylineFromJson(params["polyline"] as! [String: Any])
    polyline.zIndex = (params["zIndex"] as! NSNumber).floatValue
    polyline.isVisible = (params["isVisible"] as! NSNumber).boolValue
    polyline.setStrokeColorWith(UtilsLite.uiColor(fromInt: (params["strokeColor"] as! NSNumber).int64Value))
    polyline.style = YMKLineStyle(
      strokeWidth: (params["strokeWidth"] as! NSNumber).floatValue,
      gradientLength: (params["gradientLength"] as! NSNumber).floatValue,
      outlineColor: UtilsLite.uiColor(fromInt: (params["outlineColor"] as! NSNumber).int64Value),
      outlineWidth: (params["outlineWidth"] as! NSNumber).floatValue,
      innerOutlineEnabled: (params["isInnerOutlineEnabled"] as! NSNumber).boolValue,
      turnRadius: (params["turnRadius"] as! NSNumber).floatValue,
      arcApproximationStep: (params["arcApproximationStep"] as! NSNumber).floatValue,
      dashLength: (params["dashLength"] as! NSNumber).floatValue,
      gapLength: (params["gapLength"] as! NSNumber).floatValue,
      dashOffset: (params["dashOffset"] as! NSNumber).floatValue
    )

    consumeTapEvents = (params["consumeTapEvents"] as! NSNumber).boolValue
  }

  public func remove() {
    polyline.parent.remove(with: polyline)
  }

  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    controller!.mapObjectTap(id: id, point: point)

    return consumeTapEvents
  }
}
