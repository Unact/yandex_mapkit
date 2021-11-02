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

    applyPlacemarkStyle(placemark: placemark, params: style)

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
  
  private func applyPlacemarkStyle(placemark: YMKPlacemarkMapObject, params: [String: Any]) {
    
    placemark.opacity   = (params["opacity"] as! NSNumber).floatValue
    placemark.direction = (params["direction"] as! NSNumber).floatValue
    
    if let icon = params["icon"] as? [String: Any] {
      
      let img = getIconImage(icon)
      placemark.setIconWith(img)
      
      if let iconStyle = icon["style"] as? [String: Any] {
        let style = getIconStyle(iconStyle)
        placemark.setIconStyleWith(style)
      }
      
    } else if let composite = params["composite"] as? [Any] {
      
      for iconData in composite {
        
        guard let icon = iconData as? [String: Any] else {
          continue
        }
        
        let img = getIconImage(icon)
        let style = getIconStyle(icon["style"] as! [String: Any])
        
        placemark.useCompositeIcon().setIconWithName(
          icon["layerName"] as! String,
          image: img,
          style: style
        )
      }
    }
  }
  
  private func getIconImage(_ iconData: [String: Any]) -> UIImage {
   
    var img: UIImage
    
    if let iconName = iconData["iconName"] as? String {
      img = UIImage(named: controller.pluginRegistrar.lookupKey(forAsset: iconName))!
    } else {
      let rawImageData = iconData["rawImageData"] as! FlutterStandardTypedData
      img = UIImage(data: rawImageData.data)!
    }
    
    return img
  }
  
  private func getIconStyle(_ styleParams: [String: Any]) -> YMKIconStyle {
    
    let iconStyle = YMKIconStyle()

    let rotationType = (styleParams["rotationType"] as! NSNumber).intValue
    if (rotationType == YMKRotationType.rotate.rawValue) {
      iconStyle.rotationType = (YMKRotationType.rotate.rawValue as NSNumber)
    }
    
    let anchor = styleParams["anchor"] as! [String: Any]
    
    iconStyle.anchor = NSValue(cgPoint:
      CGPoint(
        x: (anchor["dx"] as! NSNumber).doubleValue,
        y: (anchor["dy"] as! NSNumber).doubleValue
      )
    )
    
    iconStyle.zIndex = (styleParams["zIndex"] as! NSNumber)
    iconStyle.scale = (styleParams["scale"] as! NSNumber)
    
    let tappableArea = styleParams["tappableArea"] as? [String: Any]
    
    if (tappableArea != nil) {
      
      let tappableAreaMin = tappableArea!["min"] as! [String: Any]
      let tappableAreaMax = tappableArea!["max"] as! [String: Any]
      
      iconStyle.tappableArea = YMKRect(
        min: CGPoint(
          x: (tappableAreaMin["x"] as! NSNumber).doubleValue,
          y: (tappableAreaMin["y"] as! NSNumber).doubleValue
        ),
        max: CGPoint(
          x: (tappableAreaMax["x"] as! NSNumber).doubleValue,
          y: (tappableAreaMax["y"] as! NSNumber).doubleValue
        )
      )
    }
    
    return iconStyle
  }
}
