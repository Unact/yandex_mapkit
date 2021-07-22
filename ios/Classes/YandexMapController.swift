import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexMapController: NSObject, FlutterPlatformView {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let mapTapListener: MapTapListener!
  private let mapObjectTapListener: MapObjectTapListener!
  private var mapCameraListener: MapCameraListener!
  private let mapSizeChangedListener: MapSizeChangedListener!
  private var userLocationObjectListener: UserLocationObjectListener?
  private var userLocationLayer: YMKUserLocationLayer?
  private var cameraTarget: YMKPlacemarkMapObject?
  private var placemarks: [YMKPlacemarkMapObject] = []
  private var polylines: [YMKPolylineMapObject] = []
  private var polygons: [YMKPolygonMapObject] = []
  private var circles: [YMKCircleMapObject] = []
  public let mapView: YMKMapView

  public required init(id: Int64, frame: CGRect, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.mapView = YMKMapView(frame: frame)
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_map_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.mapTapListener = MapTapListener(channel: methodChannel)
    self.mapObjectTapListener = MapObjectTapListener(channel: methodChannel)
    self.mapSizeChangedListener = MapSizeChangedListener(channel: methodChannel)
    self.userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)

    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })

    self.mapView.mapWindow.map.addInputListener(with: mapTapListener)
    self.mapView.mapWindow.addSizeChangedListener(with: mapSizeChangedListener)
  }

  public func view() -> UIView {
    return self.mapView
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "logoAlignment":
      logoAlignment(call)
      result(nil)
    case "toggleNightMode":
      toggleNightMode(call)
      result(nil)
    case "toggleMapRotation":
      toggleMapRotation(call)
      result(nil)
    case "showUserLayer":
      showUserLayer(call)
      result(nil)
    case "hideUserLayer":
      hideUserLayer()
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
      let target = enableCameraTracking(call)
      result(target)
    case "disableCameraTracking":
      disableCameraTracking()
      result(nil)
    case "addPlacemark":
      addPlacemark(call)
      result(nil)
    case "removePlacemark":
      removePlacemark(call)
      result(nil)
    case "addPolyline":
      addPolyline(call)
      result(nil)
    case "removePolyline":
      removePolyline(call)
      result(nil)
    case "addPolygon":
      addPolygon(call)
      result(nil)
    case "removePolygon":
      removePolygon(call)
      result(nil)
    case "addCircle":
      addCircle(call)
      result(nil)
      break;
    case "removeCircle":
      removeCircle(call)
      result(nil)
      break;
    case "zoomIn":
      zoomIn()
      result(nil)
    case "zoomOut":
      zoomOut()
      result(nil)
    case "isZoomGesturesEnabled":
      let isZoomGesturesEnabled = isZoomGesturesEnabled()
      result(isZoomGesturesEnabled)
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
      let isTiltGesturesEnabled = isTiltGesturesEnabled()
      result(isTiltGesturesEnabled)
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

  public func setFocusRect(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let topLeftScreenPoint = params["topLeftScreenPoint"] as? [String: Any]
    let bottomRightScreenPoint = params["bottomRightScreenPoint"] as? [String: Any]
    let screenRect = YMKScreenRect(
      topLeft: YMKScreenPoint(
        x: (topLeftScreenPoint!["x"]  as! NSNumber).floatValue,
        y: (topLeftScreenPoint!["y"]  as! NSNumber).floatValue
      ),
      bottomRight: YMKScreenPoint(
        x: (bottomRightScreenPoint!["x"]  as! NSNumber).floatValue,
        y: (bottomRightScreenPoint!["y"]  as! NSNumber).floatValue
      )
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
      horizontalAlignment: YMKLogoHorizontalAlignment(rawValue : params["x"] as! UInt)!,
      verticalAlignment: YMKLogoVerticalAlignment(rawValue : params["y"] as! UInt)!
    )
    mapView.mapWindow.map.logo.setAlignmentWith(logoPosition)
  }

  public func showUserLayer(_ call: FlutterMethodCall) {
    if (!hasLocationPermission()) { return }

    let params = call.arguments as! [String: Any]

    self.userLocationObjectListener = UserLocationObjectListener(
      pluginRegistrar: pluginRegistrar,
      iconName: params["iconName"] as! String,
      arrowName: params["arrowName"] as! String,
      userArrowOrientation: (params["userArrowOrientation"] as! NSNumber).boolValue,
      accuracyCircleFillColor: uiColor(
        fromInt: (params["accuracyCircleFillColor"] as! NSNumber).int64Value
      )
    )
    userLocationLayer?.setVisibleWithOn(true)
    userLocationLayer!.isHeadingEnabled = true
    userLocationLayer!.setObjectListenerWith(userLocationObjectListener!)
  }

  public func hideUserLayer() {
    if (!hasLocationPermission()) { return }

    userLocationLayer?.setVisibleWithOn(false)
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
    let paramsPoint = params["point"] as! [String: Any]
    let point = YMKPoint(
      latitude: (paramsPoint["latitude"] as! NSNumber).doubleValue,
      longitude: (paramsPoint["longitude"] as! NSNumber).doubleValue
    )
    let cameraPosition = YMKCameraPosition(
      target: point,
      zoom: (params["zoom"] as! NSNumber).floatValue,
      azimuth: (params["azimuth"] as! NSNumber).floatValue,
      tilt: (params["tilt"] as! NSNumber).floatValue
    )

    moveWithParams(params, cameraPosition)
  }

  public func setBounds(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsSouthWestPoint = params["southWestPoint"] as! [String: Any]
    let paramsNorthEastPoint = params["northEastPoint"] as! [String: Any]
    let cameraPosition = mapView.mapWindow.map.cameraPosition(with:
      YMKBoundingBox(
        southWest: YMKPoint(
          latitude: (paramsSouthWestPoint["latitude"] as! NSNumber).doubleValue,
          longitude: (paramsSouthWestPoint["longitude"] as! NSNumber).doubleValue
        ),
        northEast: YMKPoint(
          latitude: (paramsNorthEastPoint["latitude"] as! NSNumber).doubleValue,
          longitude: (paramsNorthEastPoint["longitude"] as! NSNumber).doubleValue
        )
      )
    )

    moveWithParams(params, cameraPosition)
  }

  public func getTargetPoint() -> [String: Any] {
    let targetPoint = mapView.mapWindow.map.cameraPosition.target;
    let arguments: [String: Any] = [
      "latitude": targetPoint.latitude,
      "longitude": targetPoint.longitude
    ]
    return arguments
  }

  public func getUserTargetPoint() -> [String: Any]? {
    if (!hasLocationPermission()) { return nil }

    if let targetPoint = userLocationLayer?.cameraPosition()?.target {
      let arguments: [String: Any] = [
        "latitude": targetPoint.latitude,
        "longitude": targetPoint.longitude
      ]

      return arguments
    }

    return nil
  }

  public func addPlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsPoint = params["point"] as! [String: Any]
    let paramsStyle = params["style"] as! [String: Any]
    let point = YMKPoint(
      latitude: (paramsPoint["latitude"] as! NSNumber).doubleValue,
      longitude: (paramsPoint["longitude"] as! NSNumber).doubleValue
    )
    let mapObjects = mapView.mapWindow.map.mapObjects
    let placemark = mapObjects.addPlacemark(with: point)
    let iconName = paramsStyle["iconName"] as? String

    placemark.addTapListener(with: mapObjectTapListener)
    placemark.userData = (params["hashCode"] as! NSNumber).intValue
    placemark.opacity = (paramsStyle["opacity"] as! NSNumber).floatValue
    placemark.isDraggable = (paramsStyle["isDraggable"] as! NSNumber).boolValue
    placemark.direction = (paramsStyle["direction"] as! NSNumber).floatValue

    if (iconName != nil) {
      placemark.setIconWith(UIImage(named: pluginRegistrar.lookupKey(forAsset: iconName!))!)
    }

    if let rawImageData = paramsStyle["rawImageData"] as? FlutterStandardTypedData,
      let image = UIImage(data: rawImageData.data) {
        placemark.setIconWith(image)
    }

    let iconStyle = YMKIconStyle()
    let rotationType = (paramsStyle["rotationType"] as! NSNumber).intValue
    if (rotationType == YMKRotationType.rotate.rawValue) {
      iconStyle.rotationType = (YMKRotationType.rotate.rawValue as NSNumber)
    }
    iconStyle.anchor = NSValue(cgPoint:
      CGPoint(
        x: (paramsStyle["anchorX"] as! NSNumber).doubleValue,
        y: (paramsStyle["anchorY"] as! NSNumber).doubleValue
      )
    )
    iconStyle.zIndex = (paramsStyle["zIndex"] as! NSNumber)
    iconStyle.scale = (paramsStyle["scale"] as! NSNumber)
    placemark.setIconStyleWith(iconStyle)

    placemarks.append(placemark)
  }

  public func getVisibleRegion() -> [String: Any] {
    let region = mapView.mapWindow.map.visibleRegion
    var arguments = [String: Any]()
    arguments["bottomLeftPoint"] = ["latitude": region.bottomLeft.latitude, "longitude": region.bottomLeft.longitude]
    arguments["bottomRightPoint"] = ["latitude": region.bottomRight.latitude, "longitude": region.bottomRight.longitude]
    arguments["topLeftPoint"] = ["latitude": region.topLeft.latitude, "longitude": region.topLeft.longitude]
    arguments["topRightPoint"] = ["latitude": region.topRight.latitude, "longitude": region.topRight.longitude]
    return arguments
  }

  public func removePlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let mapObjects = mapView.mapWindow.map.mapObjects
    let hashCode = (params["hashCode"] as! NSNumber).intValue
    let placemark = placemarks.first(where: { $0.userData as! Int == hashCode })

    if (placemark != nil) {
      mapObjects.remove(with: placemark!)
      placemarks.remove(at: placemarks.firstIndex(of: placemark!)!)
    }
  }

  public func disableCameraTracking() {
    if mapCameraListener != nil {
      mapView.mapWindow.map.removeCameraListener(with: mapCameraListener)
      mapCameraListener = nil

      if cameraTarget != nil {
        let mapObjects = mapView.mapWindow.map.mapObjects
        mapObjects.remove(with: cameraTarget!)
        cameraTarget = nil
      }
    }
  }

  public func enableCameraTracking(_ call: FlutterMethodCall) -> [String: Any] {
    if mapCameraListener == nil {
      mapCameraListener = MapCameraListener(controller: self, channel: methodChannel)
      mapView.mapWindow.map.addCameraListener(with: mapCameraListener)
    }

    if cameraTarget != nil {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: cameraTarget!)
      cameraTarget = nil
    }

    let targetPoint = mapView.mapWindow.map.cameraPosition.target;
    if call.arguments != nil {
      let params = call.arguments as! [String: Any]
      let paramsStyle = params["style"] as! [String: Any]

      let mapObjects = mapView.mapWindow.map.mapObjects
      cameraTarget = mapObjects.addPlacemark(with: targetPoint)

      let iconName = paramsStyle["iconName"] as? String

      cameraTarget!.addTapListener(with: mapObjectTapListener)
      cameraTarget!.opacity = (paramsStyle["opacity"] as! NSNumber).floatValue
      cameraTarget!.isDraggable = (paramsStyle["isDraggable"] as! NSNumber).boolValue

      if (iconName != nil) {
        cameraTarget!.setIconWith(UIImage(named: pluginRegistrar.lookupKey(forAsset: iconName!))!)
      }

      if let rawImageData = paramsStyle["rawImageData"] as? FlutterStandardTypedData,
        let image = UIImage(data: rawImageData.data) {
        cameraTarget!.setIconWith(image)
      }

      let iconStyle = YMKIconStyle()
      iconStyle.anchor = NSValue(cgPoint:
        CGPoint(
          x: (paramsStyle["anchorX"] as! NSNumber).doubleValue,
          y: (paramsStyle["anchorY"] as! NSNumber).doubleValue
        )
      )

      iconStyle.zIndex = (paramsStyle["zIndex"] as! NSNumber)
      iconStyle.scale = (paramsStyle["scale"] as! NSNumber)
      cameraTarget!.setIconStyleWith(iconStyle)
    }

    let arguments: [String: Any] = [
      "latitude": targetPoint.latitude,
      "longitude": targetPoint.longitude
    ]
    return arguments
  }

  private func addPolyline(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsCoordinates = params["coordinates"] as! [[String: Any]]
    let paramsStyle = params["style"] as! [String: Any]
    let coordinatesPrepared = paramsCoordinates.map {
      YMKPoint(
        latitude: ($0["latitude"] as! NSNumber).doubleValue,
        longitude: ($0["longitude"] as! NSNumber).doubleValue
      )
    }
    let mapObjects = mapView.mapWindow.map.mapObjects
    let polyline = YMKPolyline(points: coordinatesPrepared)
    let polylineMapObject = mapObjects.addPolyline(with: polyline)
    polylineMapObject.userData = (params["hashCode"] as! NSNumber).intValue
    polylineMapObject.strokeColor = uiColor(fromInt: (paramsStyle["strokeColor"] as! NSNumber).int64Value)
    polylineMapObject.outlineColor = uiColor(fromInt: (paramsStyle["outlineColor"] as! NSNumber).int64Value)
    polylineMapObject.outlineWidth = (paramsStyle["outlineWidth"] as! NSNumber).floatValue
    polylineMapObject.strokeWidth = (paramsStyle["strokeWidth"] as! NSNumber).floatValue
    polylineMapObject.isGeodesic = (paramsStyle["isGeodesic"] as! NSNumber).boolValue
    polylineMapObject.dashLength = (paramsStyle["dashLength"] as! NSNumber).floatValue
    polylineMapObject.dashOffset = (paramsStyle["dashOffset"] as! NSNumber).floatValue
    polylineMapObject.gapLength = (paramsStyle["gapLength"] as! NSNumber).floatValue

    polylines.append(polylineMapObject)
  }

  private func removePolyline(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let hashCode = (params["hashCode"] as! NSNumber).intValue

    if let polyline = polylines.first(where: { $0.userData as! Int ==  hashCode}) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: polyline)
      polylines.remove(at: polylines.firstIndex(of: polyline)!)
    }
  }

  public func addPolygon(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsOuterRingCoordinates = params["outerRingCoordinates"] as! [[String: Any]]
    let paramsInnerRingsCoordinates = params["innerRingsCoordinates"] as! [[[String: Any]]]
    let paramsStyle = params["style"] as! [String: Any]
    let outerRing = YMKLinearRing(points: paramsOuterRingCoordinates.map {
        YMKPoint(
          latitude: ($0["latitude"] as! NSNumber).doubleValue,
          longitude: ($0["longitude"] as! NSNumber).doubleValue
        )
      }
    )
    let innerRings = paramsInnerRingsCoordinates.map {
      YMKLinearRing(points: $0.map {
          YMKPoint(
            latitude: ($0["latitude"] as! NSNumber).doubleValue,
            longitude: ($0["longitude"] as! NSNumber).doubleValue
          )
        }
      )
    }
    let mapObjects = mapView.mapWindow.map.mapObjects
    let polylgon = YMKPolygon(outerRing: outerRing, innerRings: innerRings)
    let polygonMapObject = mapObjects.addPolygon(with: polylgon)

    polygonMapObject.userData = (params["hashCode"] as! NSNumber).intValue
    polygonMapObject.strokeColor = uiColor(fromInt: (paramsStyle["strokeColor"] as! NSNumber).int64Value)
    polygonMapObject.strokeWidth = (paramsStyle["strokeWidth"] as! NSNumber).floatValue
    polygonMapObject.isGeodesic = (paramsStyle["isGeodesic"] as! NSNumber).boolValue
    polygonMapObject.fillColor = uiColor(fromInt: (paramsStyle["fillColor"] as! NSNumber).int64Value)

    polygons.append(polygonMapObject)
  }

  public func removePolygon(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let hashCode = (params["hashCode"] as! NSNumber).intValue

    if let polygon = polygons.first(where: { $0.userData as! Int ==  hashCode}) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: polygon)
      polygons.remove(at: polygons.firstIndex(of: polygon)!)
    }
  }

  private func addCircle(_ call: FlutterMethodCall) {

    let params = call.arguments as! [String: Any]

    let paramsCenter = params["center"] as! [String: Any]
    let paramsRadius = params["radius"] as! NSNumber
    let paramsStyle = params["style"] as! [String: Any]

    let centerPrepared = YMKPoint(
      latitude: (paramsCenter["latitude"] as! NSNumber).doubleValue,
      longitude: (paramsCenter["longitude"] as! NSNumber).doubleValue
    )
  
    let radiusPrepared = paramsRadius.floatValue

    let mapObjects = mapView.mapWindow.map.mapObjects

    let circle = YMKCircle(center: centerPrepared, radius: radiusPrepared)
  
    let circleMapObject = mapObjects.addCircle(
      with: circle,
      stroke: uiColor(fromInt: (paramsStyle["strokeColor"] as! NSNumber).int64Value),
      strokeWidth: (paramsStyle["strokeWidth"] as! NSNumber).floatValue,
      fill: uiColor(fromInt: (paramsStyle["fillColor"] as! NSNumber).int64Value))

    circleMapObject.userData = (params["hashCode"] as! NSNumber).intValue
    circleMapObject.isGeodesic = (paramsStyle["isGeodesic"] as! NSNumber).boolValue
    
    circles.append(circleMapObject)
  }

  private func removeCircle(_ call: FlutterMethodCall) {
        
    let params = call.arguments as! [String: Any]
    let hashCode = (params["hashCode"] as! NSNumber).intValue

    if let circle = circles.first(where: { $0.userData as! Int == hashCode}) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: circle)
      circles.remove(at: circles.firstIndex(of: circle)!)
    }
  }

  private func moveWithParams(_ params: [String: Any], _ cameraPosition: YMKCameraPosition) {
    let paramsAnimation = params["animation"] as! [String: Any]

    if ((paramsAnimation["animate"] as! NSNumber).boolValue) {
      let type = (paramsAnimation["smoothAnimation"] as! NSNumber).boolValue ?
        YMKAnimationType.smooth :
        YMKAnimationType.linear
      let animationType = YMKAnimation(
        type: type,
        duration: (paramsAnimation["animationDuration"] as! NSNumber).floatValue
      )

      mapView.mapWindow.map.move(with: cameraPosition, animationType: animationType)
    } else {
      mapView.mapWindow.map.move(with: cameraPosition)
    }
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

  private func uiColor(fromInt value: Int64) -> UIColor {
    return UIColor(
      red: CGFloat((value & 0xFF0000) >> 16) / 0xFF,
      green: CGFloat((value & 0x00FF00) >> 8) / 0xFF,
      blue: CGFloat(value & 0x0000FF) / 0xFF,
      alpha: CGFloat((value & 0xFF000000) >> 24) / 0xFF
    )
  }

  internal class UserLocationObjectListener: NSObject, YMKUserLocationObjectListener {
    private let pluginRegistrar: FlutterPluginRegistrar!

    private let iconName: String!
    private let arrowName: String!
    private let userArrowOrientation: Bool!
    private let accuracyCircleFillColor: UIColor!

    public required init(
      pluginRegistrar: FlutterPluginRegistrar,
      iconName: String,
      arrowName: String,
      userArrowOrientation: Bool,
      accuracyCircleFillColor: UIColor
    ) {
      self.pluginRegistrar = pluginRegistrar
      self.iconName = iconName
      self.arrowName = arrowName
      self.userArrowOrientation = userArrowOrientation
      self.accuracyCircleFillColor = accuracyCircleFillColor
    }

    func onObjectAdded(with view: YMKUserLocationView) {
      view.pin.setIconWith(
        UIImage(named: pluginRegistrar.lookupKey(forAsset: self.iconName))!
      )
      view.arrow.setIconWith(
        UIImage(named: pluginRegistrar.lookupKey(forAsset: self.arrowName))!
      )
      if (userArrowOrientation) {
        view.arrow.setIconStyleWith(
          YMKIconStyle(
            anchor: nil,
            rotationType: YMKRotationType.rotate.rawValue as NSNumber,
            zIndex: nil,
            flat: nil,
            visible: nil,
            scale: nil,
            tappableArea: nil
          )
        )
      }
      view.accuracyCircle.fillColor = accuracyCircleFillColor
    }

    func onObjectRemoved(with view: YMKUserLocationView) {}

    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
  }

  internal class MapObjectTapListener: NSObject, YMKMapObjectTapListener {
    private let methodChannel: FlutterMethodChannel!

    public required init(channel: FlutterMethodChannel) {
      self.methodChannel = channel
    }

    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
      let arguments: [String:Any?] = [
        "hashCode": mapObject.userData,
        "latitude": point.latitude,
        "longitude": point.longitude
      ]
      methodChannel.invokeMethod("onMapObjectTap", arguments: arguments)

      return false
    }
  }

  internal class MapTapListener: NSObject, YMKMapInputListener {
    private let methodChannel: FlutterMethodChannel!

    public required init(channel: FlutterMethodChannel) {
      self.methodChannel = channel
    }

    func onMapTap(with map: YMKMap, point: YMKPoint) {
      let arguments: [String:Any?] = [
        "latitude": point.latitude,
        "longitude": point.longitude
      ]
      methodChannel.invokeMethod("onMapTap", arguments: arguments)
    }

    func onMapLongTap(with map: YMKMap, point: YMKPoint) {
      let arguments: [String:Any?] = [
        "latitude": point.latitude,
        "longitude": point.longitude
      ]
      methodChannel.invokeMethod("onMapLongTap", arguments: arguments)
    }
  }

  internal class MapCameraListener: NSObject, YMKMapCameraListener {
    weak private var yandexMapController: YandexMapController!
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
      let targetPoint = cameraPosition.target

      yandexMapController.cameraTarget?.geometry = targetPoint

      let arguments: [String:Any?] = [
        "latitude": targetPoint.latitude,
        "longitude": targetPoint.longitude,
        "zoom": cameraPosition.zoom,
        "tilt": cameraPosition.tilt,
        "azimuth": cameraPosition.azimuth,
        "final": finished
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
      let arguments: [String:Any?] = [
        "width": newWidth,
        "height": newHeight
      ]

      methodChannel.invokeMethod("onMapSizeChanged", arguments: arguments)
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
}
