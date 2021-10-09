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
  private let mapView: FLYMKMapView

  public required init(id: Int64, frame: CGRect, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.mapView = FLYMKMapView(frame: frame)
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

  public func showUserLayer(_ call: FlutterMethodCall) {
    if (!hasLocationPermission()) { return }

    let params = call.arguments as! [String: Any]

    self.userLocationObjectListener = UserLocationObjectListener(
      pluginRegistrar: pluginRegistrar,
      iconName: params["iconName"] as! String,
      arrowName: params["arrowName"] as! String,
      userArrowOrientation: (params["userArrowOrientation"] as! NSNumber).boolValue,
      accuracyCircleFillColor: uiColor(fromInt: (params["accuracyCircleFillColor"] as! NSNumber).int64Value)
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
      target: YandexMapController.pointFromJson(paramsTarget),
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
        southWest: YandexMapController.pointFromJson(southWest),
        northEast: YandexMapController.pointFromJson(northEast)
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
        "bottomLeft": YandexMapController.pointToJson(region.bottomLeft),
        "bottomRight": YandexMapController.pointToJson(region.bottomRight),
        "topLeft": YandexMapController.pointToJson(region.topLeft),
        "topRight": YandexMapController.pointToJson(region.bottomLeft)
      ]
    ]

    return arguments
  }

  public func addPlacemark(_ call: FlutterMethodCall) {
    
    let params = call.arguments as! [String: Any]
    let paramsPoint = params["point"] as! [String: NSNumber]
    let mapObjects = mapView.mapWindow.map.mapObjects
    let placemark = mapObjects.addPlacemark(with: YandexMapController.pointFromJson(paramsPoint))
    
    placemark.addTapListener(with: mapObjectTapListener)
    setupPlacemark(placemark: placemark, params: params)

    placemarks.append(placemark)
  }

  public func removePlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let mapObjects = mapView.mapWindow.map.mapObjects
    let id = params["id"] as! String

    if let placemark = placemarks.first(where: { $0.userData as! String == id }) {
      mapObjects.remove(with: placemark)
      placemarks.remove(at: placemarks.firstIndex(of: placemark)!)
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
    let params = call.arguments as! [String: Any]
    let mapObjects = mapView.mapWindow.map.mapObjects

    if mapCameraListener == nil {
      mapCameraListener = MapCameraListener(controller: self, channel: methodChannel)
      mapView.mapWindow.map.addCameraListener(with: mapCameraListener)
    }

    if cameraTarget != nil {
      mapObjects.remove(with: cameraTarget!)
      cameraTarget = nil
    }

    let targetPoint = mapView.mapWindow.map.cameraPosition.target;
    let arguments: [String: Any] = [
      "point": YandexMapController.pointToJson(targetPoint)
    ]

    if let style = params["style"] as? [String: Any] {
      cameraTarget = mapObjects.addPlacemark(with: targetPoint)

      applyPlacemarkStyle(cameraTarget!, style)
      cameraTarget!.addTapListener(with: mapObjectTapListener)
    }

    return arguments
  }

  public func addPolyline(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsCoordinates = params["coordinates"] as! [[String: NSNumber]]
    let paramsStyle = params["style"] as! [String: Any]
    let coordinatesPrepared = paramsCoordinates.map { YandexMapController.pointFromJson($0) }
    let mapObjects = mapView.mapWindow.map.mapObjects
    let polyline = YMKPolyline(points: coordinatesPrepared)
    let polylineMapObject = mapObjects.addPolyline(with: polyline)
    polylineMapObject.addTapListener(with: mapObjectTapListener)
    polylineMapObject.userData = params["id"] as! String
    polylineMapObject.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    polylineMapObject.zIndex = (params["zIndex"] as! NSNumber).floatValue
    polylineMapObject.strokeColor = uiColor(fromInt: (paramsStyle["strokeColor"] as! NSNumber).int64Value)
    polylineMapObject.outlineColor = uiColor(fromInt: (paramsStyle["outlineColor"] as! NSNumber).int64Value)
    polylineMapObject.outlineWidth = (paramsStyle["outlineWidth"] as! NSNumber).floatValue
    polylineMapObject.strokeWidth = (paramsStyle["strokeWidth"] as! NSNumber).floatValue
    polylineMapObject.dashLength = (paramsStyle["dashLength"] as! NSNumber).floatValue
    polylineMapObject.dashOffset = (paramsStyle["dashOffset"] as! NSNumber).floatValue
    polylineMapObject.gapLength = (paramsStyle["gapLength"] as! NSNumber).floatValue

    polylines.append(polylineMapObject)
  }

  public func removePolyline(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let id = params["id"] as! String

    if let polyline = polylines.first(where: { $0.userData as! String == id }) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: polyline)
      polylines.remove(at: polylines.firstIndex(of: polyline)!)
    }
  }

  public func addPolygon(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsOuterRingCoordinates = params["outerRingCoordinates"] as! [[String: NSNumber]]
    let paramsInnerRingsCoordinates = params["innerRingsCoordinates"] as! [[[String: NSNumber]]]
    let paramsStyle = params["style"] as! [String: Any]
    let outerRing = YMKLinearRing(points: paramsOuterRingCoordinates.map {
      YandexMapController.pointFromJson($0)
    })
    let innerRings = paramsInnerRingsCoordinates.map {
      YMKLinearRing(points: $0.map { YandexMapController.pointFromJson($0) })
    }
    let mapObjects = mapView.mapWindow.map.mapObjects
    let polylgon = YMKPolygon(outerRing: outerRing, innerRings: innerRings)
    let polygonMapObject = mapObjects.addPolygon(with: polylgon)

    polygonMapObject.addTapListener(with: mapObjectTapListener)
    polygonMapObject.userData = params["id"] as! String
    polygonMapObject.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    polygonMapObject.zIndex = (params["zIndex"] as! NSNumber).floatValue
    polygonMapObject.strokeColor = uiColor(fromInt: (paramsStyle["strokeColor"] as! NSNumber).int64Value)
    polygonMapObject.strokeWidth = (paramsStyle["strokeWidth"] as! NSNumber).floatValue
    polygonMapObject.fillColor = uiColor(fromInt: (paramsStyle["fillColor"] as! NSNumber).int64Value)

    polygons.append(polygonMapObject)
  }

  public func removePolygon(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let id = params["id"] as! String

    if let polygon = polygons.first(where: { $0.userData as! String ==  id }) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: polygon)
      polygons.remove(at: polygons.firstIndex(of: polygon)!)
    }
  }

  public func addCircle(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let paramsCenter = params["center"] as! [String: NSNumber]
    let paramsRadius = params["radius"] as! NSNumber
    let paramsStyle = params["style"] as! [String: Any]

    let mapObjects = mapView.mapWindow.map.mapObjects
    let circle = YMKCircle(center: YandexMapController.pointFromJson(paramsCenter), radius: paramsRadius.floatValue)

    let circleMapObject = mapObjects.addCircle(
      with: circle,
      stroke: uiColor(fromInt: (paramsStyle["strokeColor"] as! NSNumber).int64Value),
      strokeWidth: (paramsStyle["strokeWidth"] as! NSNumber).floatValue,
      fill: uiColor(fromInt: (paramsStyle["fillColor"] as! NSNumber).int64Value)
    )
    circleMapObject.addTapListener(with: mapObjectTapListener)
    circleMapObject.userData = params["id"] as! String
    circleMapObject.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    circleMapObject.zIndex = (params["zIndex"] as! NSNumber).floatValue

    circles.append(circleMapObject)
  }

  public func removeCircle(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let id = params["id"] as! String

    if let circle = circles.first(where: { $0.userData as! String == id }) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: circle)
      circles.remove(at: circles.firstIndex(of: circle)!)
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

  private func setupPlacemark(placemark: YMKPlacemarkMapObject, params: [String: Any]) {
    
    placemark.userData = (params["id"] as! NSNumber).intValue
    
    placemark.opacity     = (params["opacity"] as! NSNumber).floatValue
    placemark.isDraggable = (params["isDraggable"] as! NSNumber).boolValue
    placemark.direction   = (params["direction"] as! NSNumber).floatValue
    placemark.isVisible   = (params["isVisible"] as! NSNumber).boolValue
    
    if let zIndex = (params["zIndex"] as? NSNumber)?.floatValue {
      placemark.zIndex = zIndex
    }
    
    if let icon = params["icon"] as? [String: Any] {
      
      let img = getIconImage(icon)
      
      if img != nil {
        placemark.setIconWith(img!)
      }
      
      if let iconStyle = icon["style"] as? [String: Any] {
        let style = getIconStyle(iconStyle)
        placemark.setIconStyleWith(style)
      }
      
    } else if let composite = params["composite"] as? [String: Any] {
      
      for (name, iconData) in composite {
        
        guard let icon = iconData as? [String: Any] else {
          continue
        }
        
        guard let img = getIconImage(icon) else {
          continue
        }
        
        var style: YMKIconStyle = YMKIconStyle()
        
        if let iconStyle = icon["style"] as? [String: Any] {
          style = getIconStyle(iconStyle)
        }
        
        placemark.useCompositeIcon().setIconWithName(
          name,
          image: img,
          style: style
        )
      }
      
    }
  }
  
  private func getIconImage(_ iconData: [String: Any]) -> UIImage? {
   
    var img: UIImage?;
    
    if let iconName = iconData["iconName"] as? String {
      img = UIImage(named: pluginRegistrar.lookupKey(forAsset: iconName))
    } else if let rawImageData = iconData["rawImageData"] as? FlutterStandardTypedData {
      img = UIImage(data: rawImageData.data)
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
  
  private func uiColor(fromInt value: Int64) -> UIColor {
    return UIColor(
      red: CGFloat((value & 0xFF0000) >> 16) / 0xFF,
      green: CGFloat((value & 0x00FF00) >> 8) / 0xFF,
      blue: CGFloat(value & 0x0000FF) / 0xFF,
      alpha: CGFloat((value & 0xFF000000) >> 24) / 0xFF
    )
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

  private static func pointFromJson(_ json: [String: NSNumber]) -> YMKPoint {
    YMKPoint(
      latitude: json["latitude"]!.doubleValue,
      longitude: json["longitude"]!.doubleValue
    )
  }

  private static func pointToJson(_ point: YMKPoint) -> [String: Any] {
    return [
      "latitude": point.latitude,
      "longitude": point.longitude
    ]
  }

  private func applyPlacemarkStyle(_ placemark: YMKPlacemarkMapObject, _ style: [String: Any]) {
    let iconName = style["iconName"] as? String
    let iconAnchor = style["iconAnchor"] as! [String: NSNumber]

    placemark.opacity = (style["opacity"] as! NSNumber).floatValue
    placemark.direction = (style["direction"] as! NSNumber).floatValue

    if (iconName != nil) {
      placemark.setIconWith(UIImage(named: pluginRegistrar.lookupKey(forAsset: iconName!))!)
    }

    if let rawImageData = style["rawImageData"] as? FlutterStandardTypedData,
      let image = UIImage(data: rawImageData.data) {
      placemark.setIconWith(image)
    }

    let iconStyle = YMKIconStyle()
    let rotationType = (style["rotationType"] as! NSNumber).intValue
    if (rotationType == YMKRotationType.rotate.rawValue) {
      iconStyle.rotationType = (YMKRotationType.rotate.rawValue as NSNumber)
    }
    iconStyle.anchor = NSValue(cgPoint: CGPoint(x: iconAnchor["dx"]!.doubleValue, y: iconAnchor["dy"]!.doubleValue))
    iconStyle.scale = (style["scale"] as! NSNumber)

    placemark.setIconStyleWith(iconStyle)
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
      let arguments: [String: Any?] = [
        "id": mapObject.userData,
        "point": pointToJson(point)
      ]
      methodChannel.invokeMethod("onMapObjectTap", arguments: arguments)

      return true
    }
  }

  internal class MapTapListener: NSObject, YMKMapInputListener {
    private let methodChannel: FlutterMethodChannel!

    public required init(channel: FlutterMethodChannel) {
      self.methodChannel = channel
    }

    func onMapTap(with map: YMKMap, point: YMKPoint) {
      let arguments: [String: Any?] = [
        "point": pointToJson(point)
      ]
      methodChannel.invokeMethod("onMapTap", arguments: arguments)
    }

    func onMapLongTap(with map: YMKMap, point: YMKPoint) {
      let arguments: [String: Any?] = [
        "point": pointToJson(point)
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

      let arguments: [String: Any?] = [
        "cameraPosition": [
          "target": pointToJson(targetPoint),
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
