import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexMapController: NSObject, FlutterPlatformView, YMKUserLocationObjectListener {
  public let methodChannel: FlutterMethodChannel!
  public let pluginRegistrar: FlutterPluginRegistrar!
  private let mapTapListener: MapTapListener!
  private var mapCameraListener: MapCameraListener!
  private let mapSizeChangedListener: MapSizeChangedListener!
  private let userLocationLayer: YMKUserLocationLayer!
  private var placemarks: [YMKPlacemarkMapObject] = []
  private var polylines: [YMKPolylineMapObject] = []
  private var polygons: [YMKPolygonMapObject] = []
  private var circles: [YMKCircleMapObject] = []
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

  public required init(id: Int64, frame: CGRect, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.mapView = FLYMKMapView(frame: frame)
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_map_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.mapTapListener = MapTapListener(channel: methodChannel)
    self.mapSizeChangedListener = MapSizeChangedListener(channel: methodChannel)
    self.userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })

    self.mapView.mapWindow.map.addInputListener(with: mapTapListener)
    self.mapView.mapWindow.addSizeChangedListener(with: mapSizeChangedListener)
    userLocationLayer.setObjectListenerWith(self)
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
    case "toggleNightMode":
      toggleNightMode(call)
      result(nil)
    case "toggleMapRotation":
      toggleMapRotation(call)
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
    case "enableCameraTracking":
      enableCameraTracking()
      result(nil)
    case "disableCameraTracking":
      disableCameraTracking()
      result(nil)
    case "updateMapObjects":
      updateMapObjects(call)
      result(nil)
    case "zoomIn":
      zoomIn()
      result(nil)
    case "zoomOut":
      zoomOut()
      result(nil)
    case "isZoomGesturesEnabled":
      let enabled = isZoomGesturesEnabled()
      result(enabled)
    case "toggleZoomGestures":
      toggleZoomGestures(call)
      result(nil)
    case "getMinZoom":
      let minZoom = getMinZoom()
      result(minZoom)
    case "getMaxZoom":
      let maxZoom = getMaxZoom()
      result(maxZoom)
    case "getZoom":
      let zoom = getZoom()
      result(zoom)
    case "getTargetPoint":
      let targetPoint = getTargetPoint()
      result(targetPoint)
    case "getVisibleRegion":
      let region: [String: Any] = getVisibleRegion()
      result(region)
    case "getUserTargetPoint":
      let userTargetPoint = getUserTargetPoint()
      result(userTargetPoint)
    case "isTiltGesturesEnabled":
      let enabled = isTiltGesturesEnabled()
      result(enabled)
    case "toggleTiltGestures":
      toggleTiltGestures(call)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func toggleMapRotation(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    mapView.mapWindow.map.isRotateGesturesEnabled = (params["enabled"] as! NSNumber).boolValue
  }

  public func toggleNightMode(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    mapView.mapWindow.map.isNightModeEnabled = (params["enabled"] as! NSNumber).boolValue
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
      topLeft: YMKScreenPoint(x: topLeft["x"]!.floatValue, y: topLeft["y"]!.floatValue),
      bottomRight: YMKScreenPoint(x: bottomRight["x"]!.floatValue, y: bottomRight["y"]!.floatValue)
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

  public func isZoomGesturesEnabled() -> Bool {
    return mapView.mapWindow.map.isZoomGesturesEnabled
  }

  public func toggleZoomGestures(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let enabled = params["enabled"] as! Bool
    mapView.mapWindow.map.isZoomGesturesEnabled = enabled
  }

  public func getMinZoom() -> Float {
    return mapView.mapWindow.map.getMinZoom()
  }

  public func getMaxZoom() -> Float {
    return mapView.mapWindow.map.getMaxZoom()
  }

  public func getZoom() -> Float {
    return mapView.mapWindow.map.cameraPosition.zoom
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

  public func getTargetPoint() -> [String: Any] {
    let targetPoint = mapView.mapWindow.map.cameraPosition.target;
    let arguments: [String: Any] = [
      "point": [
        "latitude": targetPoint.latitude,
        "longitude": targetPoint.longitude
      ]
    ]

    return arguments
  }

  public func getUserTargetPoint() -> [String: Any]? {
    if (!hasLocationPermission()) { return nil }

    if let targetPoint = userLocationLayer?.cameraPosition()?.target {
      let arguments: [String: Any] = [
        "point": [
          "latitude": targetPoint.latitude,
          "longitude": targetPoint.longitude
        ]
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

  public func updateMapObjects(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let toChangeParams = params["toChange"] as! [[String: Any]]

    if let rootChangeParams = toChangeParams.first(where: { $0["id"] as! String == rootController.id }) {
      rootController.update(rootChangeParams)
    }
  }

  public func disableCameraTracking() {
    if mapCameraListener != nil {
      mapView.mapWindow.map.removeCameraListener(with: mapCameraListener)
      mapCameraListener = nil
    }
  }

  public func enableCameraTracking() {
    if mapCameraListener == nil {
      mapCameraListener = MapCameraListener(controller: self, channel: methodChannel)
      mapView.mapWindow.map.addCameraListener(with: mapCameraListener)
    }
  }

  public func isTiltGesturesEnabled() -> Bool {
    return mapView.mapWindow.map.isTiltGesturesEnabled
  }

  public func toggleTiltGestures(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let enabled = params["enabled"] as! Bool

    mapView.mapWindow.map.isTiltGesturesEnabled = enabled
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

  internal class MapTapListener: NSObject, YMKMapInputListener {
    private let methodChannel: FlutterMethodChannel!

    public required init(channel: FlutterMethodChannel) {
      self.methodChannel = channel
    }

    func onMapTap(with map: YMKMap, point: YMKPoint) {
      let arguments: [String: Any?] = [
        "point": Utils.pointToJson(point)
      ]
      methodChannel.invokeMethod("onMapTap", arguments: arguments)
    }

    func onMapLongTap(with map: YMKMap, point: YMKPoint) {
      let arguments: [String: Any?] = [
        "point": Utils.pointToJson(point)
      ]
      methodChannel.invokeMethod("onMapLongTap", arguments: arguments)
    }
  }

  internal class MapCameraListener: NSObject, YMKMapCameraListener {
    unowned private var yandexMapController: YandexMapController
    private let methodChannel: FlutterMethodChannel!

    public required init(controller: YandexMapController, channel: FlutterMethodChannel) {
      self.yandexMapController = controller
      self.methodChannel = channel
      super.init()
    }

    internal func onCameraPositionChanged(
      with map: YMKMap,
      cameraPosition: YMKCameraPosition,
      cameraUpdateReason: YMKCameraUpdateReason,
      finished: Bool
    ) {
      let arguments: [String: Any?] = [
        "cameraPosition": [
          "target": Utils.pointToJson(cameraPosition.target),
          "zoom": cameraPosition.zoom,
          "tilt": cameraPosition.tilt,
          "azimuth": cameraPosition.azimuth,
        ],
        "finished": finished
      ]
      methodChannel.invokeMethod("onCameraPositionChanged", arguments: arguments)
    }
  }

  internal class MapSizeChangedListener: NSObject, YMKMapSizeChangedListener {
    private let methodChannel: FlutterMethodChannel!

    public required init(channel: FlutterMethodChannel) {
      self.methodChannel = channel
    }

    func onMapWindowSizeChanged(with mapWindow: YMKMapWindow, newWidth: Int, newHeight: Int) {
      let arguments: [String: Any?] = [
        "mapSize": [
            "width": newWidth,
            "height": newHeight
          ]
        ]

      methodChannel.invokeMethod("onMapSizeChanged", arguments: arguments)
    }
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
