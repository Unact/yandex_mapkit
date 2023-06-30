import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexMapController:
  NSObject,
  FlutterPlatformView,
  YMKUserLocationObjectListener,
  YMKTrafficDelegate,
  YMKMapInputListener,
  YMKMapCameraListener,
  YMKLayersGeoObjectTapListener
{
  public let methodChannel: FlutterMethodChannel!
  public let pluginRegistrar: FlutterPluginRegistrar!
  private let userLocationLayer: YMKUserLocationLayer!
  private let trafficLayer: YMKTrafficLayer!
  private var mapObjectCollections: [YMKMapObjectCollection] = []
  private var userPinController: PlacemarkMapObjectController?
  private var userArrowController: PlacemarkMapObjectController?
  private var userAccuracyCircleController: CircleMapObjectController?
  private lazy var rootController: MapObjectCollectionController = {
    MapObjectCollectionController.init(
      root: mapView.mapWindow.map.mapObjects,
      id: "root_map_object_collection",
      controller: self
    )
  }()
  private let mapView: FLYMKMapView

  public required init(id: Int64, frame: CGRect, registrar: FlutterPluginRegistrar, params: [String: Any]) {
    self.pluginRegistrar = registrar
    self.mapView = FLYMKMapView(frame: frame, vulkanPreferred: YandexMapController.isM1Simulator())
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_map_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
    self.trafficLayer = YMKMapKit.sharedInstance().createTrafficLayer(with: mapView.mapWindow)

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })

    mapView.mapWindow.map.addTapListener(with: self)
    mapView.mapWindow.map.addInputListener(with: self)
    mapView.mapWindow.map.addCameraListener(with: self)

    userLocationLayer.setObjectListenerWith(self)
    trafficLayer.addTrafficListener(withTrafficListener: self)

    applyMapOptions(params["mapOptions"] as! [String: Any])
    applyMapObjects(params["mapObjects"] as! [String: Any])
  }

  public func view() -> UIView {
    return self.mapView
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "waitForInit":
      if (mapView.frame.isEmpty) {
        mapView.initResult = result
      } else {
        result(nil)
      }
    case "toggleUserLayer":
      toggleUserLayer(call)
      result(nil)
    case "toggleTrafficLayer":
      toggleTrafficLayer(call)
      result(nil)
    case "setMapStyle":
      result(setMapStyle(call))
    case "moveCamera":
      moveCamera(call, result)
    case "updateMapObjects":
      updateMapObjects(call)
      result(nil)
    case "updateMapOptions":
      updateMapOptions(call)
      result(nil)
    case "getMinZoom":
      let minZoom = getMinZoom()
      result(minZoom)
    case "getMaxZoom":
      let maxZoom = getMaxZoom()
      result(maxZoom)
    case "getPoint":
      result(getPoint(call))
    case "getScreenPoint":
      result(getScreenPoint(call))
    case "getCameraPosition":
      result(getCameraPosition())
    case "getVisibleRegion":
      result(getVisibleRegion())
    case "getFocusRegion":
      result(getFocusRegion())
    case "getUserCameraPosition":
      result(getUserCameraPosition())
    case "selectGeoObject":
      selectGeoObject(call)
      result(nil)
    case "deselectGeoObject":
      deselectGeoObject()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func updateMapObjects(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]

    applyMapObjects(params)
  }

  public func updateMapOptions(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]

    applyMapOptions(params)
  }

  public func toggleUserLayer(_ call: FlutterMethodCall) {
    if (!hasLocationPermission()) { return }

    let params = call.arguments as! [String: Any]
    userLocationLayer.setVisibleWithOn(params["visible"] as! Bool)
    userLocationLayer.isHeadingEnabled = params["headingEnabled"] as! Bool
    userLocationLayer.isAutoZoomEnabled = params["autoZoomEnabled"] as! Bool
    userLocationLayer.resetAnchor()

    if let anchor = params["anchor"] as? [String: Any] {
      userLocationLayer.setAnchorWithAnchorNormal(
        Utils.rectPointFromJson(anchor["normal"] as! [String: NSNumber]),
        anchorCourse: Utils.rectPointFromJson(anchor["course"] as! [String: NSNumber])
      )
    }
  }

  public func toggleTrafficLayer(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]

    trafficLayer.setTrafficVisibleWithOn(params["visible"] as! Bool)
  }

  public func setMapStyle(_ call: FlutterMethodCall) -> Bool {
    let params = call.arguments as! [String: Any]

    return mapView.mapWindow.map.setMapStyleWithStyle(params["style"] as! String)
  }

  public func selectGeoObject(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]

    mapView.mapWindow.map.selectGeoObject(
      withObjectId: params["objectId"] as! String,
      layerId: params["layerId"] as! String
    )
  }

  public func deselectGeoObject() {
    mapView.mapWindow.map.deselectGeoObject()
  }

  public func getMinZoom() -> Float {
    return mapView.mapWindow.map.getMinZoom()
  }

  public func getMaxZoom() -> Float {
    return mapView.mapWindow.map.getMaxZoom()
  }

  public func getScreenPoint(_ call: FlutterMethodCall) -> [String: Any]? {
    let params = call.arguments as! [String: NSNumber]

    if let screenPoint = mapView.mapWindow.worldToScreen(withWorldPoint: Utils.pointFromJson(params)) {
      return Utils.screenPointToJson(screenPoint)
    }

    return nil
  }

  public func getPoint(_ call: FlutterMethodCall) -> [String: Any]? {
    let params = call.arguments as! [String: NSNumber]

    if let point = mapView.mapWindow.screenToWorld(with: Utils.screenPointFromJson(params)) {
      return Utils.pointToJson(point)
    }

    return nil
  }

  public func moveCamera(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]

    if (mapView.frame.isEmpty) {
      result(false)

      return
    }

    move(
      cameraPosition: cameraUpdateToPosition(params["cameraUpdate"] as! [String: Any]),
      animationParams: params["animation"] as? [String: Any],
      result: result
    )
  }

  public func getCameraPosition() -> [String: Any] {
    let arguments: [String: Any] = [
      "cameraPosition": Utils.cameraPositionToJson(mapView.mapWindow.map.cameraPosition)
    ]

    return arguments
  }

  public func getUserCameraPosition() -> [String: Any]? {
    if (!hasLocationPermission()) { return nil }

    if let cameraPosition = userLocationLayer?.cameraPosition() {
      let arguments: [String: Any] = [
        "cameraPosition": Utils.cameraPositionToJson(cameraPosition)
      ]

      return arguments
    }

    return nil
  }

  public func getVisibleRegion() -> [String: Any] {
    let arguments = [
      "visibleRegion": Utils.visibleRegionToJson(mapView.mapWindow.map.visibleRegion)
    ]

    return arguments
  }

  public func getFocusRegion() -> [String: Any] {
    let arguments = [
      "focusRegion": Utils.visibleRegionToJson(mapView.mapWindow.focusRegion)
    ]

    return arguments
  }

  private static func isM1Simulator() -> Bool {
    return (TARGET_IPHONE_SIMULATOR & TARGET_CPU_ARM64) != 0
  }

  private func hasLocationPermission() -> Bool {
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .notDetermined, .restricted, .denied:
        return false
      case .authorizedAlways, .authorizedWhenInUse:
        return true
      default:
        return false
      }
    } else {
      return false
    }
  }

  private func cameraUpdateToPosition(_ cameraUpdate: [String: Any]) -> YMKCameraPosition {
    let cameraUpdateParams = cameraUpdate["params"] as? [String: Any]

    switch cameraUpdate["type"] as! String {
    case "newCameraPosition":
      return newCameraPosition(cameraUpdateParams!)
    case "newBounds":
      return newBounds(cameraUpdateParams!)
    case "newTiltAzimuthGeometry":
      return newTiltAzimuthGeometry(cameraUpdateParams!)
    case "zoomIn":
      return zoomIn()
    case "zoomOut":
      return zoomOut()
    case "zoomTo":
      return zoomTo(cameraUpdateParams!)
    case "azimuthTo":
      return azimuthTo(cameraUpdateParams!)
    case "tiltTo":
      return tiltTo(cameraUpdateParams!)
    default:
      return YMKCameraPosition()
    }
  }

  private func newCameraPosition(_ params: [String: Any]) -> YMKCameraPosition {
    let paramsCameraPosition = params["cameraPosition"] as! [String: Any]

    return YMKCameraPosition(
      target: Utils.pointFromJson(paramsCameraPosition["target"] as! [String: NSNumber]),
      zoom: (paramsCameraPosition["zoom"] as! NSNumber).floatValue,
      azimuth: (paramsCameraPosition["azimuth"] as! NSNumber).floatValue,
      tilt: (paramsCameraPosition["tilt"] as! NSNumber).floatValue
    )
  }

  private func newBounds(_ params: [String: Any]) -> YMKCameraPosition {
    if (params["focusRect"] as? [String: Any] != nil) {
      return mapView.mapWindow.map.cameraPosition(
        with: Utils.boundingBoxFromJson(params["boundingBox"] as! [String: Any]),
        focus: Utils.screenRectFromJson(params["focusRect"] as! [String: Any])
      )
    }

    return mapView.mapWindow.map.cameraPosition(
      with: Utils.boundingBoxFromJson(params["boundingBox"] as! [String: Any])
    )
  }

  private func newTiltAzimuthGeometry(_ params: [String: Any]) -> YMKCameraPosition {
    let focus = params["focusRect"] as? [String: Any] != nil ?
      Utils.screenRectFromJson(params["focusRect"] as! [String: Any]) :
      nil

    return mapView.mapWindow.map.cameraPosition(
      with: Utils.geometryFromJson(params["geometry"] as! [String: Any]),
      azimuth: (params["azimuth"] as! NSNumber),
      tilt: (params["tilt"] as! NSNumber),
      focus: focus
    )
  }

  private func zoomIn() -> YMKCameraPosition {
    let curPosition = mapView.mapWindow.map.cameraPosition

    return YMKCameraPosition(
      target: curPosition.target,
      zoom: curPosition.zoom + 1,
      azimuth: curPosition.azimuth,
      tilt: curPosition.tilt
    )
  }

  private func zoomOut() -> YMKCameraPosition {
    let curPosition = mapView.mapWindow.map.cameraPosition

    return YMKCameraPosition(
      target: curPosition.target,
      zoom: curPosition.zoom - 1,
      azimuth: curPosition.azimuth,
      tilt: curPosition.tilt
    )
  }

  private func zoomTo(_ params: [String: Any]) -> YMKCameraPosition {
    let curPosition = mapView.mapWindow.map.cameraPosition

    return YMKCameraPosition(
      target: curPosition.target,
      zoom: (params["zoom"] as! NSNumber).floatValue,
      azimuth: curPosition.azimuth,
      tilt: curPosition.tilt
    )
  }

  private func azimuthTo(_ params: [String: Any]) -> YMKCameraPosition {
    let curPosition = mapView.mapWindow.map.cameraPosition

    return YMKCameraPosition(
      target: curPosition.target,
      zoom: curPosition.zoom,
      azimuth: (params["azimuth"] as! NSNumber).floatValue,
      tilt: curPosition.tilt
    )
  }

  private func tiltTo(_ params: [String: Any]) -> YMKCameraPosition {
    let curPosition = mapView.mapWindow.map.cameraPosition

    return YMKCameraPosition(
      target: curPosition.target,
      zoom: curPosition.zoom,
      azimuth: curPosition.azimuth,
      tilt: (params["tilt"] as! NSNumber).floatValue
    )
  }

  private func move(
    cameraPosition: YMKCameraPosition,
    animationParams: [String: Any]?,
    result: @escaping FlutterResult
  ) {
    if animationParams == nil {
      mapView.mapWindow.map.move(with: cameraPosition)
      result(true)

      return
    }

    let animation = YMKAnimation(
      type: YMKAnimationType.init(rawValue: (animationParams!["type"] as! NSNumber).uintValue)!,
      duration: (animationParams!["duration"] as! NSNumber).floatValue
    )

    mapView.mapWindow.map.move(
      with: cameraPosition,
      animationType: animation,
      cameraCallback: { (completed: Bool) -> Void in result(completed) }
    )
  }

  public func applyMapOptions(_ params: [String: Any]) {
    let map = mapView.mapWindow.map

    if let tiltGesturesEnabled = params["tiltGesturesEnabled"] as? NSNumber {
      map.isTiltGesturesEnabled = tiltGesturesEnabled.boolValue
    }

    if let zoomGesturesEnabled = params["zoomGesturesEnabled"] as? NSNumber {
      map.isZoomGesturesEnabled = zoomGesturesEnabled.boolValue
    }

    if let rotateGesturesEnabled = params["rotateGesturesEnabled"] as? NSNumber {
      map.isRotateGesturesEnabled = rotateGesturesEnabled.boolValue
    }

    if let nightModeEnabled = params["nightModeEnabled"] as? NSNumber {
      map.isNightModeEnabled = nightModeEnabled.boolValue
    }

    if let scrollGesturesEnabled = params["scrollGesturesEnabled"] as? NSNumber {
      map.isScrollGesturesEnabled = scrollGesturesEnabled.boolValue
    }

    if let fastTapEnabled = params["fastTapEnabled"] as? NSNumber {
      map.isFastTapEnabled = fastTapEnabled.boolValue
    }

    if let mode2DEnabled = params["mode2DEnabled"] as? NSNumber {
      map.set2DMode(withEnable: mode2DEnabled.boolValue)
    }

    if let modelsEnabled = params["modelsEnabled"] as? NSNumber {
      map.isModelsEnabled = modelsEnabled.boolValue
    }

    if let logoAlignment = params["logoAlignment"] as? [String: Any] {
      applyAlignLogo(logoAlignment)
    }

    if params.keys.contains("focusRect") {
      applyFocusRect(params["focusRect"] as? [String: Any])
    }

    if let mapType = params["mapType"] as? NSNumber {
      map.mapType = YMKMapType.init(rawValue: mapType.uintValue)!
    }

    if params.keys.contains("poiLimit") {
      map.poiLimit = params["poiLimit"] as? NSNumber
    }
  }

  public func applyMapObjects(_ params: [String: Any]) {
    let toChangeParams = params["toChange"] as! [[String: Any]]

    if let rootChangeParams = toChangeParams.first(where: { $0["id"] as! String == rootController.id }) {
      rootController.update(rootChangeParams)
    }
  }

  private func applyAlignLogo(_ params: [String: Any]) {
    let logoPosition = YMKLogoAlignment(
      horizontalAlignment: YMKLogoHorizontalAlignment(rawValue: (params["horizontal"] as! NSNumber).uintValue)!,
      verticalAlignment: YMKLogoVerticalAlignment(rawValue: (params["vertical"] as! NSNumber).uintValue)!
    )
    mapView.mapWindow.map.logo.setAlignmentWith(logoPosition)
  }

  private func applyFocusRect(_ params: [String: Any]?) {
    if (params == nil) {
      mapView.mapWindow.focusRect = nil
      mapView.mapWindow.pointOfView = YMKPointOfView.screenCenter

      return
    }

    let focusRect = Utils.screenRectFromJson(params!)

    if (
      focusRect.topLeft.y < 0 ||
      focusRect.topLeft.x < 0 ||
      focusRect.bottomRight.y > Float(mapView.mapWindow.height()) ||
      focusRect.bottomRight.x > Float(mapView.mapWindow.width())
    ) {
      return
    }

    mapView.mapWindow.focusRect = focusRect
    mapView.mapWindow.pointOfView = YMKPointOfView.adaptToFocusPointHorizontally
  }

  public func onObjectAdded(with view: YMKUserLocationView) {
    let arguments = [
      "pinPoint": Utils.pointToJson(view.pin.geometry),
      "arrowPoint": Utils.pointToJson(view.arrow.geometry),
      "circle": Utils.circleToJson(view.accuracyCircle.geometry)
    ]

    methodChannel.invokeMethod("onUserLocationAdded", arguments: arguments) { result in
      if (result is FlutterError) {
        return
      }

      let params = result as! [String: Any]

      self.userPinController = PlacemarkMapObjectController(
        placemark: view.pin,
        params: params["pin"] as! [String: Any],
        controller: self
      )

      self.userArrowController = PlacemarkMapObjectController(
        placemark: view.arrow,
        params: params["arrow"] as! [String: Any],
        controller: self
      )

      self.userAccuracyCircleController = CircleMapObjectController(
        circle: view.accuracyCircle,
        params: params["accuracyCircle"] as! [String: Any],
        controller: self
      )
    }
  }

  public func onObjectRemoved(with view: YMKUserLocationView) {}

  public func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}

  public func onTrafficChanged(with trafficLevel: YMKTrafficLevel?) {
    let arguments: [String: Any?] = [
      "trafficLevel": trafficLevel == nil ? nil : [
        "level": trafficLevel!.level,
        "color": trafficLevel!.color.rawValue
      ]
    ]

    methodChannel.invokeMethod("onTrafficChanged", arguments: arguments)
  }

  public func onTrafficLoading() {}

  public func onTrafficExpired() {}

  public func onMapTap(with map: YMKMap, point: YMKPoint) {
    let arguments: [String: Any?] = [
      "point": Utils.pointToJson(point)
    ]
    methodChannel.invokeMethod("onMapTap", arguments: arguments)
  }

  public func onMapLongTap(with map: YMKMap, point: YMKPoint) {
    let arguments: [String: Any?] = [
      "point": Utils.pointToJson(point)
    ]
    methodChannel.invokeMethod("onMapLongTap", arguments: arguments)
  }

  public func onCameraPositionChanged(
    with map: YMKMap,
    cameraPosition: YMKCameraPosition,
    cameraUpdateReason: YMKCameraUpdateReason,
    finished: Bool
  ) {
    let arguments: [String: Any?] = [
      "cameraPosition": Utils.cameraPositionToJson(cameraPosition),
      "reason": cameraUpdateReason.rawValue,
      "finished": finished
    ]
    methodChannel.invokeMethod("onCameraPositionChanged", arguments: arguments)
  }

  public func onObjectTap(with event: YMKGeoObjectTapEvent) -> Bool {
    let geoObj = event.geoObject
    let meta = geoObj.metadataContainer.getItemOf(YMKGeoObjectSelectionMetadata.self) as? YMKGeoObjectSelectionMetadata

    let arguments: [String: Any?] = [
      "geoObject": [
        "name": geoObj.name,
        "descriptionText": geoObj.descriptionText,
        "geometry": geoObj.geometry.map({ Utils.geometryToJson($0) }),
        "boundingBox": geoObj.boundingBox != nil ? Utils.boundingBoxToJson(geoObj.boundingBox!) : nil,
        "selectionMetadata": meta == nil ? nil : [
          "id": meta!.id,
          "layerId": meta!.layerId
        ],
        "aref": geoObj.aref
      ]
    ]

    methodChannel.invokeMethod("onObjectTap", arguments: arguments)

    return false
  }

  internal func mapObjectTap(id: String, point: YMKPoint) {
    let arguments: [String: Any?] = [
      "id": id,
      "point": Utils.pointToJson(point)
    ]

    methodChannel.invokeMethod("onMapObjectTap", arguments: arguments)
  }

  internal func mapObjectDragStart(id: String) {
    let arguments: [String: Any?] = [
      "id": id
    ]

    methodChannel.invokeMethod("onMapObjectDragStart", arguments: arguments)
  }

  internal func mapObjectDrag(id: String, point: YMKPoint) {
    let arguments: [String: Any?] = [
      "id": id,
      "point": Utils.pointToJson(point)
    ]
    methodChannel.invokeMethod("onMapObjectDrag", arguments: arguments)
  }

  internal func mapObjectDragEnd(id: String) {
    let arguments: [String: Any?] = [
      "id": id
    ]

    methodChannel.invokeMethod("onMapObjectDragEnd", arguments: arguments)
  }

  // Fix https://github.com/flutter/flutter/issues/67514
  internal class FLYMKMapView: YMKMapView {
    public var initResult: FlutterResult?

    override var frame: CGRect {
      didSet {
        if initResult != nil {
          initResult!(nil)
          initResult = nil
        }
      }
    }
  }
}
