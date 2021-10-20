import YandexMapsMobile

class YandexPolygonController: NSObject, YandexMapObjectController {
  private let pluginRegistrar: FlutterPluginRegistrar
  private let methodChannel: FlutterMethodChannel
  private let polygon: YMKPolygonMapObject
  private let parent: YMKMapObjectCollection
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    pluginRegistrar: FlutterPluginRegistrar,
    methodChannel: FlutterMethodChannel
  ) {
    let polygon = parent.addPolygon(with: Utils.polygonFromJson(params))

    self.polygon = polygon
    self.id = params["id"] as! String
    self.parent = parent
    self.pluginRegistrar = pluginRegistrar
    self.methodChannel = methodChannel

    super.init()

    polygon.addTapListener(with: YandexMapObjectTapListener(id: id, methodChannel: methodChannel))
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
  }

  public func remove(_ params: [String: Any]) {
    parent.remove(with: polygon)
  }
}
