import YandexMapsMobile

class YandexPlacemarkController: NSObject, YandexMapObjectController {
  private let internallyControlled: Bool
  private let parent: YMKMapObject // Workaround https://github.com/yandex/mapkit-ios-demo/issues/100
  public let placemark: YMKPlacemarkMapObject
  private let tapListener: YandexMapObjectTapListener
  private unowned var controller: YandexMapController
  public let id: String

  public required init(
    parent: YMKMapObject,
    params: [String: Any],
    controller: YandexMapController
  ) {
    var placemark: YMKPlacemarkMapObject? = nil
    let point = Utils.pointFromJson(params["point"] as! [String: NSNumber])

    if (parent is YMKClusterizedPlacemarkCollection) {
      placemark = (parent as! YMKClusterizedPlacemarkCollection).addPlacemark(with: point)
    }

    if (parent is YMKMapObjectCollection) {
      placemark = (parent as! YMKMapObjectCollection).addPlacemark(with: point)
    }

    self.parent = parent
    self.placemark = placemark!
    self.id = params["id"] as! String
    self.controller = controller
    self.tapListener = YandexMapObjectTapListener(id: id, controller: controller)
    self.internallyControlled = false

    super.init()

    placemark!.userData = self.id
    placemark!.addTapListener(with: tapListener)
    update(params)
  }

  public required init(
    parent: YMKMapObject,
    placemark: YMKPlacemarkMapObject,
    params: [String: Any],
    controller: YandexMapController
  ) {
    self.parent = parent
    self.placemark = placemark
    self.id = params["id"] as! String
    self.controller = controller
    self.tapListener = YandexMapObjectTapListener(id: id, controller: controller)
    self.internallyControlled = true

    super.init()

    placemark.userData = self.id
    placemark.addTapListener(with: tapListener)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    let paramsPoint = params["point"] as! [String: NSNumber]
    let style = params["style"] as! [String: Any]

    let iconName = style["iconName"] as? String
    let rawImageData = style["rawImageData"] as? FlutterStandardTypedData
    let iconAnchor = style["iconAnchor"] as! [String: NSNumber]
    var image = nil as UIImage?

    placemark.opacity = (style["opacity"] as! NSNumber).floatValue
    placemark.direction = (style["direction"] as! NSNumber).floatValue

    if iconName != nil {
      image = UIImage(named: controller.pluginRegistrar.lookupKey(forAsset: iconName!))!
    }

    if rawImageData != nil {
      image = UIImage(data: rawImageData!.data)
    }

    if image != nil {
      let iconStyle = YMKIconStyle()
      let rotationType = (style["rotationType"] as! NSNumber).intValue
      if (rotationType == YMKRotationType.rotate.rawValue) {
        iconStyle.rotationType = (YMKRotationType.rotate.rawValue as NSNumber)
      }
      iconStyle.anchor = NSValue(cgPoint: CGPoint(x: iconAnchor["dx"]!.doubleValue, y: iconAnchor["dy"]!.doubleValue))
      iconStyle.scale = (style["scale"] as! NSNumber)
      placemark.setIconWith(image!)
      placemark.setIconStyleWith(iconStyle)
    }

    placemark.isDraggable = (params["isDraggable"] as! NSNumber).boolValue
    placemark.zIndex = (params["zIndex"] as! NSNumber).floatValue
    placemark.geometry = Utils.pointFromJson(paramsPoint)
  }

  public func remove() {
    if (internallyControlled) {
      return
    }

    if (parent is YMKClusterizedPlacemarkCollection) {
      (parent as! YMKClusterizedPlacemarkCollection).remove(withPlacemark: placemark)
    }

    if (parent is YMKMapObjectCollection) {
      (parent as! YMKMapObjectCollection).remove(with: placemark)
    }
  }
}
