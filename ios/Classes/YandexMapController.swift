import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexMapController:
  NSObject,
  FlutterPlatformView,
  YMKUserLocationObjectListener,
  YMKMapSizeChangedListener,
  YMKMapInputListener,
  YMKMapCameraListener
{
  public let methodChannel: FlutterMethodChannel!
  public let pluginRegistrar: FlutterPluginRegistrar!
  private let userLocationLayer: YMKUserLocationLayer!
  private var mapObjectCollections: [YMKMapObjectCollection] = []
  private var userPinController: YandexPlacemarkController?
  private var userArrowController: YandexPlacemarkController?
  private var userAccuracyCircleController: YandexCircleController?
  private lazy var rootController: YandexMapObjectCollectionController = {
    YandexMapObjectCollectionController.init(
      root: mapView.mapWindow.map.mapObjects,
      id: "root_map_object_collection",
      controller: self
    )
  }()
  private let mapView: FLYMKMapView

  public required init(id: Int64, frame: CGRect, registrar: FlutterPluginRegistrar, params: [String: Any]) {
    self.pluginRegistrar = registrar
    self.mapView = FLYMKMapView(frame: frame)
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_map_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })

    mapView.mapWindow.map.addInputListener(with: self)
    mapView.mapWindow.map.addCameraListener(with: self)
    mapView.mapWindow.addSizeChangedListener(with: self)
    userLocationLayer.setObjectListenerWith(self)

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
    case "logoAlignment":
      logoAlignment(call)
      result(nil)
    case "toggleUserLayer":
      toggleUserLayer(call)
      result(nil)
    case "setMapStyle":
      setMapStyle(call)
      result(nil)
    case "move":
      move(call)
      result(nil)
    case "setBounds":
      setBounds(call)
      result(nil)
    case "setFocusRect":
      setFocusRect(call)
      result(nil)
    case "clearFocusRect":
      clearFocusRect()
      result(nil)
    case "updateMapObjects":
      updateMapObjects(call)
      result(nil)
    case "updateMapOptions":
      updateMapOptions(call)
      result(nil)
    case "zoomIn":
      zoomIn()
      result(nil)
    case "zoomOut":
      zoomOut()
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

    default:
      result(FlutterMethodNotImplemented)
    }
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
  }

  public func setFocusRect(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let topLeft = params["topLeft"] as! [String: NSNumber]
    let bottomRight = params["bottomRight"] as! [String: NSNumber]
    let screenRect = YMKScreenRect(
      topLeft: Utils.screenPointFromJson(topLeft),
      bottomRight: Utils.screenPointFromJson(bottomRight)
    )

    mapView.mapWindow.focusRect = screenRect
    mapView.mapWindow.pointOfView = YMKPointOfView.adaptToFocusRectHorizontally
  }

  public func clearFocusRect() {
    mapView.mapWindow.focusRect = nil
    mapView.mapWindow.pointOfView = YMKPointOfView.screenCenter
  }

  public func logoAlignment(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let logoPosition = YMKLogoAlignment(
      horizontalAlignment: YMKLogoHorizontalAlignment(rawValue: params["horizontal"] as! UInt)!,
      verticalAlignment: YMKLogoVerticalAlignment(rawValue: params["vertical"] as! UInt)!
    )
    mapView.mapWindow.map.logo.setAlignmentWith(logoPosition)
  }

  public func setMapStyle(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let map = mapView.mapWindow.map
    map.setMapStyleWithStyle(params["style"] as! String)
  }

  public func zoomIn() {
    zoom(1)
  }

  public func zoomOut() {
    zoom(-1)
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

  public func move(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsAnimation = params["animation"] as? [String: Any]
    let paramsCameraPosition = params["cameraPosition"] as! [String: Any]
    let paramsTarget = paramsCameraPosition["target"] as! [String: NSNumber]
    let cameraPosition = YMKCameraPosition(
      target: Utils.pointFromJson(paramsTarget),
      zoom: (paramsCameraPosition["zoom"] as! NSNumber).floatValue,
      azimuth: (paramsCameraPosition["azimuth"] as! NSNumber).floatValue,
      tilt: (paramsCameraPosition["tilt"] as! NSNumber).floatValue
    )

    moveWithParams(paramsAnimation, cameraPosition)
  }

  public func setBounds(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsAnimation = params["animation"] as? [String: Any]
    let paramsBoundingBox = params["boundingBox"] as! [String: Any]
    let southWest = paramsBoundingBox["southWest"] as! [String: NSNumber]
    let northEast = paramsBoundingBox["northEast"] as! [String: NSNumber]
    let cameraPosition = mapView.mapWindow.map.cameraPosition(with: YMKBoundingBox(
        southWest: Utils.pointFromJson(southWest),
        northEast: Utils.pointFromJson(northEast)
      )
    )

    moveWithParams(paramsAnimation, cameraPosition)
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
    let region = mapView.mapWindow.map.visibleRegion
    let arguments = [
      "visibleRegion": [
        "bottomLeft": Utils.pointToJson(region.bottomLeft),
        "bottomRight": Utils.pointToJson(region.bottomRight),
        "topLeft": Utils.pointToJson(region.topLeft),
        "topRight": Utils.pointToJson(region.bottomLeft)
      ]
    ]

    return arguments
  }

  public func getFocusRegion() -> [String: Any] {
    let region = mapView.mapWindow.focusRegion
    let arguments = [
      "focusRegion": [
        "bottomLeft": Utils.pointToJson(region.bottomLeft),
        "bottomRight": Utils.pointToJson(region.bottomRight),
        "topLeft": Utils.pointToJson(region.topLeft),
        "topRight": Utils.pointToJson(region.bottomLeft)
      ]
    ]

    return arguments
  }

  public func updateMapObjects(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]

    applyMapObjects(params)
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

  private func moveWithParams(_ paramsAnimation: [String: Any]?, _ cameraPosition: YMKCameraPosition) {
    if paramsAnimation == nil {
      mapView.mapWindow.map.move(with: cameraPosition)
      return
    }

    let type = (paramsAnimation!["smooth"] as! NSNumber).boolValue ?
      YMKAnimationType.smooth :
      YMKAnimationType.linear
    let animationType = YMKAnimation(
      type: type,
      duration: (paramsAnimation!["duration"] as! NSNumber).floatValue
    )

    mapView.mapWindow.map.move(with: cameraPosition, animationType: animationType)
  }

  private func zoom(_ step: Float) {
    let point = mapView.mapWindow.map.cameraPosition.target
    let zoom = mapView.mapWindow.map.cameraPosition.zoom
    let azimuth = mapView.mapWindow.map.cameraPosition.azimuth
    let tilt = mapView.mapWindow.map.cameraPosition.tilt
    let currentPosition = YMKCameraPosition(
      target: point,
      zoom: zoom + step,
      azimuth: azimuth,
      tilt: tilt
    )
    mapView.mapWindow.map.move(
      with: currentPosition,
      animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1),
      cameraCallback: nil
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

    if let indoorEnabled = params["indoorEnabled"] as? NSNumber {
      map.isIndoorEnabled = indoorEnabled.boolValue
    }

    if let liteModeEnabled = params["liteModeEnabled"] as? NSNumber {
      map.isLiteModeEnabled = liteModeEnabled.boolValue
    }

    if let modelsEnabled = params["modelsEnabled"] as? NSNumber {
      map.isModelsEnabled = modelsEnabled.boolValue
    }
  }

  public func applyMapObjects(_ params: [String: Any]) {
    let toChangeParams = params["toChange"] as! [[String: Any]]

    if let rootChangeParams = toChangeParams.first(where: { $0["id"] as! String == rootController.id }) {
      rootController.update(rootChangeParams)
    }
  }

  public func onObjectAdded(with view: YMKUserLocationView) {
    let arguments = [
      "pinPoint": Utils.pointToJson(view.pin.geometry),
      "arrowPoint": Utils.pointToJson(view.arrow.geometry),
      "circle": Utils.circleToJson(view.accuracyCircle.geometry)
    ]

    methodChannel.invokeMethod("onUserLocationAdded", arguments: arguments) { result in
      let params = result as! [String: Any]

      if (!view.isValid) {
        return
      }

      self.userPinController = YandexPlacemarkController(
        parent: view.pin.parent,
        placemark: view.pin,
        params: params["pin"] as! [String: Any],
        controller: self
      )

      self.userArrowController = YandexPlacemarkController(
        parent: view.arrow.parent,
        placemark: view.arrow,
        params: params["arrow"] as! [String: Any],
        controller: self
      )

      self.userAccuracyCircleController = YandexCircleController(
        circle: view.accuracyCircle,
        params: params["accuracyCircle"] as! [String: Any],
        controller: self
      )
    }
  }

  public func onObjectRemoved(with view: YMKUserLocationView) {}

  public func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}

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

  public func onMapWindowSizeChanged(with mapWindow: YMKMapWindow, newWidth: Int, newHeight: Int) {
    let arguments: [String: Any?] = [
      "mapSize": [
          "width": newWidth,
          "height": newHeight
        ]
      ]

    methodChannel.invokeMethod("onMapSizeChanged", arguments: arguments)
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
