import CoreLocation
import Flutter
import UIKit
import YandexMapKit
import YandexMapKitSearch
import YandexMapKitDirections

public class YandexMapController: NSObject, FlutterPlatformView {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let mapTapListener: MapTapListener!
  private let mapObjectTapListener: MapObjectTapListener!
  private var mapCameraListener: MapCameraListener!
  private var userLocationObjectListener: UserLocationObjectListener?
  private var userLocationLayer: YMKUserLocationLayer?
  private var cameraTarget: YMKPlacemarkMapObject?
  private var drivingSession: YMKDrivingSession?
  private var locationManager: YMKLocationManager!
  private var yandexMapLocationListener: YandexMapLocationListener!
  private var currentLocation: YMKPoint!
  private var drivingFromLocation: YMKPoint!
  private var drivingToLocation: YMKPoint!
  private var placemarks: [YMKPlacemarkMapObject] = []
  private var drivingStartingPlacemark: YMKPlacemarkMapObject!
  private var polylines: [YMKPolylineMapObject] = []
  private var polygons: [YMKPolygonMapObject] = []
  private var drivingPolylines: [YMKPolylineMapObject] = []
  private var drivingPolylineStyle: [String: Any] = [:]
  public let mapView: YMKMapView

  private static let DESIRED_ACCURACY: Double = 0
  private static let MINIMAL_TIME: Int64 = 0
  private static let MINIMAL_DISTANCE: Double = 50
  private static let USE_IN_BACKGROUND: Bool = false

  public required init(id: Int64, frame: CGRect, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.mapView = YMKMapView(frame: frame)
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_map_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.mapTapListener = MapTapListener(channel: methodChannel)
    self.mapObjectTapListener = MapObjectTapListener(channel: methodChannel)
    self.userLocationLayer =
                YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
    super.init()

    weak var weakSelf = self
    self.methodChannel.setMethodCallHandler({ weakSelf?.handle($0, result: $1) })
    self.mapView.mapWindow.map.addInputListener(with: mapTapListener)

    self.locationManager = YMKMapKit.sharedInstance().createLocationManager()
    self.yandexMapLocationListener = YandexMapLocationListener(controller: self, channel: methodChannel)
    self.locationManager.subscribeForLocationUpdates(withDesiredAccuracy: YandexMapController.DESIRED_ACCURACY, minTime: YandexMapController.MINIMAL_TIME, minDistance: YandexMapController.MINIMAL_DISTANCE, allowUseInBackground: YandexMapController.USE_IN_BACKGROUND, filteringMode: .off, locationListener: yandexMapLocationListener)
  }

  public func view() -> UIView {
    return self.mapView
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
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
    case "zoomIn":
      zoomIn()
      result(nil)
    case "zoomOut":
      zoomOut()
      result(nil)
    case "getTargetPoint":
      let targetPoint = getTargetPoint()
      result(targetPoint)
    case "moveToUser":
      moveToUser()
      result(nil)
    case "routeToLocation":
      routeToLocation(call)
      result(nil)
    case "cancelRoute":
      cancelRoute()
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
          zoom: zoom+step,
          azimuth: azimuth,
          tilt: tilt
        )
      mapView.mapWindow.map.move(
          with: currentPosition,
          animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1),
          cameraCallback: nil
      )
  }

  public func move(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let point = YMKPoint(
      latitude: (params["latitude"] as! NSNumber).doubleValue,
      longitude: (params["longitude"] as! NSNumber).doubleValue
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
    let cameraPosition = mapView.mapWindow.map.cameraPosition(with:
      YMKBoundingBox(
        southWest: YMKPoint(
          latitude: (params["southWestLatitude"] as! NSNumber).doubleValue,
          longitude: (params["southWestLongitude"] as! NSNumber).doubleValue
        ),
        northEast: YMKPoint(
          latitude: (params["northEastLatitude"] as! NSNumber).doubleValue,
          longitude: (params["northEastLongitude"] as! NSNumber).doubleValue
        )
      )
    )

    moveWithParams(params, cameraPosition)
  }
    
  public func getTargetPoint() -> [String: Any] {
    let targetPoint = mapView.mapWindow.map.cameraPosition.target
    let arguments: [String: Any] = [
        "hashCode": targetPoint.hashValue,
        "latitude": targetPoint.latitude,
        "longitude": targetPoint.longitude
    ]
    return arguments
  }
    
  public func addPlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let point = YMKPoint(
      latitude: (params["latitude"] as! NSNumber).doubleValue,
      longitude: (params["longitude"] as! NSNumber).doubleValue
    )

    let placemark = preparePlacemark(point: point, params: params)
    placemark.userData = (params["hashCode"] as! NSNumber).intValue
    placemarks.append(placemark)
  }

  public func preparePlacemark(point: YMKPoint, params: [String: Any]) -> YMKPlacemarkMapObject {
    let mapObjects = mapView.mapWindow.map.mapObjects
    let placemark = mapObjects.addPlacemark(with: point)
    let iconName = params["iconName"] as? String

    placemark.addTapListener(with: mapObjectTapListener)
    placemark.opacity = (params["opacity"] as! NSNumber).floatValue
    placemark.isDraggable = (params["isDraggable"] as! NSNumber).boolValue
    placemark.direction = (params["direction"] as! NSNumber).floatValue

    if (iconName != nil) {
      placemark.setIconWith(UIImage(named: pluginRegistrar.lookupKey(forAsset: iconName!))!)
    }

    if let rawImageData = params["rawImageData"] as? FlutterStandardTypedData, 
      let image = UIImage(data: rawImageData.data) {
        placemark.setIconWith(image)
    }

    let iconStyle = YMKIconStyle()
    let rotationType = params["rotationType"] as? String
    if (rotationType == "RotationType.ROTATE") {
      iconStyle.rotationType = (YMKRotationType.rotate.rawValue as NSNumber)
    }
    iconStyle.anchor = NSValue(cgPoint:
      CGPoint(
        x: (params["anchorX"] as! NSNumber).doubleValue,
        y: (params["anchorY"] as! NSNumber).doubleValue
      )
    )
    iconStyle.zIndex = (params["zIndex"] as! NSNumber)
    iconStyle.scale = (params["scale"] as! NSNumber)
    placemark.setIconStyleWith(iconStyle)

    return placemark
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
    
    let targetPoint = mapView.mapWindow.map.cameraPosition.target
    if call.arguments != nil {
      let params = call.arguments as! [String: Any]
      
      cameraTarget = preparePlacemark(point: targetPoint, params: params)
      cameraTarget!.userData = (params["hashCode"] as! NSNumber).intValue
    }
    
    let arguments: [String: Any] = [
      "hashCode": targetPoint.hashValue,
      "latitude": targetPoint.latitude,
      "longitude": targetPoint.longitude
    ]
    return arguments
  }

  private func addPolyline(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let coordinates = params["coordinates"] as! [[String: Any]]
    let coordinatesPrepared = coordinates.map {
      YMKPoint(
        latitude: ($0["latitude"] as! NSNumber).doubleValue,
        longitude: ($0["longitude"] as! NSNumber).doubleValue
      )
    }
    let mapObjects = mapView.mapWindow.map.mapObjects
    let polyline = YMKPolyline(points: coordinatesPrepared)
    let polylineMapObject = mapObjects.addPolyline(with: polyline)
    polylineMapObject.userData = (params["hashCode"] as! NSNumber).intValue
    polylineMapObject.strokeColor = uiColor(fromInt: (params["strokeColor"] as! NSNumber).int64Value)
    polylineMapObject.outlineColor = uiColor(fromInt: (params["outlineColor"] as! NSNumber).int64Value)
    polylineMapObject.outlineWidth = (params["outlineWidth"] as! NSNumber).floatValue
    polylineMapObject.strokeWidth = (params["strokeWidth"] as! NSNumber).floatValue
    polylineMapObject.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    polylineMapObject.dashLength = (params["dashLength"] as! NSNumber).floatValue
    polylineMapObject.dashOffset = (params["dashOffset"] as! NSNumber).floatValue
    polylineMapObject.gapLength = (params["gapLength"] as! NSNumber).floatValue
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
    let coordinates = params["coordinates"] as! [[String: Any]]
    let coordinatesPrepared = coordinates.map {
      YMKPoint(
        latitude: ($0["latitude"] as! NSNumber).doubleValue,
        longitude: ($0["longitude"] as! NSNumber).doubleValue
      )
    }
    let mapObjects = mapView.mapWindow.map.mapObjects
    let polylgon = YMKPolygon(outerRing: YMKLinearRing(points: coordinatesPrepared), innerRings: [])
    let polygonMapObject = mapObjects.addPolygon(with: polylgon)

    polygonMapObject.userData = (params["hashCode"] as! NSNumber).intValue
    polygonMapObject.strokeColor = uiColor(fromInt: (params["strokeColor"] as! NSNumber).int64Value)
    polygonMapObject.strokeWidth = (params["strokeWidth"] as! NSNumber).floatValue
    polygonMapObject.isGeodesic = (params["isGeodesic"] as! NSNumber).boolValue
    polygonMapObject.fillColor = uiColor(fromInt: (params["fillColor"] as! NSNumber).int64Value)

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

  public func moveToUser() {
    if (!hasLocationPermission()) { return }
    let zoom = mapView.mapWindow.map.cameraPosition.zoom
    let azimuth = mapView.mapWindow.map.cameraPosition.azimuth
    let tilt = mapView.mapWindow.map.cameraPosition.tilt
    if let target = userLocationLayer?.cameraPosition()?.target {
      let cameraPosition = YMKCameraPosition(
        target: target,
        zoom: zoom,
        azimuth: azimuth,
        tilt: tilt
      )
      mapView.mapWindow.map.move(
        with: cameraPosition,
        animationType: YMKAnimation.init(type: YMKAnimationType.smooth, duration: 1),
        cameraCallback: nil
      )
    }
  }

  private func moveWithParams(_ params: [String: Any], _ cameraPosition: YMKCameraPosition) {
    if ((params["animate"] as! NSNumber).boolValue) {
      let type = (params["smoothAnimation"] as! NSNumber).boolValue ? YMKAnimationType.smooth : YMKAnimationType.linear
      let animationType = YMKAnimation(type: type, duration: (params["animationDuration"] as! NSNumber).floatValue)

      mapView.mapWindow.map.move(with: cameraPosition, animationType: animationType)
    } else {
      mapView.mapWindow.map.move(with: cameraPosition)
    }
  }

  public func routeToLocation(_ call: FlutterMethodCall) {
    if (!hasLocationPermission()) { return }
    
    cancelRoute()

    let params = call.arguments as! [String: Any]
    let destination = params["destination"] as! [String: Any]
    let polylineStyle = params["polylineStyle"] as! [String: Any]
    let startingPointStyle = params["startingPointStyle"] as! [String: Any]
    let destinationPoint = YMKPoint(
        latitude: (destination["latitude"] as! NSNumber).doubleValue,
        longitude: (destination["longitude"] as! NSNumber).doubleValue
      )
      
    drivingFromLocation = currentLocation
    drivingToLocation = destinationPoint
    drivingPolylineStyle = polylineStyle

    let box = YMKBoundingBox(southWest: drivingFromLocation, northEast: drivingToLocation)

    mapView.mapWindow.map.move(with: mapView.mapWindow.map.cameraPosition(with: box))
    zoomOut()

    setDrivingSession()
    
    if (startingPointStyle.count > 0){
      drivingStartingPlacemark = preparePlacemark(point: drivingFromLocation, params: startingPointStyle)
    }
  }

  public func setDrivingSession() {
    let requestPoints : [YMKRequestPoint] = [
        YMKRequestPoint(point: drivingFromLocation, type: .waypoint, pointContext: nil),
        YMKRequestPoint(point: drivingToLocation, type: .waypoint, pointContext: nil),
        ]
    
    let responseHandler = {(routesResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
        if let routes = routesResponse {
            self.onRoutesReceived(routes)
        } else {
            self.onRoutesError(error!)
        }
    }
    
    let drivingOptions = YMKDrivingDrivingOptions()
    drivingOptions.alternativeCount = 1
    let drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()
    drivingSession = drivingRouter.requestRoutes(
        with: requestPoints,
        drivingOptions: YMKDrivingDrivingOptions(),
        routeHandler: responseHandler)
  }

  public func cancelRoute() {
    if (drivingSession != nil) {
      drivingSession!.cancel()
      let mapObjects = mapView.mapWindow.map.mapObjects
      for polyline in drivingPolylines {
        mapObjects.remove(with: polyline)
      }
      drivingPolylines = []

      if (drivingStartingPlacemark != nil) {
        mapObjects.remove(with: drivingStartingPlacemark!)
        drivingStartingPlacemark = nil;
      }
    }

    drivingSession = nil
  }
     
  func onRoutesReceived(_ routes: [YMKDrivingRoute]) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      for route in routes {
          if (drivingPolylines.count > 0){
            for polyline in drivingPolylines {
              polyline.geometry = route.geometry
            }

            if (drivingStartingPlacemark != nil) {
              drivingStartingPlacemark!.geometry = route.geometry.points.first!
            }
          }
          else{
            let polylineMapObject = mapObjects.addPolyline(with: route.geometry)

            polylineMapObject.strokeColor = uiColor(fromInt: (drivingPolylineStyle["strokeColor"] as! NSNumber).int64Value)
            polylineMapObject.outlineColor = uiColor(fromInt: (drivingPolylineStyle["outlineColor"] as! NSNumber).int64Value)
            polylineMapObject.outlineWidth = (drivingPolylineStyle["outlineWidth"] as! NSNumber).floatValue
            polylineMapObject.strokeWidth = (drivingPolylineStyle["strokeWidth"] as! NSNumber).floatValue
            polylineMapObject.isGeodesic = (drivingPolylineStyle["isGeodesic"] as! NSNumber).boolValue
            polylineMapObject.dashLength = (drivingPolylineStyle["dashLength"] as! NSNumber).floatValue
            polylineMapObject.dashOffset = (drivingPolylineStyle["dashOffset"] as! NSNumber).floatValue
            polylineMapObject.gapLength = (drivingPolylineStyle["gapLength"] as! NSNumber).floatValue

            drivingPolylines.append(polylineMapObject)
          }

          let drivingRouteMetadata = route.metadata;
          let weight = drivingRouteMetadata.weight;
          let distance = weight.distance;
          let time = weight.time;
          let timeWithTraffic = weight.timeWithTraffic;

          let arguments: [String:Any?] = [
            "distance": distance.text,
            "time": time.text,
            "timeWithTraffic": timeWithTraffic.text
          ]
          methodChannel.invokeMethod("onDrivingRoutes", arguments: arguments)
      }
  }
  
  func onRoutesError(_ error: Error) {
      let routingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
      var errorMessage = "Unknown error"
      if routingError.isKind(of: YRTNetworkError.self) {
          errorMessage = "Network error"
      } else if routingError.isKind(of: YRTRemoteError.self) {
          errorMessage = "Remote server error"
      }
      let arguments: [String:Any?] = [
        "error": errorMessage
      ]
      methodChannel.invokeMethod("onDrivingRoutesError", arguments: arguments)
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
      alpha: CGFloat((value & 0xFF000000) >> 24) / 0xFF)
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
    private let yandexMapController: YandexMapController!
    private let methodChannel: FlutterMethodChannel!

    public required init(controller: YandexMapController, channel: FlutterMethodChannel) {
      self.yandexMapController = controller
      self.methodChannel = channel
      super.init()
    }

    internal func onCameraPositionChanged(
      with map: YMKMap,
      cameraPosition: YMKCameraPosition,
      cameraUpdateSource: YMKCameraUpdateSource,
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

  internal class YandexMapLocationListener: NSObject, YMKLocationDelegate  {
    private let yandexMapController: YandexMapController!
    private let methodChannel: FlutterMethodChannel!

    public required init(controller: YandexMapController, channel: FlutterMethodChannel) {
      self.yandexMapController = controller
      self.methodChannel = channel
      super.init()
    }

    func onLocationUpdated(with location: YMKLocation) {
        yandexMapController.currentLocation = YMKPoint(latitude: location.position.latitude, longitude: location.position.longitude)
      if (yandexMapController.drivingSession != nil && yandexMapController.currentLocation != yandexMapController.drivingFromLocation) {
        yandexMapController.drivingFromLocation = yandexMapController.currentLocation
        yandexMapController.setDrivingSession()
      }
    }
    
    func onLocationStatusUpdated(with status: YMKLocationStatus) {
      if (status == YMKLocationStatus.notAvailable) {
        let arguments: [String:Any?] = [
          "status": "NOT_AVAILABLE"
        ]
        methodChannel.invokeMethod("onLocationStatusUpdated", arguments: arguments)
      }

    }
  }
}
