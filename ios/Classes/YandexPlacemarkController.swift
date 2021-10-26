import YandexMapsMobile

class YandexPlacemarkController: NSObject, YandexMapObjectController {
  private let placemark: YMKPlacemarkMapObject
  private let tapListener: YandexMapObjectTapListener
  private unowned var controller: YandexMapController
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    let placemark = parent.addPlacemark(with: Utils.pointFromJson(params["point"] as! [String: NSNumber]))

    self.placemark = placemark
    self.id = params["id"] as! String
    self.controller = controller
    self.tapListener = YandexMapObjectTapListener(id: id, controller: controller)

    super.init()

    placemark.addTapListener(with: tapListener)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    let paramsPoint = params["point"] as! [String: NSNumber]
    let style = params["style"] as! [String: Any]

    let iconName = style["iconName"] as? String
    let iconAnchor = style["iconAnchor"] as! [String: NSNumber]

    placemark.opacity = (style["opacity"] as! NSNumber).floatValue
    placemark.direction = (style["direction"] as! NSNumber).floatValue

    if (iconName != nil) {
      placemark.setIconWith(UIImage(named: controller.pluginRegistrar.lookupKey(forAsset: iconName!))!)
    }

    if let rawImageData = style["rawImageData"] as? FlutterStandardTypedData {
      placemark.setIconWith(UIImage(data: rawImageData.data)!)
    }

    let iconStyle = YMKIconStyle()
    let rotationType = (style["rotationType"] as! NSNumber).intValue
    if (rotationType == YMKRotationType.rotate.rawValue) {
      iconStyle.rotationType = (YMKRotationType.rotate.rawValue as NSNumber)
    }
    iconStyle.anchor = NSValue(cgPoint: CGPoint(x: iconAnchor["dx"]!.doubleValue, y: iconAnchor["dy"]!.doubleValue))
    iconStyle.scale = (style["scale"] as! NSNumber)

    placemark.setIconStyleWith(iconStyle)
    placemark.isDraggable = (params["isDraggable"] as! NSNumber).boolValue
    placemark.zIndex = (params["zIndex"] as! NSNumber).floatValue
    placemark.geometry = Utils.pointFromJson(paramsPoint)
  }

  public func remove() {
    placemark.parent.remove(with: placemark)
  }
}
