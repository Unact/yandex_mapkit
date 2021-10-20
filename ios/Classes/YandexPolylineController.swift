import YandexMapsMobile

class YandexPolylineController: NSObject, YandexMapObjectController {
  private let pluginRegistrar: FlutterPluginRegistrar
  private let methodChannel: FlutterMethodChannel
  private let polyline: YMKPolylineMapObject
  private let parent: YMKMapObjectCollection
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    pluginRegistrar: FlutterPluginRegistrar,
    methodChannel: FlutterMethodChannel
  ) {
    let polyline = parent.addPolyline(with: Utils.polylineFromJson(params))

    self.polyline = polyline
    self.id = params["id"] as! String
    self.parent = parent
    self.pluginRegistrar = pluginRegistrar
    self.methodChannel = methodChannel

    super.init()

    polyline.addTapListener(with: YandexMapObjectTapListener(id: id, methodChannel: methodChannel))
    update(params)
  }

  public func update(_ params: [String: Any]) {
    let style = params["style"] as! [String: Any]

    polyline.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    polyline.zIndex = (params["zIndex"] as! NSNumber).floatValue
    polyline.strokeColor = Utils.uiColor(fromInt: (style["strokeColor"] as! NSNumber).int64Value)
    polyline.outlineColor = Utils.uiColor(fromInt: (style["outlineColor"] as! NSNumber).int64Value)
    polyline.outlineWidth = (style["outlineWidth"] as! NSNumber).floatValue
    polyline.strokeWidth = (style["strokeWidth"] as! NSNumber).floatValue
    polyline.dashLength = (style["dashLength"] as! NSNumber).floatValue
    polyline.dashOffset = (style["dashOffset"] as! NSNumber).floatValue
    polyline.gapLength = (style["gapLength"] as! NSNumber).floatValue
    polyline.geometry = Utils.polylineFromJson(params)
  }

  public func remove(_ params: [String: Any]) {
    parent.remove(with: polyline)
  }
}
