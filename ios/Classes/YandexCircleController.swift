import YandexMapsMobile

class YandexCircleController: NSObject, YandexMapObjectController {
  private let circle: YMKCircleMapObject
  private let tapListener: YandexMapObjectTapListener
  private unowned var controller: YandexMapController
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    let style = params["style"] as! [String: Any]
    let circle = parent.addCircle(
      with: Utils.circleFromJson(params),
      stroke: Utils.uiColor(fromInt: (style["strokeColor"] as! NSNumber).int64Value),
      strokeWidth: (style["strokeWidth"] as! NSNumber).floatValue,
      fill: Utils.uiColor(fromInt: (style["fillColor"] as! NSNumber).int64Value)
    )

    self.circle = circle
    self.id = params["id"] as! String
    self.controller = controller
    self.tapListener = YandexMapObjectTapListener(id: id, controller: controller)

    super.init()

    circle.addTapListener(with: tapListener)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    let style = params["style"] as! [String: Any]

    circle.strokeColor = Utils.uiColor(fromInt: (style["strokeColor"] as! NSNumber).int64Value)
    circle.strokeWidth = (style["strokeWidth"] as! NSNumber).floatValue
    circle.fillColor = Utils.uiColor(fromInt: (style["fillColor"] as! NSNumber).int64Value)
    circle.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    circle.zIndex = (params["zIndex"] as! NSNumber).floatValue
    circle.geometry = Utils.circleFromJson(params)
  }

  public func remove() {
    circle.parent.remove(with: circle)
  }
}
