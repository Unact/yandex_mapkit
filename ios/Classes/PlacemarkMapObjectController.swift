import YandexMapsMobile

class PlacemarkMapObjectController:
  NSObject,
  MapObjectController,
  YMKMapObjectTapListener,
  YMKMapObjectDragListener
{
  private let internallyControlled: Bool
  public let placemark: YMKPlacemarkMapObject
  private var consumeTapEvents: Bool = false
  public weak var controller: YandexMapController?
  public let id: String

  public required init(
    parent: YMKBaseMapObjectCollection,
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

    self.placemark = placemark!
    self.id = params["id"] as! String
    self.controller = controller
    self.internallyControlled = false

    super.init()

    placemark!.userData = self.id
    placemark!.addTapListener(with: self)
    placemark!.setDragListenerWith(self)
    update(params)
  }

  public required init(
    placemark: YMKPlacemarkMapObject,
    params: [String: Any],
    controller: YandexMapController
  ) {
    self.placemark = placemark
    self.id = params["id"] as! String
    self.controller = controller
    self.internallyControlled = true

    super.init()

    placemark.userData = self.id
    placemark.addTapListener(with: self)
    placemark.setDragListenerWith(self)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    if (!internallyControlled) {
      placemark.geometry = Utils.pointFromJson(params["point"] as! [String: NSNumber])
      placemark.isVisible = (params["isVisible"] as! NSNumber).boolValue
    }

    placemark.zIndex = (params["zIndex"] as! NSNumber).floatValue
    placemark.isDraggable = (params["isDraggable"] as! NSNumber).boolValue
    placemark.opacity = (params["opacity"] as! NSNumber).floatValue
    placemark.direction = (params["direction"] as! NSNumber).floatValue 

    setIcon(params["icon"] as? [String: Any])

    consumeTapEvents = (params["consumeTapEvents"] as! NSNumber).boolValue
  }

  public func remove() {
    if (internallyControlled) {
      return
    }

    placemark.parent.remove(with: placemark)
  }

  func onMapObjectDragStart(with mapObject: YMKMapObject) {
    controller!.mapObjectDragStart(id: id)
  }

  func onMapObjectDrag(with mapObject: YMKMapObject, point: YMKPoint) {
    controller!.mapObjectDrag(id: id, point: point)
  }

  func onMapObjectDragEnd(with mapObject: YMKMapObject) {
    controller!.mapObjectDragEnd(id: id)
  }

  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    controller!.mapObjectTap(id: id, point: point)

    return consumeTapEvents
  }

  private func setIcon(_ icon: [String: Any]?) {
    if (icon == nil) {
      return
    }

    let iconType = icon!["type"] as! String

    if (iconType == "single") {
      let style = icon!["style"] as! [String: Any]
      let image = style["image"] as! [String: Any]

      placemark.setIconWith(getIconImage(image), style: getIconStyle(style))
    }

    if (iconType == "composite") {
      let compositeIcon = placemark.useCompositeIcon()
      let iconParts = icon!["iconParts"] as! [[String: Any]]

      for iconPart in iconParts {
        let style = iconPart["style"] as! [String: Any]
        let image = style["image"] as! [String: Any]
        let name = iconPart["name"] as! String

        compositeIcon.setIconWithName(name, image: getIconImage(image), style: getIconStyle(style))
      }
    }
  }

  private func getIconImage(_ image: [String: Any]) -> UIImage {
    let type = image["type"] as! String
    let defaultImage = UIImage()

    if (type == "fromAssetImage") {
      let assetName = controller!.pluginRegistrar.lookupKey(forAsset: image["assetName"] as! String)

      return UIImage(named: assetName) ?? defaultImage
    }

    if (type == "fromBytes") {
      let imageData = (image["rawImageData"] as! FlutterStandardTypedData).data

      return UIImage(data: imageData) ?? defaultImage
    }

    return defaultImage
  }

  private func getIconStyle(_ style: [String: Any]) -> YMKIconStyle {
    let iconStyle = YMKIconStyle()

    if let tappableArea = style["tappableArea"] as? [String: Any] {
      iconStyle.tappableArea = Utils.rectFromJson(tappableArea)
    }

    iconStyle.anchor = NSValue(cgPoint: Utils.rectPointFromJson(style["anchor"] as! [String: NSNumber]))
    iconStyle.zIndex = (style["zIndex"] as! NSNumber)
    iconStyle.scale = (style["scale"] as! NSNumber)
    iconStyle.visible = (style["isVisible"] as! NSNumber)
    iconStyle.flat = (style["isFlat"] as! NSNumber)
    iconStyle.rotationType = YMKRotationType.init(
      rawValue: (style["rotationType"] as! NSNumber).uintValue
    )!.rawValue as NSNumber

    return iconStyle
  }
}
